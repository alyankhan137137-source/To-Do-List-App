import 'package:flutter/material.dart';
import 'priority_enum.dart';
import 'sub_task_model.dart';
import 'task_model.dart';

/// Preset templates for instant task creation.
class TaskTemplate {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String categoryId;
  final PriorityLevel priority;
  final List<String> subTaskTitles;

  const TaskTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.categoryId,
    required this.priority,
    required this.subTaskTitles,
  });

  TaskModel toTask() {
    final now = DateTime.now();
    return TaskModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      createdAt: now,
      categoryId: categoryId,
      priority: priority,
      subTasks: subTaskTitles.asMap().entries.map((entry) {
        return SubTask(
          id: '${now.millisecondsSinceEpoch}_${entry.key}',
          title: entry.value,
        );
      }).toList(),
    );
  }

  static const List<TaskTemplate> presets = [
    TaskTemplate(
      id: 'morning_routine',
      title: '🌅 Morning Productivity Routine',
      description: 'Kickstart your day with mindfulness, exercise, and planning.',
      icon: Icons.wb_sunny_rounded,
      color: Colors.amber,
      categoryId: 'personal',
      priority: PriorityLevel.high,
      subTaskTitles: [
        'Drink 500ml water',
        '10 minutes meditation or stretching',
        'Review top 3 priorities for today',
        'Healthy breakfast',
      ],
    ),
    TaskTemplate(
      id: 'weekly_groceries',
      title: '🛒 Weekly Grocery Shopping List',
      description: 'Essential items for a healthy week ahead.',
      icon: Icons.shopping_cart_rounded,
      color: Colors.orange,
      categoryId: 'shopping',
      priority: PriorityLevel.medium,
      subTaskTitles: [
        'Fresh fruits & vegetables',
        'Almond / Oat milk',
        'Whole grain bread & eggs',
        'Healthy snacks & nuts',
      ],
    ),
    TaskTemplate(
      id: 'fitness_session',
      title: '🏋️ 45-Min Workout & Fitness',
      description: 'Full-body strength training and recovery.',
      icon: Icons.fitness_center_rounded,
      color: Colors.purple,
      categoryId: 'fitness',
      priority: PriorityLevel.medium,
      subTaskTitles: [
        '5-min warm-up cardio',
        'Core & upper body circuit',
        'Lower body squats & lunges',
        'Cool down & post-workout stretch',
      ],
    ),
    TaskTemplate(
      id: 'work_standup',
      title: '💻 Daily Work Standup & Sprint Plan',
      description: 'Organize sprint backlog and sync with team.',
      icon: Icons.laptop_mac_rounded,
      color: Colors.blue,
      categoryId: 'work',
      priority: PriorityLevel.urgent,
      subTaskTitles: [
        'Check priority emails & messages',
        'Update sprint board tickets',
        'Prepare standup update notes',
        'Focus block: 90 mins deep work',
      ],
    ),
    TaskTemplate(
      id: 'study_session',
      title: '📚 1-Hour Deep Study & Reading',
      description: 'Uninterrupted learning session with Pomodoro technique.',
      icon: Icons.menu_book_rounded,
      color: Colors.cyan,
      categoryId: 'education',
      priority: PriorityLevel.low,
      subTaskTitles: [
        'Clear workspace & eliminate distractions',
        '25 mins focused reading',
        'Take 5-min break',
        'Summarize key takeaways',
      ],
    ),
  ];
}
