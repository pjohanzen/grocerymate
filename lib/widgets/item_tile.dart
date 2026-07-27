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
    final theme = Theme.of(context);

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.horizontal,
      background: _buildSwipeBackground(
        alignment: Alignment.centerLeft,
        color: theme.colorScheme.primary,
        icon: item.isCompleted ? Icons.undo_rounded : Icons.check_circle_rounded,
        label: item.isCompleted ? 'Undo' : 'Done',
      ),
      secondaryBackground: _buildSwipeBackground(
        alignment: Alignment.centerRight,
        color: theme.colorScheme.error,
        icon: Icons.delete_sweep_rounded,
        label: 'Delete',
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onToggle();
          return false;
        } else {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Delete Item?'),
              content: Text('Remove "${item.name}" from this list?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Delete'),
                ),
              ],
            ),
          );
          return confirmed ?? false;
        }
      },
      onDismissed: (_) => onDelete(),
      child: AnimatedOpacity(
        opacity: item.isCompleted ? 0.6 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurfaceElevated : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppTheme.darkBorder : AppTheme.neutral200,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 12, 12, 12),
                child: Row(
                  children: [
                    // Checkbox with dedicated hit target
                    GestureDetector(
                      onTap: onToggle,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: _buildCheckbox(context, isDark),
                      ),
                    ),
                    const SizedBox(width: 4),

                    // Item information
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (item.priority >= 2)
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.getPriorityColor(item.priority),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: AppTheme.bodyLarge.copyWith(
                                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.neutral900,
                                    fontWeight: item.isCompleted ? FontWeight.w400 : FontWeight.w600,
                                    decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                                    decorationColor: isDark ? AppTheme.darkTextSecondary : AppTheme.neutral400,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Quantity + Unit + Notes
                          Row(
                            children: [
                              Text(
                                '${item.quantity.displayQuantity} ${item.unit}',
                                style: AppTheme.caption.copyWith(
                                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.neutral500,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (item.hasPrice) ...[
                                const SizedBox(width: 8),
                                Container(
                                  width: 3,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: isDark ? AppTheme.neutral600 : AppTheme.neutral300,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  CurrencyFormatter.formatUnitPrice(item.unitPrice!, item.unit),
                                  style: AppTheme.caption.copyWith(
                                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.neutral400,
                                  ),
                                ),
                              ],
                              if (item.notes != null && item.notes!.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.notes_rounded,
                                  size: 13,
                                  color: isDark ? AppTheme.darkTextSecondary.withValues(alpha: 0.6) : AppTheme.neutral400,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Estimated cost display
                    if (item.hasPrice) ...[
                      const SizedBox(width: 8),
                      Text(
                        CurrencyFormatter.formatWhole(item.estimatedCost),
                        style: AppTheme.monoBold.copyWith(
                          fontSize: 14,
                          color: item.isCompleted
                              ? (isDark ? AppTheme.darkTextSecondary : AppTheme.neutral400)
                              : (isDark ? AppTheme.darkTextPrimary : AppTheme.neutral900),
                          decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ],

                    // Edit button
                    const SizedBox(width: 6),
                    IconButton(
                      icon: Icon(
                        Icons.edit_note_rounded,
                        size: 20,
                        color: isDark ? AppTheme.darkTextSecondary.withValues(alpha: 0.8) : AppTheme.neutral400,
                      ),
                      onPressed: onEdit,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: item.isCompleted ? primaryColor : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: item.isCompleted ? primaryColor : (isDark ? AppTheme.neutral600 : AppTheme.neutral400),
          width: 1.5,
        ),
      ),
      child: item.isCompleted
          ? Icon(Icons.check_rounded, size: 14, color: isDark ? Colors.black : Colors.white)
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (alignment == Alignment.centerRight) ...[
            Text(label, style: AppTheme.label.copyWith(color: color, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
          ],
          Icon(icon, color: color, size: 20),
          if (alignment == Alignment.centerLeft) ...[
            const SizedBox(width: 8),
            Text(label, style: AppTheme.label.copyWith(color: color, fontWeight: FontWeight.bold)),
          ],
        ],
      ),
    );
  }
}
