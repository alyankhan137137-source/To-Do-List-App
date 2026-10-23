import 'package:shared_preferences/shared_preferences.dart';

/// Service wrapper around SharedPreferences for local task data persistence.
class StorageService {
  static const String _tasksKey = 'user_tasks_list';

  /// Saves raw JSON string list of tasks to SharedPreferences
  Future<bool> saveTasksJson(List<String> tasksJsonList) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setStringList(_tasksKey, tasksJsonList);
  }

  /// Loads raw JSON string list of tasks from SharedPreferences
  Future<List<String>> loadTasksJson() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_tasksKey) ?? [];
  }

  /// Clears all tasks stored locally
  Future<bool> clearTasks() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(_tasksKey);
  }
}
