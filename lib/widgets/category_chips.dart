import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/category.dart';

class CategoryChips extends StatelessWidget {
  final List<Category> categories;
  final List<String> selectedIds;
  final ValueChanged<String> onToggle;
  final bool scrollable;

  const CategoryChips({
    super.key,
    required this.categories,
    required this.selectedIds,
    required this.onToggle,
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final chips = categories.map((cat) {
      final isSelected = selectedIds.contains(cat.id);
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: FilterChip(
          selected: isSelected,
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Category.getIconData(cat.icon),
                size: 16,
                color: isSelected
                    ? AppTheme.primary
                    : (isDark ? AppTheme.darkTextSecondary : AppTheme.neutral500),
              ),
              const SizedBox(width: 6),
              Text(cat.name),
            ],
          ),
          labelStyle: AppTheme.label.copyWith(
            color: isSelected
                ? AppTheme.primary
                : (isDark ? AppTheme.darkTextPrimary : AppTheme.neutral700),
          ),
          onSelected: (_) => onToggle(cat.id),
          selectedColor: isDark
              ? AppTheme.primaryLight.withValues(alpha: 0.25)
              : AppTheme.primary.withValues(alpha: 0.12),
          checkmarkColor: AppTheme.primary,
          backgroundColor: isDark ? AppTheme.darkSurfaceHigh : AppTheme.neutral200,
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      );
    }).toList();

    if (scrollable) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: chips),
      );
    }

    return Wrap(
      spacing: 0,
      runSpacing: 8,
      children: chips,
    );
  }
}
