import '../entities/task.dart';

abstract class TaskRepository {
  Stream<List<Task>> watchTasks({required String userId});
  Future<List<Task>> getTasks({required String userId});
  Future<void> addTask(Task task, {required String userId});
  Future<void> updateTask(Task task, {required String userId});
  Future<void> deleteTask(String taskId, {required String userId});
  Future<void> toggleTaskStatus(String taskId, {required String userId});
  Future<void> toggleSubTaskStatus(String taskId, String subTaskId, {required String userId});
  Future<void> togglePinTask(String taskId, {required String userId});
  Future<void> clearCompletedTasks({required String userId});
  bool get isCloudSyncEnabled;
}
