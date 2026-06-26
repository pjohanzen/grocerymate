import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/list_item.dart';
import '../utils/currency_formatter.dart';
import '../utils/extensions.dart';

class ItemTile extends StatelessWidget {
  final ListItem item;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ItemTile({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.horizontal,
      background: _buildSwipeBackground(
        alignment: Alignment.centerLeft,
        color: AppTheme.success,
        icon: item.isCompleted ? Icons.undo : Icons.check,
        label: item.isCompleted ? 'Undo' : 'Done',
      ),
      secondaryBackground: _buildSwipeBackground(
        alignment: Alignment.centerRight,
        color: AppTheme.error,
        icon: Icons.delete_outline,
        label: 'Delete',
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onToggle();
          return false;
        } else {
          return true;
        }
      },
      onDismissed: (_) => onDelete(),
      child: AnimatedOpacity(
        opacity: item.isCompleted ? 0.5 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  // Checkbox
                  _buildCheckbox(isDark),
                  const SizedBox(width: 12),

                  // Item info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name + quantity
                        Row(
                          children: [
                            // Priority indicator
                            if (item.priority >= 2)
                              Container(
                                width: 6,
                                height: 6,
                                margin: const EdgeInsets.only(right: 6),
                                decoration: BoxDecoration(
                                  color: AppTheme.getPriorityColor(item.priority),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            Expanded(
                              child: Text(
                                item.name,
                                style: AppTheme.bodyLarge.copyWith(
                                  color: isDark
                                      ? AppTheme.darkTextPrimary
                                      : AppTheme.neutral900,
                                  decoration: item.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                  decorationColor: isDark
                                      ? AppTheme.darkTextSecondary
                                      : AppTheme.neutral400,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        // Quantity + unit + notes
                        Row(
                          children: [
                            Text(
                              '${item.quantity.displayQuantity} ${item.unit}',
                              style: AppTheme.caption.copyWith(
                                color: isDark
                                    ? AppTheme.darkTextSecondary
                                    : AppTheme.neutral500,
                              ),
                            ),
                            if (item.hasPrice) ...[
                              const SizedBox(width: 8),
                              Text(
                                CurrencyFormatter.formatUnitPrice(
                                    item.unitPrice!, item.unit),
                                style: AppTheme.caption.copyWith(
                                  color: isDark
                                      ? AppTheme.darkTextSecondary
                                      : AppTheme.neutral400,
                                ),
                              ),
                            ],
                            if (item.notes != null &&
                                item.notes!.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Icon(
                                Icons.sticky_note_2_outlined,
                                size: 12,
                                color: isDark
                                    ? AppTheme.darkTextSecondary
                                    : AppTheme.neutral400,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Estimated cost
                  if (item.hasPrice) ...[
                    const SizedBox(width: 8),
                    Text(
                      CurrencyFormatter.formatWhole(item.estimatedCost),
                      style: AppTheme.monoBold.copyWith(
                        fontSize: 14,
                        color: item.isCompleted
                            ? (isDark
                                ? AppTheme.darkTextSecondary
                                : AppTheme.neutral400)
                            : (isDark
                                ? AppTheme.darkTextPrimary
                                : AppTheme.neutral900),
                        decoration:
                            item.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ],

                  // Edit button
                  const SizedBox(width: 4),
                  IconButton(
                    icon: Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: isDark
                          ? AppTheme.darkTextSecondary
                          : AppTheme.neutral400,
                    ),
                    onPressed: onEdit,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: item.isCompleted
            ? AppTheme.primary
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: item.isCompleted
              ? AppTheme.primary
              : (isDark ? AppTheme.neutral600 : AppTheme.neutral400),
          width: 2,
        ),
      ),
      child: item.isCompleted
          ? const Icon(Icons.check, size: 16, color: Colors.white)
          : null,
    );
  }

  Widget _buildSwipeBackground({
    required Alignment alignment,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (alignment == Alignment.centerRight) ...[
            Text(label, style: AppTheme.label.copyWith(color: color)),
            const SizedBox(width: 8),
          ],
          Icon(icon, color: color, size: 22),
          if (alignment == Alignment.centerLeft) ...[
            const SizedBox(width: 8),
            Text(label, style: AppTheme.label.copyWith(color: color)),
          ],
        ],
      ),
    );
  }
}
