import 'package:intl/intl.dart';

/// Utility class for formatting dates and calculating relative time labels.
class DateFormatter {
  /// Formats date into readable string like "Today, 5:00 PM", "Tomorrow", or "MMM d, yyyy"
  static String formatDueDate(DateTime? date) {
    if (date == null) return 'No Due Date';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    final difference = targetDate.difference(today).inDays;

    if (difference == 0) {
      return 'Today, ${DateFormat('h:mm a').format(date)}';
    } else if (difference == 1) {
      return 'Tomorrow, ${DateFormat('h:mm a').format(date)}';
    } else if (difference == -1) {
      return 'Yesterday (Overdue)';
    } else if (difference < -1) {
      return '${DateFormat('MMM d, yyyy').format(date)} (Overdue)';
    } else {
      return DateFormat('MMM d, yyyy - h:mm a').format(date);
    }
  }

  /// Formats short date (e.g. "Oct 24")
  static String formatShortDate(DateTime date) {
    return DateFormat('MMM d').format(date);
  }

  /// Checks if task is past due date and not completed
  static bool isOverdue(DateTime? date, bool isCompleted) {
    if (date == null || isCompleted) return false;
    return date.isBefore(DateTime.now());
  }

  /// Checks if date falls on today
  static bool isToday(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
}
