import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/task.dart';

class TaskListItem extends StatelessWidget {
  final Task task;
  final Function(TaskStatus) onStatusChanged;
  final VoidCallback onDelete;

  const TaskListItem({
    super.key,
    required this.task,
    required this.onStatusChanged,
    required this.onDelete,
  });

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return Colors.orange;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.completed:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _getStatusColor(task.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: PopupMenuButton<TaskStatus>(
                    onSelected: onStatusChanged,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: BoxDecoration(
                            color: _getStatusColor(task.status),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          task.status.name.replaceAll(RegExp(r'(?=[A-Z])'), ' '),
                          style: TextStyle(
                            color: _getStatusColor(task.status),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    itemBuilder: (context) => TaskStatus.values
                        .map(
                          (status) => PopupMenuItem(
                            value: status,
                            child: Row(
                              children: [
                                Container(
                                  width: 8.w,
                                  height: 8.w,
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(status),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  status.name.replaceAll(RegExp(r'(?=[A-Z])'), ' '),
                                  style: TextStyle(
                                    color: _getStatusColor(status),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                SizedBox(width: 8.w),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: onDelete,
                  color: Colors.red,
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              task.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16.r,
                  color: Colors.grey,
                ),
                SizedBox(width: 4.w),
                Text(
                  'Due: ${DateFormat('MMM dd, yyyy HH:mm').format(task.dueDate)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 