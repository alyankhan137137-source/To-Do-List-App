import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/priority_enum.dart';
import '../../../providers/task_provider.dart';

/// Bottom sheet displaying visual productivity analytics, priority breakdown, and streak stats.
class AnalyticsSheet extends StatelessWidget {
  const AnalyticsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, child) {
        final total = provider.totalTasksCount;
        final completed = provider.completedTasksCount;
        final active = provider.activeTasksCount;
        final overdue = provider.overdueTasksCount;
        final streak = provider.streakCount;

        final urgentCount = provider.allTasks.where((t) => t.priority == PriorityLevel.urgent).length;
        final highCount = provider.allTasks.where((t) => t.priority == PriorityLevel.high).length;
        final medCount = provider.allTasks.where((t) => t.priority == PriorityLevel.medium).length;
        final lowCount = provider.allTasks.where((t) => t.priority == PriorityLevel.low).length;

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.insights_rounded, color: Colors.blueAccent),
                      SizedBox(width: 8),
                      Text(
                        'Productivity Analytics',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),

              // Overview Grid
              Row(
                children: [
                  _buildStatTile(context, 'Total Tasks', '$total', Icons.assignment_rounded, Colors.indigo),
                  const SizedBox(width: 8),
                  _buildStatTile(context, 'Completed', '$completed', Icons.check_circle_rounded, Colors.green),
                  const SizedBox(width: 8),
                  _buildStatTile(context, 'Streak', '$streak Days', Icons.local_fire_department_rounded, Colors.orange),
                ],
              ),

              const SizedBox(height: 20),

              // Status Summary Bar
              const Text('Task Status Ratio', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(flex: active > 0 ? active : 1, child: Container(height: 10, color: Colors.blue)),
                  Expanded(flex: completed > 0 ? completed : 1, child: Container(height: 10, color: Colors.green)),
                  Expanded(flex: overdue > 0 ? overdue : 1, child: Container(height: 10, color: Colors.red)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Active: $active', style: const TextStyle(fontSize: 11, color: Colors.blue)),
                  Text('Completed: $completed', style: const TextStyle(fontSize: 11, color: Colors.green)),
                  Text('Overdue: $overdue', style: const TextStyle(fontSize: 11, color: Colors.red)),
                ],
              ),

              const SizedBox(height: 20),

              // Priority Distribution Breakdown
              const Text('Priority Distribution', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              _buildPriorityBar('Urgent', urgentCount, total, PriorityLevel.urgent.color),
              _buildPriorityBar('High', highCount, total, PriorityLevel.high.color),
              _buildPriorityBar('Medium', medCount, total, PriorityLevel.medium.color),
              _buildPriorityBar('Low', lowCount, total, PriorityLevel.low.color),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatTile(BuildContext context, String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityBar(String label, int count, int total, Color color) {
    final ratio = total == 0 ? 0.0 : count / total;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(width: 60, child: Text(label, style: const TextStyle(fontSize: 12))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('$count', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
