import 'package:flutter/material.dart';

/// Stylized empty state placeholder when no tasks exist or match search criteria.
class EmptyStateWidget extends StatelessWidget {
  final bool isSearch;
  final VoidCallback? onClearFilters;

  const EmptyStateWidget({
    super.key,
    this.isSearch = false,
    this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.indigo.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSearch ? Icons.search_off_rounded : Icons.check_circle_outline_rounded,
                size: 64,
                color: isSearch ? Colors.orange : theme.primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isSearch ? 'No Tasks Found' : 'All Caught Up!',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSearch
                  ? 'Try adjusting your search terms or clearing active filters.'
                  : 'You have no tasks pending. Tap "+" below to add a new task!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            if (isSearch && onClearFilters != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onClearFilters,
                icon: const Icon(Icons.filter_alt_off_rounded),
                label: const Text('Clear Filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
