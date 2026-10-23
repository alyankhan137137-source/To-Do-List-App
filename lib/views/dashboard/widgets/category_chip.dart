import 'package:flutter/material.dart';
import '../../../models/category_model.dart';

/// Horizontal category selection chip widget.
class CategoryChip extends StatelessWidget {
  final TaskCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isSelected
        ? category.color
        : (isDark ? Colors.grey.shade800 : Colors.grey.shade200);

    final textColor = isSelected
        ? Colors.white
        : (isDark ? Colors.grey.shade300 : Colors.grey.shade800);

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        selected: isSelected,
        showCheckmark: false,
        avatar: Icon(
          category.icon,
          size: 16,
          color: isSelected ? Colors.white : category.color,
        ),
        label: Text(
          category.title,
          style: TextStyle(
            color: textColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
        backgroundColor: backgroundColor,
        selectedColor: category.color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide.none,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        onSelected: (_) => onTap(),
      ),
    );
  }
}
