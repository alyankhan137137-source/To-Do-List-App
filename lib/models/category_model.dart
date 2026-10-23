import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Represents a task category with display properties and predefined defaults.
class TaskCategory {
  final String id;
  final String title;
  final IconData icon;
  final Color color;

  const TaskCategory({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
  });

  static const List<TaskCategory> defaultCategories = [
    TaskCategory(
      id: 'all',
      title: 'All',
      icon: Icons.grid_view_rounded,
      color: AppColors.primary,
    ),
    TaskCategory(
      id: 'work',
      title: 'Work',
      icon: Icons.work_rounded,
      color: AppColors.categoryWork,
    ),
    TaskCategory(
      id: 'personal',
      title: 'Personal',
      icon: Icons.person_rounded,
      color: AppColors.categoryPersonal,
    ),
    TaskCategory(
      id: 'shopping',
      title: 'Shopping',
      icon: Icons.shopping_cart_rounded,
      color: AppColors.categoryShopping,
    ),
    TaskCategory(
      id: 'health',
      title: 'Health',
      icon: Icons.favorite_rounded,
      color: AppColors.categoryHealth,
    ),
    TaskCategory(
      id: 'fitness',
      title: 'Fitness',
      icon: Icons.fitness_center_rounded,
      color: AppColors.categoryFitness,
    ),
    TaskCategory(
      id: 'education',
      title: 'Education',
      icon: Icons.school_rounded,
      color: AppColors.categoryEducation,
    ),
    TaskCategory(
      id: 'other',
      title: 'Other',
      icon: Icons.more_horiz_rounded,
      color: AppColors.categoryOther,
    ),
  ];

  static TaskCategory getById(String id) {
    return defaultCategories.firstWhere(
      (cat) => cat.id == id,
      orElse: () => defaultCategories.last,
    );
  }
}
