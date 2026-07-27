import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../utils/currency_formatter.dart';

class ShoppingStreakCard extends StatelessWidget {
  final int streakWeeks;
  final int completedListsCount;
  final double moneySaved;
  final double completionRate;

  const ShoppingStreakCard({
    super.key,
    required this.streakWeeks,
    required this.completedListsCount,
    required this.moneySaved,
    required this.completionRate,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppTheme.secondaryDark.withValues(alpha: 0.15), AppTheme.darkSurfaceElevated]
              : [AppTheme.secondary.withValues(alpha: 0.08), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
            children: [
              const Text(
                'Shopping Streak',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.local_fire_department_rounded,
                color: AppTheme.secondaryDark,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStreakMetric(
                  label: 'Under Budget',
                  value: '$streakWeeks weeks 🔥',
                  isDark: isDark,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: isDark ? AppTheme.darkBorder : AppTheme.neutral250,
              ),
              Expanded(
                child: _buildStreakMetric(
                  label: 'Completed',
                  value: '$completedListsCount lists',
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildStreakMetric(
                  label: 'Money Saved',
                  value: CurrencyFormatter.formatWhole(moneySaved),
                  isDark: isDark,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: isDark ? AppTheme.darkBorder : AppTheme.neutral250,
              ),
              Expanded(
                child: _buildStreakMetric(
                  label: 'Completion Rate',
                  value: '${completionRate.toStringAsFixed(0)}%',
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreakMetric({
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: AppTheme.caption.copyWith(
            fontSize: 11,
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.neutral500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTheme.monoBold.copyWith(
            fontSize: 14,
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.neutral900,
          ),
        ),
      ],
    );
  }
}
