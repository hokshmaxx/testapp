import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../auth/domain/usecases/sign_out.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import '../widgets/task_list_item.dart';
import '../widgets/add_task_dialog.dart';

class TaskListPage extends StatelessWidget {
  const TaskListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Management'),
        centerTitle: true,
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if(state is TaskInitial){
            context.read<TaskBloc>().add(LoadTasks());
          }
          print('stattttt$state');
          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TaskError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.message,
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      context.read<TaskBloc>().add(LoadTasks());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is TaskLoaded) {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16.r),
                    itemCount: state.tasks.length,
                    itemBuilder: (context, index) {
                      final task = state.tasks[index];
                      return TaskListItem(
                        task: task,
                        onStatusChanged: (newStatus) {
                          context.read<TaskBloc>().add(
                                UpdateTaskStatus(
                                  taskId: task.id,
                                  status: newStatus,
                                ),
                              );
                        },
                        onDelete: () {
                          context.read<TaskBloc>().add(
                                DeleteTask(task.id),
                              );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.r),
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const AddTaskDialog(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50.h),
                    ),
                    child: const Text('Add New Task'),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.r),
                  child: ElevatedButton(
                    onPressed: () {
                     context.read<AuthBloc>().add(SignOutRequested());
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50.h),
                    ),
                    child: const Text('Sign Out'),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
} 