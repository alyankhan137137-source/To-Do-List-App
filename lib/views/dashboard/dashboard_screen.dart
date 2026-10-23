import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme_provider.dart';
import '../../models/category_model.dart';
import '../../providers/task_provider.dart';
import '../settings/settings_screen.dart';
import 'widgets/add_edit_task_sheet.dart';
import 'widgets/analytics_sheet.dart';
import 'widgets/category_chip.dart';
import 'widgets/celebration_dialog.dart';
import 'widgets/eisenhower_matrix_view.dart';
import 'widgets/empty_state_widget.dart';
import 'widgets/motivational_quote_card.dart';
import 'widgets/pomodoro_timer_sheet.dart';
import 'widgets/progress_card.dart';
import 'widgets/search_filter_bar.dart';
import 'widgets/task_card.dart';
import 'widgets/task_detail_sheet.dart';
import 'widgets/templates_sheet.dart';

/// Main Dashboard Screen supporting celebration overlays, view mode toggling, templates, pomodoro, and analytics.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isEisenhowerView = false;

  void _checkCelebration(TaskProvider provider) {
    if (provider.shouldTriggerCelebration) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CelebrationDialog.show(context, streakCount: provider.streakCount);
        provider.resetCelebrationTrigger();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Consumer<TaskProvider>(
      builder: (context, provider, child) {
        _checkCelebration(provider);

        if (provider.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final filteredTasks = provider.filteredTasks;
        final isSearching = provider.searchQuery.isNotEmpty ||
            provider.statusFilter != TaskStatusFilter.all ||
            provider.selectedCategoryId != 'all' ||
            provider.selectedPriority != null;

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: themeProvider.primaryColor, size: 28),
                const SizedBox(width: 8),
                const Text(
                  'TaskFlow Pro',
                  style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ],
            ),
            actions: [
              // Habit Streak Badge
              if (provider.streakCount > 0)
                Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text(
                        '${provider.streakCount}',
                        style: TextStyle(
                          color: Colors.orange.shade900,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

              // Theme Switcher
              IconButton(
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                ),
                tooltip: 'Toggle Theme Mode',
                onPressed: () => themeProvider.toggleTheme(),
              ),

              // Settings
              IconButton(
                icon: const Icon(Icons.settings_rounded),
                tooltip: 'Settings & Color Customization',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Motivational Quote Banner
                const MotivationalQuoteCard(),

                // Top Progress Summary Header Card
                const ProgressCard(),

                // Quick Tools Action Row (Templates, Pomodoro, Analytics, Matrix Toggle)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.auto_awesome_rounded, size: 16, color: Colors.purple),
                        label: const Text('Templates', style: TextStyle(fontSize: 12)),
                        onPressed: () => _showSheet(context, const TemplatesSheet()),
                      ),
                      const SizedBox(width: 6),
                      ActionChip(
                        avatar: const Icon(Icons.timer_rounded, size: 16, color: Colors.deepOrange),
                        label: const Text('Pomodoro', style: TextStyle(fontSize: 12)),
                        onPressed: () => _showSheet(context, const PomodoroTimerSheet()),
                      ),
                      const SizedBox(width: 6),
                      ActionChip(
                        avatar: const Icon(Icons.insights_rounded, size: 16, color: Colors.blueAccent),
                        label: const Text('Analytics', style: TextStyle(fontSize: 12)),
                        onPressed: () => _showSheet(context, const AnalyticsSheet()),
                      ),
                      const SizedBox(width: 6),
                      FilterChip(
                        selected: _isEisenhowerView,
                        avatar: Icon(
                          _isEisenhowerView ? Icons.view_compact_rounded : Icons.grid_view_rounded,
                          size: 16,
                          color: _isEisenhowerView ? Colors.white : themeProvider.primaryColor,
                        ),
                        label: Text(_isEisenhowerView ? 'Matrix View' : 'List View', style: const TextStyle(fontSize: 12)),
                        onSelected: (selected) {
                          setState(() => _isEisenhowerView = selected);
                        },
                      ),
                    ],
                  ),
                ),

                // Search Bar
                const SearchFilterBar(),

                // Category Horizontal Filter List
                if (!_isEisenhowerView)
                  SizedBox(
                    height: 44,
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

                const SizedBox(height: 8),

                // Section Header Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isEisenhowerView ? 'Eisenhower Priority Matrix' : 'Tasks (${filteredTasks.length})',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    if (isSearching && !_isEisenhowerView)
                      TextButton.icon(
                        onPressed: () => provider.clearAllFilters(),
                        icon: const Icon(Icons.clear_all_rounded, size: 16),
                        label: const Text('Clear Filters', style: TextStyle(fontSize: 12)),
                      ),
                  ],
                ),

                const SizedBox(height: 6),

                // Main Content View (Eisenhower Matrix vs Standard List)
                Expanded(
                  child: _isEisenhowerView
                      ? const EisenhowerMatrixView()
                      : (filteredTasks.isEmpty
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
                                      _showSheet(context, TaskDetailSheet(taskId: task.id));
                                    },
                                    onEdit: () {
                                      _showSheet(context, AddEditTaskSheet(existingTask: task));
                                    },
                                  );
                                },
                              ),
                            )),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showSheet(context, const AddEditTaskSheet()),
            icon: const Icon(Icons.add_rounded),
            label: const Text('New Task', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }

  void _showSheet(BuildContext context, Widget sheet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => sheet,
    );
  }
}
