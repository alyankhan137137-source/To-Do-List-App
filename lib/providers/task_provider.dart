import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../core/utils/date_formatter.dart';
import '../core/utils/storage_service.dart';
import '../models/priority_enum.dart';
import '../models/sub_task_model.dart';
import '../models/task_model.dart';

enum TaskStatusFilter { all, active, completed }

enum TaskSortOption { dueDate, priority, title, createdAt }

/// Central state management for task CRUD operations, persistence, search, filtering, and sorting.
class TaskProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();

  List<TaskModel> _tasks = [];
  bool _isLoading = true;

  // Search & Filter State
  String _searchQuery = '';
  TaskStatusFilter _statusFilter = TaskStatusFilter.all;
  String _selectedCategoryId = 'all';
  PriorityLevel? _selectedPriority;
  TaskSortOption _sortOption = TaskSortOption.dueDate;

  // Undo support
  TaskModel? _lastDeletedTask;
  int? _lastDeletedIndex;

  // Getters
  bool get isLoading => _isLoading;
  List<TaskModel> get allTasks => List.unmodifiable(_tasks);
  String get searchQuery => _searchQuery;
  TaskStatusFilter get statusFilter => _statusFilter;
  String get selectedCategoryId => _selectedCategoryId;
  PriorityLevel? get selectedPriority => _selectedPriority;
  TaskSortOption get sortOption => _sortOption;
  bool get canUndo => _lastDeletedTask != null;

  TaskProvider() {
    loadTasksFromStorage();
  }

  // --- PERSISTENCE ---

  /// Loads stored tasks from SharedPreferences
  Future<void> loadTasksFromStorage() async {
    _isLoading = true;
    notifyListeners();
    try {
      final jsonList = await _storageService.loadTasksJson();
      if (jsonList.isNotEmpty) {
        _tasks = jsonList.map((jsonStr) => TaskModel.fromJson(jsonStr)).toList();
      } else {
        // Provide demo sample tasks for initial app launch
        _tasks = _getInitialSampleTasks();
        await _persistTasks();
      }
    } catch (e) {
      debugPrint('Error loading tasks: $e');
      _tasks = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _persistTasks() async {
    final jsonList = _tasks.map((task) => task.toJson()).toList();
    await _storageService.saveTasksJson(jsonList);
  }

  // --- FILTERED & SORTED TASKS ---

  List<TaskModel> get filteredTasks {
    return _tasks.where((task) {
      // 1. Text Search Filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesTitle = task.title.toLowerCase().contains(query);
        final matchesDesc = task.description.toLowerCase().contains(query);
        if (!matchesTitle && !matchesDesc) return false;
      }

      // 2. Status Filter
      if (_statusFilter == TaskStatusFilter.active && task.isCompleted) return false;
      if (_statusFilter == TaskStatusFilter.completed && !task.isCompleted) return false;

      // 3. Category Filter
      if (_selectedCategoryId != 'all' && task.categoryId != _selectedCategoryId) return false;

      // 4. Priority Filter
      if (_selectedPriority != null && task.priority != _selectedPriority) return false;

      return true;
    }).toList()
      ..sort((a, b) {
        switch (_sortOption) {
          case TaskSortOption.dueDate:
            if (a.dueDate == null && b.dueDate == null) return 0;
            if (a.dueDate == null) return 1;
            if (b.dueDate == null) return -1;
            return a.dueDate!.compareTo(b.dueDate!);
          case TaskSortOption.priority:
            return b.priority.weight.compareTo(a.priority.weight);
          case TaskSortOption.title:
            return a.title.toLowerCase().compareTo(b.title.toLowerCase());
          case TaskSortOption.createdAt:
            return b.createdAt.compareTo(a.createdAt);
        }
      });
  }

  // --- STATS & COMPUTED VALUES ---

  int get totalTasksCount => _tasks.length;
  int get activeTasksCount => _tasks.where((t) => !t.isCompleted).length;
  int get completedTasksCount => _tasks.where((t) => t.isCompleted).length;
  int get overdueTasksCount => _tasks.where((t) => DateFormatter.isOverdue(t.dueDate, t.isCompleted)).length;

  double get completionPercentage {
    if (_tasks.isEmpty) return 0.0;
    return completedTasksCount / totalTasksCount;
  }

  // --- CRUD OPERATIONS ---

  /// Adds a new task
  Future<void> addTask(TaskModel task) async {
    _tasks.insert(0, task);
    notifyListeners();
    await _persistTasks();
  }

  /// Updates an existing task
  Future<void> updateTask(TaskModel updatedTask) async {
    final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      notifyListeners();
      await _persistTasks();
    }
  }

  /// Deletes a task by ID with undo backup
  Future<void> deleteTask(String taskId) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _lastDeletedTask = _tasks[index];
      _lastDeletedIndex = index;
      _tasks.removeAt(index);
      notifyListeners();
      await _persistTasks();
    }
  }

  /// Restores the last deleted task
  Future<void> restoreLastDeletedTask() async {
    if (_lastDeletedTask != null) {
      if (_lastDeletedIndex != null && _lastDeletedIndex! <= _tasks.length) {
        _tasks.insert(_lastDeletedIndex!, _lastDeletedTask!);
      } else {
        _tasks.add(_lastDeletedTask!);
      }
      _lastDeletedTask = null;
      _lastDeletedIndex = null;
      notifyListeners();
      await _persistTasks();
    }
  }

  /// Toggles completion status of a task
  Future<void> toggleTaskCompletion(String taskId) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final currentTask = _tasks[index];
      final newStatus = !currentTask.isCompleted;

      // If completing main task, optionally complete all sub-tasks as well
      final updatedSubTasks = currentTask.subTasks.map((st) {
        return st.copyWith(isCompleted: newStatus);
      }).toList();

      _tasks[index] = currentTask.copyWith(
        isCompleted: newStatus,
        subTasks: updatedSubTasks,
      );
      notifyListeners();
      await _persistTasks();
    }
  }

  // --- SUB-TASKS CONTROLLER ---

  /// Toggles sub-task status
  Future<void> toggleSubTask(String taskId, String subTaskId) async {
    final taskIndex = _tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex != -1) {
      final task = _tasks[taskIndex];
      final updatedSubTasks = task.subTasks.map((st) {
        if (st.id == subTaskId) {
          return st.copyWith(isCompleted: !st.isCompleted);
        }
        return st;
      }).toList();

      final allSubTasksCompleted = updatedSubTasks.isNotEmpty && updatedSubTasks.every((st) => st.isCompleted);

      _tasks[taskIndex] = task.copyWith(
        subTasks: updatedSubTasks,
        isCompleted: allSubTasksCompleted ? true : task.isCompleted,
      );
      notifyListeners();
      await _persistTasks();
    }
  }

  // --- SEARCH & FILTER SETTERS ---

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setStatusFilter(TaskStatusFilter filter) {
    _statusFilter = filter;
    notifyListeners();
  }

  void setCategoryFilter(String categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void setPriorityFilter(PriorityLevel? priority) {
    _selectedPriority = priority;
    notifyListeners();
  }

  void setSortOption(TaskSortOption sortOption) {
    _sortOption = sortOption;
    notifyListeners();
  }

  void clearAllFilters() {
    _searchQuery = '';
    _statusFilter = TaskStatusFilter.all;
    _selectedCategoryId = 'all';
    _selectedPriority = null;
    _sortOption = TaskSortOption.dueDate;
    notifyListeners();
  }

  // --- DATA MANAGEMENT ---

  /// Clears all completed tasks
  Future<void> clearCompletedTasks() async {
    _tasks.removeWhere((t) => t.isCompleted);
    notifyListeners();
    await _persistTasks();
  }

  /// Clears all tasks completely
  Future<void> clearAllData() async {
    _tasks.clear();
    _lastDeletedTask = null;
    notifyListeners();
    await _storageService.clearTasks();
  }

  /// Exports tasks as formatted JSON string
  String exportTasksToJson() {
    final list = _tasks.map((t) => t.toMap()).toList();
    return const JsonEncoder.withIndent('  ').convert(list);
  }

  /// Imports tasks from JSON string
  Future<bool> importTasksFromJson(String jsonStr) async {
    try {
      final dynamic parsed = json.decode(jsonStr);
      if (parsed is List) {
        final List<TaskModel> imported = parsed.map((map) => TaskModel.fromMap(map)).toList();
        _tasks = imported;
        notifyListeners();
        await _persistTasks();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error importing JSON: $e');
      return false;
    }
  }

  // Initial demo items for clean first launch
  List<TaskModel> _getInitialSampleTasks() {
    final now = DateTime.now();
    return [
      TaskModel(
        id: '1',
        title: 'Design To-Do List Mobile App',
        description: 'Create modern wireframes and color scheme using Flutter Material 3.',
        isCompleted: true,
        priority: PriorityLevel.urgent,
        categoryId: 'work',
        dueDate: now.subtract(const Duration(hours: 2)),
        createdAt: now.subtract(const Duration(days: 1)),
        subTasks: [
          SubTask(id: 'st1', title: 'Sketch Dashboard UI', isCompleted: true),
          SubTask(id: 'st2', title: 'Define Task Model', isCompleted: true),
        ],
      ),
      TaskModel(
        id: '2',
        title: 'Weekly Grocery Shopping',
        description: 'Buy organic vegetables, fruits, almond milk, and whole wheat bread.',
        isCompleted: false,
        priority: PriorityLevel.high,
        categoryId: 'shopping',
        dueDate: now.add(const Duration(hours: 5)),
        createdAt: now,
        subTasks: [
          SubTask(id: 'st3', title: 'Avocados & Spinach', isCompleted: true),
          SubTask(id: 'st4', title: 'Almond Milk', isCompleted: false),
          SubTask(id: 'st5', title: 'Oatmeal & Honey', isCompleted: false),
        ],
      ),
      TaskModel(
        id: '3',
        title: 'Evening Fitness Workout',
        description: '45-minute cardio training followed by stretching exercises.',
        isCompleted: false,
        priority: PriorityLevel.medium,
        categoryId: 'fitness',
        dueDate: now.add(const Duration(days: 1)),
        createdAt: now,
      ),
      TaskModel(
        id: '4',
        title: 'Read 2 Chapters of Clean Architecture',
        description: 'Focus on dependency rule and software entity boundaries.',
        isCompleted: false,
        priority: PriorityLevel.low,
        categoryId: 'education',
        dueDate: now.add(const Duration(days: 3)),
        createdAt: now,
      ),
    ];
  }
}
