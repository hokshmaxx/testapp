import 'package:equatable/equatable.dart';
import '../../domain/entities/task.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class LoadTasks extends TaskEvent {}

class CreateTask extends TaskEvent {
  final String title;
  final String description;
  final DateTime dueDate;

  const CreateTask({
    required this.title,
    required this.description,
    required this.dueDate,
  });

  @override
  List<Object?> get props => [title, description, dueDate];
}

class UpdateTask extends TaskEvent {
  final Task task;

  const UpdateTask(this.task);

  @override
  List<Object?> get props => [task];
}

class DeleteTask extends TaskEvent {
  final String taskId;

  const DeleteTask(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class UpdateTaskStatus extends TaskEvent {
  final String taskId;
  final TaskStatus status;

  const UpdateTaskStatus({
    required this.taskId,
    required this.status,
  });

  @override
  List<Object?> get props => [taskId, status];
} 