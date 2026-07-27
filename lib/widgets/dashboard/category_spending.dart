import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/theme.dart';
import '../../providers/dashboard_provider.dart';
import '../../services/analytics_service.dart';
import '../../utils/currency_formatter.dart';

class CategorySpendingCard extends ConsumerWidget {
  final List<CategorySpendingSlice> slices;

  const CategorySpendingCard({
    super.key,
    required this.slices,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tappedIndex = ref.watch(selectedDonutCategoryIndexProvider);

    // Calculate total spend across all slices
    final double totalAmount = slices.fold(0, (sum, slice) => sum + slice.amount);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurfaceElevated : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.neutral300,
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Category Spending',
            style: AppTheme.headline3.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.neutral900,
            ),
          ),
          const SizedBox(height: 18),
          
          // Row with Donut & Details
          Row(
            children: [
              // Left: Donut Chart
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: 150,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            return;
                          }
                          final idx = pieTouchResponse.touchedSection!.touchedSectionIndex;
                          // If tapping again, toggle off (null)
                          if (idx == tappedIndex) {
                            ref.read(selectedDonutCategoryIndexProvider.notifier).state = null;
                          } else {
                            ref.read(selectedDonutCategoryIndexProvider.notifier).state = idx;
                          }
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 3,
                      centerSpaceRadius: 40,
                      sections: List.generate(slices.length, (i) {
                        final isTouched = i == tappedIndex;
                        final radius = isTouched ? 26.0 : 18.0;
                        final slice = slices[i];
                        
                        return PieChartSectionData(
                          color: slice.color,
                          value: slice.amount,
                          title: '', // Keep title inside donut blank to look modern
                          radius: radius,
                        );
                      }),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Right: Tapped Category Detail / Total
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (tappedIndex == null || tappedIndex < 0 || tappedIndex >= slices.length) ...[
                      Text(
                        'Total Shopping',
                        style: AppTheme.caption.copyWith(
                          color: isDark ? AppTheme.darkTextSecondary : AppTheme.neutral500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        CurrencyFormatter.formatWhole(totalAmount),
                        style: AppTheme.headline2.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppTheme.darkTextPrimary : AppTheme.neutral900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap any segment to reveal category cost.',
                        style: AppTheme.caption.copyWith(
                          fontSize: 10,
                          color: isDark ? AppTheme.darkTextSecondary.withValues(alpha: 0.6) : AppTheme.neutral500,
                        ),
                      ),
                    ] else ...[
                      // Specific Category Selected
                      Row(
                        children: [
                          Icon(
                            slices[tappedIndex].icon,
                            color: slices[tappedIndex].color,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              slices[tappedIndex].categoryName,
                              style: AppTheme.bodyRegular.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppTheme.darkTextPrimary : AppTheme.neutral900,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.formatWhole(slices[tappedIndex].amount),
                        style: AppTheme.monoBold.copyWith(
                          fontSize: 18,
                          color: slices[tappedIndex].color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${(slices[tappedIndex].percentage * 100).toStringAsFixed(1)}% of spending',
                        style: AppTheme.caption.copyWith(
                          color: isDark ? AppTheme.darkTextSecondary : AppTheme.neutral600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Dynamic category legend list
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: slices.take(5).map((slice) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: slice.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    slice.categoryName,
                    style: AppTheme.caption.copyWith(
                      fontSize: 10,
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.neutral600,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
