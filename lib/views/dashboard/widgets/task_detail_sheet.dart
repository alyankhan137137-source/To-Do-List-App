import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../models/category_model.dart';
import '../../../models/priority_enum.dart';
import '../../../providers/task_provider.dart';
import 'add_edit_task_sheet.dart';

/// Modal bottom sheet for viewing full task details and toggling sub-tasks.
class TaskDetailSheet extends StatelessWidget {
  final String taskId;

  const TaskDetailSheet({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, child) {
        final taskIndex = provider.allTasks.indexWhere((t) => t.id == taskId);
        if (taskIndex == -1) {
          return const SizedBox.shrink();
        }

        final task = provider.allTasks[taskIndex];
        final category = TaskCategory.getById(task.categoryId);
        final isOverdue = DateFormatter.isOverdue(task.dueDate, task.isCompleted);

        return Container(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: category.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(category.icon, size: 16, color: category.color),
                          const SizedBox(width: 6),
                          Text(
                            category.title,
                            style: TextStyle(
                              color: category.color,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_rounded),
                          tooltip: 'Edit Task',
                          onPressed: () {
                            Navigator.pop(context);
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                              ),
                              builder: (_) => AddEditTaskSheet(existingTask: task),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_rounded, color: Colors.redAccent),
                          tooltip: 'Delete Task',
                          onPressed: () {
                            Navigator.pop(context);
                            provider.deleteTask(task.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Task deleted'),
                                action: SnackBarAction(
                                  label: 'UNDO',
                                  onPressed: () => provider.restoreLastDeletedTask(),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Main Title
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 12),

                // Metadata Chips
                Row(
                  children: [
                    // Priority Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: task.priority.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Priority: ${task.priority.label}',
                        style: TextStyle(
                          color: task.priority.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Due Date
                    if (task.dueDate != null) ...[
                      Icon(
                        Icons.event_rounded,
                        size: 16,
                        color: isOverdue ? Colors.red : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormatter.formatDueDate(task.dueDate),
                        style: TextStyle(
                          fontSize: 12,
                          color: isOverdue ? Colors.red : Colors.grey.shade700,
                          fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ],
                ),

                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text('Notes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      task.description,
                      style: const TextStyle(fontSize: 14, height: 1.4),
                    ),
                  ),
                ],

                // Sub-tasks Section
                if (task.subTasks.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Checklist', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(
                        '${task.subTasks.where((s) => s.isCompleted).length} / ${task.subTasks.length}',
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...task.subTasks.map((st) {
                    return CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        st.title,
                        style: TextStyle(
                          decoration: st.isCompleted ? TextDecoration.lineThrough : null,
                          color: st.isCompleted ? Colors.grey : null,
                        ),
                      ),
                      value: st.isCompleted,
                      onChanged: (_) {
                        provider.toggleSubTask(task.id, st.id);
                      },
                    );
                  }),
                ],

                const SizedBox(height: 28),

                // Mark Complete / Re-open Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: task.isCompleted ? Colors.grey.shade700 : Theme.of(context).primaryColor,
                    ),
                    onPressed: () {
                      provider.toggleTaskCompletion(task.id);
                    },
                    icon: Icon(
                      task.isCompleted ? Icons.replay_rounded : Icons.check_circle_rounded,
                      color: Colors.white,
                    ),
                    label: Text(
                      task.isCompleted ? 'Mark as Incomplete' : 'Mark as Complete',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
