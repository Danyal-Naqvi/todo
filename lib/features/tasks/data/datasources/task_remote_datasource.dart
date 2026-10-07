import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

abstract class TaskRemoteDataSource {
  Stream<List<TaskModel>> streamTasks(String userId);
  Future<List<TaskModel>> getTasks(String userId);
  Future<void> saveTask(String userId, TaskModel task);
  Future<void> updateTask(String userId, TaskModel task);
  Future<void> deleteTask(String userId, String taskId);
  Future<void> batchDeleteTasks(String userId, List<String> taskIds);
}

class FirebaseTaskRemoteDataSource implements TaskRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirebaseTaskRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _tasksCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('tasks');
  }

  @override
  Stream<List<TaskModel>> streamTasks(String userId) {
    return _tasksCollection(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TaskModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  @override
  Future<List<TaskModel>> getTasks(String userId) async {
    final snapshot = await _tasksCollection(userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => TaskModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<void> saveTask(String userId, TaskModel task) async {
    await _tasksCollection(userId).doc(task.id).set(
          task.toFirestore(),
          SetOptions(merge: true),
        );
  }

  @override
  Future<void> updateTask(String userId, TaskModel task) async {
    await _tasksCollection(userId).doc(task.id).update(task.toFirestore());
  }

  @override
  Future<void> deleteTask(String userId, String taskId) async {
    await _tasksCollection(userId).doc(taskId).delete();
  }

  @override
  Future<void> batchDeleteTasks(String userId, List<String> taskIds) async {
    final batch = _firestore.batch();
    for (final id in taskIds) {
      batch.delete(_tasksCollection(userId).doc(id));
    }
    await batch.commit();
  }
}
