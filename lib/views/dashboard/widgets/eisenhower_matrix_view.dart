import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/priority_enum.dart';
import '../../../models/task_model.dart';
import '../../../providers/task_provider.dart';
import 'task_detail_sheet.dart';

/// Eisenhower Matrix 4-Quadrant interactive task grid view.
class EisenhowerMatrixView extends StatelessWidget {
  const EisenhowerMatrixView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);
    final tasks = provider.filteredTasks;

    final urgentImportant = tasks.where((t) => (t.priority == PriorityLevel.urgent || t.priority == PriorityLevel.high) && !t.isCompleted).toList();
    final importantNotUrgent = tasks.where((t) => t.priority == PriorityLevel.medium && !t.isCompleted).toList();
    final urgentNotImportant = tasks.where((t) => t.priority == PriorityLevel.low && !t.isCompleted).toList();
    final completedOrLater = tasks.where((t) => t.isCompleted).toList();

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 0.85,
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        _buildQuadrant(
          context,
          title: '🔥 Do First',
          subtitle: 'Urgent & Important',
          color: Colors.red.shade400,
          tasks: urgentImportant,
        ),
        _buildQuadrant(
          context,
          title: '📅 Schedule',
          subtitle: 'Important, Not Urgent',
          color: Colors.amber.shade700,
          tasks: importantNotUrgent,
        ),
        _buildQuadrant(
          context,
          title: '🤝 Delegate',
          subtitle: 'Urgent, Less Important',
          color: Colors.blue.shade600,
          tasks: urgentNotImportant,
        ),
        _buildQuadrant(
          context,
          title: '✅ Completed / Done',
          subtitle: 'Finished tasks',
          color: Colors.green.shade600,
          tasks: completedOrLater,
        ),
      ],
    );
  }

  Widget _buildQuadrant(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Color color,
    required List<TaskModel> tasks,
  }) {
    final provider = Provider.of<TaskProvider>(context, listen: false);

    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
                child: Text(
                  '${tasks.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
          const Divider(height: 12),
          Expanded(
            child: tasks.isEmpty
                ? const Center(
                    child: Text(
                      'No tasks',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (ctx, index) {
                      final task = tasks[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 6),
                        child: InkWell(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                              ),
                              builder: (_) => TaskDetailSheet(taskId: task.id),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () => provider.toggleTaskCompletion(task.id),
                                  child: Icon(
                                    task.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                    size: 16,
                                    color: task.isCompleted ? Colors.green : Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    task.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
