import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme_provider.dart';
import '../../providers/task_provider.dart';

/// Settings & Data Management Screen.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Data'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Theme Settings Section
          _buildSectionTitle(context, 'Appearance'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.brightness_medium_rounded),
                  title: const Text('App Theme'),
                  subtitle: Text(_getThemeModeName(themeProvider.themeMode)),
                  trailing: DropdownButton<ThemeMode>(
                    value: themeProvider.themeMode,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: ThemeMode.system, child: Text('System Default')),
                      DropdownMenuItem(value: ThemeMode.light, child: Text('Light Theme')),
                      DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark Theme')),
                    ],
                    onChanged: (mode) {
                      if (mode != null) themeProvider.setThemeMode(mode);
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Data Management Section
          _buildSectionTitle(context, 'Data Management'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.cleaning_services_rounded, color: Colors.amber),
                  title: const Text('Clear Completed Tasks'),
                  subtitle: Text('Remove ${taskProvider.completedTasksCount} finished items'),
                  onTap: () {
                    if (taskProvider.completedTasksCount == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No completed tasks to clear')),
                      );
                      return;
                    }
                    _showConfirmationDialog(
                      context,
                      title: 'Clear Completed Tasks',
                      message: 'Are you sure you want to delete all completed tasks?',
                      onConfirm: () => taskProvider.clearCompletedTasks(),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.download_rounded, color: Colors.blue),
                  title: const Text('Export Backup (JSON)'),
                  subtitle: const Text('Copy JSON task data to clipboard'),
                  onTap: () => _exportData(context, taskProvider),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.upload_rounded, color: Colors.green),
                  title: const Text('Import Backup (JSON)'),
                  subtitle: const Text('Restore tasks from a JSON payload'),
                  onTap: () => _importData(context, taskProvider),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_forever_rounded, color: Colors.red),
                  title: const Text('Reset All App Data', style: TextStyle(color: Colors.red)),
                  subtitle: const Text('Delete all tasks and reset local storage'),
                  onTap: () {
                    _showConfirmationDialog(
                      context,
                      title: 'Reset All Data',
                      message: 'This action is irreversible. Are you sure you want to clear all tasks?',
                      isDangerous: true,
                      onConfirm: () => taskProvider.clearAllData(),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // App Info
          _buildSectionTitle(context, 'About Application'),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: Color(0xFF6366F1),
                      child: Icon(Icons.check_rounded, color: Colors.white),
                    ),
                    title: Text('TaskFlow Pro', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Version 1.0.0 (Play Store Ready)'),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'TaskFlow Pro is a clean, feature-rich Flutter task management application with local offline persistence, priorities, categories, and sub-task checklists.',
                    style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  String _getThemeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System Default';
      case ThemeMode.light:
        return 'Light Theme Mode';
      case ThemeMode.dark:
        return 'Dark Theme Mode';
    }
  }

  void _exportData(BuildContext context, TaskProvider provider) {
    final jsonStr = provider.exportTasksToJson();
    Clipboard.setData(ClipboardData(text: jsonStr));

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Export Data JSON'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your task data JSON has been copied to your clipboard!'),
            const SizedBox(height: 12),
            Container(
              height: 120,
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  jsonStr,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _importData(BuildContext context, TaskProvider provider) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import Backup JSON'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Paste exported JSON payload here...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await provider.importTasksFromJson(controller.text.trim());
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Tasks imported successfully!' : 'Failed to parse JSON string'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
    bool isDangerous = false,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: isDangerous
                ? ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white)
                : null,
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Operation completed')),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
