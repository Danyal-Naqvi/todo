import 'dart:async';
import 'dart:developer' as developer;
import '../../../../core/firebase/firebase_service.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_datasource.dart';
import '../datasources/task_remote_datasource.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource? remoteDataSource;
  final TaskLocalDataSource localDataSource;

  TaskRepositoryImpl({
    this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  bool get isCloudSyncEnabled =>
      FirebaseService.instance.isInitialized && remoteDataSource != null;

  @override
  Stream<List<Task>> watchTasks({required String userId}) {
    if (isCloudSyncEnabled) {
      try {
        return remoteDataSource!.streamTasks(userId).handleError((error) {
          developer.log('Remote stream error: $error. Falling back to local cache.', name: 'TaskRepositoryImpl');
          return localDataSource.streamTasks();
        });
      } catch (e) {
        developer.log('Error opening remote stream: $e', name: 'TaskRepositoryImpl');
        return localDataSource.streamTasks();
      }
    } else {
      return localDataSource.streamTasks();
    }
  }

  @override
  Future<List<Task>> getTasks({required String userId}) async {
    if (isCloudSyncEnabled) {
      try {
        final remoteTasks = await remoteDataSource!.getTasks(userId);
        // Update local cache
        for (final t in remoteTasks) {
          await localDataSource.saveTask(t);
        }
        return remoteTasks;
      } catch (e) {
        developer.log('Remote getTasks error: $e. Using local data.', name: 'TaskRepositoryImpl');
        return localDataSource.getTasks();
      }
    } else {
      return localDataSource.getTasks();
    }
  }

  @override
  Future<void> addTask(Task task, {required String userId}) async {
    final model = TaskModel.fromEntity(task);
    await localDataSource.saveTask(model);

    if (isCloudSyncEnabled) {
      try {
        await remoteDataSource!.saveTask(userId, model);
      } catch (e) {
        developer.log('Failed to sync added task to Firestore: $e', name: 'TaskRepositoryImpl');
      }
    }
  }

  @override
  Future<void> updateTask(Task task, {required String userId}) async {
    final model = TaskModel.fromEntity(task);
    await localDataSource.updateTask(model);

    if (isCloudSyncEnabled) {
      try {
        await remoteDataSource!.updateTask(userId, model);
      } catch (e) {
        developer.log('Failed to update task in Firestore: $e', name: 'TaskRepositoryImpl');
      }
    }
  }

  @override
  Future<void> deleteTask(String taskId, {required String userId}) async {
    await localDataSource.deleteTask(taskId);

    if (isCloudSyncEnabled) {
      try {
        await remoteDataSource!.deleteTask(userId, taskId);
      } catch (e) {
        developer.log('Failed to delete task from Firestore: $e', name: 'TaskRepositoryImpl');
      }
    }
  }

  @override
  Future<void> toggleTaskStatus(String taskId, {required String userId}) async {
    final currentTasks = await localDataSource.getTasks();
    final index = currentTasks.indexWhere((t) => t.id == taskId);
    if (index >= 0) {
      final task = currentTasks[index];
      final newStatus = !task.isCompleted;
      final updated = task.copyWith(
        isCompleted: newStatus,
        completedAt: newStatus ? DateTime.now() : null,
        status: newStatus
            ? 'Completed'
            : (task.status == 'Completed' ? 'In Process' : task.status),
      );
      await updateTask(updated, userId: userId);
    }
  }

  @override
  Future<void> toggleSubTaskStatus(
    String taskId,
    String subTaskId, {
    required String userId,
  }) async {
    final currentTasks = await localDataSource.getTasks();
    final index = currentTasks.indexWhere((t) => t.id == taskId);
    if (index >= 0) {
      final task = currentTasks[index];
      final updatedSubtasks = task.subtasks.map((st) {
        if (st.id == subTaskId) {
          return st.copyWith(isCompleted: !st.isCompleted);
        }
        return st;
      }).toList();

      final allCompleted = updatedSubtasks.isNotEmpty &&
          updatedSubtasks.every((st) => st.isCompleted);

      final updatedTask = task.copyWith(
        subtasks: updatedSubtasks,
        isCompleted: allCompleted,
        completedAt: allCompleted ? DateTime.now() : null,
        status: allCompleted
            ? 'Completed'
            : (task.status == 'Completed' ? 'In Process' : task.status),
      );
      await updateTask(updatedTask, userId: userId);
    }
  }

  @override
  Future<void> togglePinTask(String taskId, {required String userId}) async {
    final currentTasks = await localDataSource.getTasks();
    final index = currentTasks.indexWhere((t) => t.id == taskId);
    if (index >= 0) {
      final task = currentTasks[index];
      final updated = task.copyWith(isPinned: !task.isPinned);
      await updateTask(updated, userId: userId);
    }
  }

  @override
  Future<void> clearCompletedTasks({required String userId}) async {
    final currentTasks = await localDataSource.getTasks();
    final completedIds = currentTasks
        .where((t) => t.isCompleted)
        .map((t) => t.id)
        .toList();

    await localDataSource.clearCompleted();

    if (isCloudSyncEnabled && completedIds.isNotEmpty) {
      try {
        await remoteDataSource!.batchDeleteTasks(userId, completedIds);
      } catch (e) {
        developer.log('Failed to batch delete completed tasks from Firestore: $e', name: 'TaskRepositoryImpl');
      }
    }
  }
}
