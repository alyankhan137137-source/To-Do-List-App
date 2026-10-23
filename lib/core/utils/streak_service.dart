import 'package:shared_preferences/shared_preferences.dart';

/// Helper for tracking and calculating daily task completion habit streaks.
class StreakService {
  static const String _streakKey = 'user_daily_streak_count';
  static const String _lastDateKey = 'user_last_completed_date';

  /// Loads current daily habit streak count
  Future<int> getStreakCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_streakKey) ?? 0;
  }

  /// Updates streak count when tasks are completed today
  Future<int> checkAndUpdateStreak(bool hasCompletedTasksToday) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month}-${now.day}";
    final lastCompletedStr = prefs.getString(_lastDateKey);
    int currentStreak = prefs.getInt(_streakKey) ?? 0;

    if (!hasCompletedTasksToday) return currentStreak;

    if (lastCompletedStr == null) {
      currentStreak = 1;
      await prefs.setInt(_streakKey, currentStreak);
      await prefs.setString(_lastDateKey, todayStr);
    } else {
      final lastDate = DateTime.parse(lastCompletedStr);
      final difference = DateTime(now.year, now.month, now.day)
          .difference(DateTime(lastDate.year, lastDate.month, lastDate.day))
          .inDays;

      if (difference == 1) {
        currentStreak += 1;
        await prefs.setInt(_streakKey, currentStreak);
        await prefs.setString(_lastDateKey, todayStr);
      } else if (difference > 1) {
        currentStreak = 1;
        await prefs.setInt(_streakKey, currentStreak);
        await prefs.setString(_lastDateKey, todayStr);
      }
    }

    return currentStreak;
  }
}
