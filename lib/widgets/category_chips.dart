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
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    final chips = categories.map((cat) {
      final isSelected = selectedIds.contains(cat.id);
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: FilterChip(
          selected: isSelected,
          showCheckmark: false, // Cleaner Outfit look without the checkmark
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Category.getIconData(cat.icon),
                size: 15,
                color: isSelected
                    ? (isDark ? Colors.black : Colors.white)
                    : (isDark ? AppTheme.darkTextSecondary : AppTheme.neutral500),
              ),
              const SizedBox(width: 6),
              Text(cat.name),
            ],
          ),
          labelStyle: AppTheme.label.copyWith(
            color: isSelected
                ? (isDark ? Colors.black : Colors.white)
                : (isDark ? AppTheme.darkTextPrimary : AppTheme.neutral700),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          onSelected: (_) => onToggle(cat.id),
          selectedColor: primaryColor,
          backgroundColor: isDark ? AppTheme.darkSurfaceHigh : AppTheme.neutral200,
          side: BorderSide(
            color: isSelected
                ? primaryColor
                : (isDark ? AppTheme.darkBorder : AppTheme.neutral300),
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      );
    }).toList();

    if (scrollable) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(children: chips),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chips,
    );
  }
}
