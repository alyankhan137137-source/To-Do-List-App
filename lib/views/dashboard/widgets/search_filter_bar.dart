import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/priority_enum.dart';
import '../../../providers/task_provider.dart';

/// Search input bar with sorting and filter trigger options.
class SearchFilterBar extends StatefulWidget {
  const SearchFilterBar({super.key});

  @override
  State<SearchFilterBar> createState() => _SearchFilterBarState();
}

class _SearchFilterBarState extends State<SearchFilterBar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) => provider.setSearchQuery(value),
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          provider.setSearchQuery('');
                        },
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => _showFilterBottomSheet(context, provider),
            tooltip: 'Filter & Sort',
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context, TaskProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter & Sort Tasks',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          provider.clearAllFilters();
                          _searchController.clear();
                          Navigator.pop(ctx);
                        },
                        child: const Text('Reset All'),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Status Filter
                  const Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  SegmentedButton<TaskStatusFilter>(
                    segments: const [
                      ButtonSegment(value: TaskStatusFilter.all, label: Text('All')),
                      ButtonSegment(value: TaskStatusFilter.active, label: Text('Pending')),
                      ButtonSegment(value: TaskStatusFilter.completed, label: Text('Completed')),
                    ],
                    selected: {provider.statusFilter},
                    onSelectionChanged: (set) {
                      provider.setStatusFilter(set.first);
                      setModalState(() {});
                    },
                  ),

                  const SizedBox(height: 20),

                  // Priority Filter
                  const Text('Priority', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('All'),
                        selected: provider.selectedPriority == null,
                        onSelected: (_) {
                          provider.setPriorityFilter(null);
                          setModalState(() {});
                        },
                      ),
                      ...PriorityLevel.values.map(
                        (p) => ChoiceChip(
                          label: Text(p.label),
                          selected: provider.selectedPriority == p,
                          selectedColor: p.color.withValues(alpha: 0.2),
                          onSelected: (_) {
                            provider.setPriorityFilter(p);
                            setModalState(() {});
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Sort Options
                  const Text('Sort By', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<TaskSortOption>(
                    initialValue: provider.sortOption,
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
                    items: const [
                      DropdownMenuItem(value: TaskSortOption.dueDate, child: Text('Due Date')),
                      DropdownMenuItem(value: TaskSortOption.priority, child: Text('Priority Level')),
                      DropdownMenuItem(value: TaskSortOption.title, child: Text('Title (A-Z)')),
                      DropdownMenuItem(value: TaskSortOption.createdAt, child: Text('Creation Date')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        provider.setSortOption(value);
                        setModalState(() {});
                      }
                    },
                  ),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
