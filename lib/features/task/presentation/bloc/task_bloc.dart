import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:testapp/core/services/notification_service.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/task.dart';
import '../../domain/usecases/create_task.dart' as create_task;
import '../../domain/usecases/delete_task.dart' as delete_task;
import '../../domain/usecases/get_tasks.dart' as get_tasks;
import '../../domain/usecases/update_task.dart' as update_task;
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final get_tasks.GetTasks getTasks;
  final create_task.CreateTask createTask;
  final update_task.UpdateTask updateTask;
  final delete_task.DeleteTask deleteTask;
  final NotificationService notificationService;

  TaskBloc({
    required this.getTasks,
    required this.createTask,
    required this.updateTask,
    required this.deleteTask,
    required this.notificationService,
  }) : super(TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<CreateTask>(_onCreateTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<UpdateTaskStatus>(_onUpdateTaskStatus);
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    try {
      emit(TaskLoading());
      final tasks = await getTasks();
      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onCreateTask(CreateTask event, Emitter<TaskState> emit) async {
    try {
      final task = Task(
        id: const Uuid().v4(),
        title: event.title,
        description: event.description,
        status: TaskStatus.todo,
        dueDate: event.dueDate,
        userId: 'current_user_id', // TODO: Get from auth
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await createTask(task);
      
      // Schedule notification for the new task
      await notificationService.scheduleTaskNotification(
        taskId: task.id,
        title: task.title,
        description: task.description,
        dueDate: task.dueDate,
      );
      
      add(LoadTasks());
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    try {
      await updateTask(event.task);
      
      // Cancel existing notification and schedule a new one
      await notificationService.cancelTaskNotification(event.task.id);
      await notificationService.scheduleTaskNotification(
        taskId: event.task.id,
        title: event.task.title,
        description: event.task.description,
        dueDate: event.task.dueDate,
      );
      
      add(LoadTasks());
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    try {
      await deleteTask(event.taskId);
      
      // Cancel notification for the deleted task
      await notificationService.cancelTaskNotification(event.taskId);
      
      add(LoadTasks());
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onUpdateTaskStatus(
    UpdateTaskStatus event,
    Emitter<TaskState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is TaskLoaded) {
        final task = currentState.tasks.firstWhere((t) => t.id == event.taskId);
        final updatedTask = task.copyWith(
          status: event.status,
          updatedAt: DateTime.now(),
        );
        await updateTask(updatedTask);

        // Send notification about task state change
        await notificationService.sendTaskStateChangeNotification(
          taskId: task.id,
          title: task.title,
          newStatus: event.status.name,
          userId: task.userId,
        );

        add(LoadTasks());
      }
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }
} 