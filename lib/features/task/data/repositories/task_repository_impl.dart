import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_remote_data_source.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;

  TaskRepositoryImpl(this.remoteDataSource);

  @override
  Stream<List<Task>> watchTasks() {
    return remoteDataSource.watchTasks();
  }

  @override
  Future<void> createTask(Task task) async {
    await remoteDataSource.createTask(TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      status: task.status,
      dueDate: task.dueDate,
      userId: task.userId,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
    ));
  }

  @override
  Future<void> updateTask(Task task) async {
    await remoteDataSource.updateTask(TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      status: task.status,
      dueDate: task.dueDate,
      userId: task.userId,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
    ));
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await remoteDataSource.deleteTask(taskId);
  }

  @override
  Future<List<Task>> getTasks() async {
    return await remoteDataSource.getTasks();
  }

  @override
  Future<Task?> getTask(String taskId) async {
    return await remoteDataSource.getTask(taskId);
  }
} 