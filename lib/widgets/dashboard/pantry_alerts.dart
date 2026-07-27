import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/analytics_service.dart';

class PantryAlertsCard extends StatelessWidget {
  final PantryHealthStats stats;
  final VoidCallback onViewPantry;

  const PantryAlertsCard({
    super.key,
    required this.stats,
    required this.onViewPantry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Choose status color based on health index
    Color healthColor = AppTheme.success;
    if (stats.healthPercentage < 50) {
      healthColor = AppTheme.error;
    } else if (stats.healthPercentage < 85) {
      healthColor = AppTheme.warning;
    }

    final hasAlerts = stats.lowStockCount > 0 || stats.outOfStockCount > 0;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurfaceElevated : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.neutral300,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    hasAlerts ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded,
                    color: hasAlerts ? AppTheme.warning : AppTheme.success,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Pantry Alert Stock',
                    style: AppTheme.headline3.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.neutral900,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: healthColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${stats.healthPercentage.toStringAsFixed(0)}% Healthy',
                  style: AppTheme.caption.copyWith(
                    color: healthColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (!hasAlerts)
            Text(
              'All items in your pantry are adequately stocked!',
              style: AppTheme.bodyRegular.copyWith(
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.neutral600,
                fontSize: 13,
              ),
            )
          else ...[
            Text(
              '${stats.outOfStockCount} out of stock • ${stats.lowStockCount} running low',
              style: AppTheme.bodyRegular.copyWith(
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.neutral700,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: stats.alertItemNames.take(4).map((name) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkSurfaceHigh : AppTheme.neutral200,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.error.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppTheme.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        name,
                        style: AppTheme.caption.copyWith(
                          color: isDark ? AppTheme.darkTextPrimary : AppTheme.neutral800,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList()
                ..addAll(
                  stats.alertItemNames.length > 4
                      ? [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                            decoration: BoxDecoration(
                              color: isDark ? AppTheme.darkSurfaceHigh : AppTheme.neutral200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '+${stats.alertItemNames.length - 4} more',
                              style: AppTheme.caption.copyWith(
                                color: isDark ? AppTheme.darkTextSecondary : AppTheme.neutral600,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ]
                      : [],
                ),
            ),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: AppTheme.label.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            onPressed: onViewPantry,
            child: const Text('Manage Pantry Inventory'),
          ),
        ],
      ),
    );
  }
}
