import 'dart:convert';
import 'priority_enum.dart';
import 'sub_task_model.dart';

/// Data model representing a task item with categories, due date, priorities, and sub-tasks.
class TaskModel {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime? dueDate;
  final DateTime createdAt;
  final PriorityLevel priority;
  final String categoryId;
  final List<SubTask> subTasks;

  TaskModel({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    this.dueDate,
    required this.createdAt,
    this.priority = PriorityLevel.medium,
    this.categoryId = 'personal',
    this.subTasks = const [],
  });

  /// Calculates completion progress for sub-tasks (0.0 to 1.0)
  double get subTaskProgress {
    if (subTasks.isEmpty) return isCompleted ? 1.0 : 0.0;
    final completedCount = subTasks.where((st) => st.isCompleted).length;
    return completedCount / subTasks.length;
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? dueDate,
    DateTime? createdAt,
    PriorityLevel? priority,
    String? categoryId,
    List<SubTask>? subTasks,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      priority: priority ?? this.priority,
      categoryId: categoryId ?? this.categoryId,
      subTasks: subTasks ?? this.subTasks,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'priority': priority.name,
      'categoryId': categoryId,
      'subTasks': subTasks.map((x) => x.toMap()).toList(),
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      createdAt: DateTime.parse(map['createdAt']),
      priority: PriorityLevel.values.firstWhere(
        (e) => e.name == map['priority'],
        orElse: () => PriorityLevel.medium,
      ),
      categoryId: map['categoryId'] ?? 'personal',
      subTasks: map['subTasks'] != null
          ? List<SubTask>.from(map['subTasks'].map((x) => SubTask.fromMap(x)))
          : [],
    );
  }

  String toJson() => json.encode(toMap());

  factory TaskModel.fromJson(String source) => TaskModel.fromMap(json.decode(source));
}
