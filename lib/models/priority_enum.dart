import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Priority levels for tasks with associated display labels, colors, and sorting weight.
enum PriorityLevel {
  low,
  medium,
  high,
  urgent,
}

extension PriorityLevelExtension on PriorityLevel {
  String get label {
    switch (this) {
      case PriorityLevel.low:
        return 'Low';
      case PriorityLevel.medium:
        return 'Medium';
      case PriorityLevel.high:
        return 'High';
      case PriorityLevel.urgent:
        return 'Urgent';
    }
  }

  Color get color {
    switch (this) {
      case PriorityLevel.low:
        return AppColors.priorityLow;
      case PriorityLevel.medium:
        return AppColors.priorityMedium;
      case PriorityLevel.high:
        return AppColors.priorityHigh;
      case PriorityLevel.urgent:
        return AppColors.priorityUrgent;
    }
  }

  int get weight {
    switch (this) {
      case PriorityLevel.low:
        return 1;
      case PriorityLevel.medium:
        return 2;
      case PriorityLevel.high:
        return 3;
      case PriorityLevel.urgent:
        return 4;
    }
  }
}
