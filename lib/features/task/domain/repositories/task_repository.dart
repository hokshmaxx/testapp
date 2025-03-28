import '../entities/task.dart';

abstract class TaskRepository {
  Stream<List<Task>> watchTasks();
  Future<void> createTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String taskId);
  Future<List<Task>> getTasks();
  Future<Task?> getTask(String taskId);
} 