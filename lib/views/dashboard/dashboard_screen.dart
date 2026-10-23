import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme_provider.dart';
import '../../models/category_model.dart';
import '../../providers/task_provider.dart';
import '../settings/settings_screen.dart';
import 'widgets/add_edit_task_sheet.dart';
import 'widgets/category_chip.dart';
import 'widgets/empty_state_widget.dart';
import 'widgets/progress_card.dart';
import 'widgets/search_filter_bar.dart';
import 'widgets/task_card.dart';
import 'widgets/task_detail_sheet.dart';

/// Main Dashboard Screen featuring progress card, category filtering, search, and task list.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Color(0xFF6366F1), size: 28),
            SizedBox(width: 10),
            Text(
              'TaskFlow Pro',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
          ],
        ),
        actions: [
          // Theme Toggle
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.wb_sunny_rounded : Icons.nightlight_round,
            ),
            tooltip: 'Toggle Theme',
            onPressed: () => themeProvider.toggleTheme(),
          ),
          // Settings Screen
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            tooltip: 'Settings & Data',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final filteredTasks = provider.filteredTasks;
          final isSearching = provider.searchQuery.isNotEmpty ||
              provider.statusFilter != TaskStatusFilter.all ||
              provider.selectedCategoryId != 'all' ||
              provider.selectedPriority != null;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Progress Summary Card
                const ProgressCard(),

                // Search Bar
                const SearchFilterBar(),

                // Category Horizontal Filter List
                SizedBox(
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: TaskCategory.defaultCategories.length,
                    itemBuilder: (context, index) {
                      final category = TaskCategory.defaultCategories[index];
                      final isSelected = provider.selectedCategoryId == category.id;
                      return CategoryChip(
                        category: category,
                        isSelected: isSelected,
                        onTap: () => provider.setCategoryFilter(category.id),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // Task List Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tasks (${filteredTasks.length})',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    if (isSearching)
                      TextButton.icon(
                        onPressed: () => provider.clearAllFilters(),
                        icon: const Icon(Icons.clear_all_rounded, size: 16),
                        label: const Text('Clear Filters', style: TextStyle(fontSize: 12)),
                      ),
                  ],
                ),

                const SizedBox(height: 6),

                // Main Tasks List or Empty State
                Expanded(
                  child: filteredTasks.isEmpty
                      ? EmptyStateWidget(
                          isSearch: isSearching,
                          onClearFilters: () => provider.clearAllFilters(),
                        )
                      : RefreshIndicator(
                          onRefresh: () => provider.loadTasksFromStorage(),
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 80),
                            itemCount: filteredTasks.length,
                            itemBuilder: (context, index) {
                              final task = filteredTasks[index];
                              return TaskCard(
                                task: task,
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
                                onEdit: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                                    ),
                                    builder: (_) => AddEditTaskSheet(existingTask: task),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (_) => const AddEditTaskSheet(),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Task', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
