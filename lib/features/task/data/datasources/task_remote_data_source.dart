import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

abstract class TaskRemoteDataSource {
  Stream<List<TaskModel>> watchTasks();
  Future<void> createTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
  Future<void> deleteTask(String taskId);
  Future<List<TaskModel>> getTasks();
  Future<TaskModel?> getTask(String taskId);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final FirebaseFirestore firestore;
  final String collection = 'tasks';

  TaskRemoteDataSourceImpl(this.firestore);

  @override
  Stream<List<TaskModel>> watchTasks() {
    return firestore
        .collection(collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaskModel.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  @override
  Future<void> createTask(TaskModel task) async {
    await firestore.collection(collection).doc(task.id).set(task.toJson());
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    await firestore.collection(collection).doc(task.id).update(task.toJson());
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await firestore.collection(collection).doc(taskId).delete();
  }

  @override
  Future<List<TaskModel>> getTasks() async {
    final snapshot = await firestore
        .collection(collection)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => TaskModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  @override
  Future<TaskModel?> getTask(String taskId) async {
    final doc = await firestore.collection(collection).doc(taskId).get();
    if (!doc.exists) return null;
    return TaskModel.fromJson({...doc.data()!, 'id': doc.id});
  }
} 