import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/theme.dart';
import '../../services/analytics_service.dart';
import '../../utils/currency_formatter.dart';

class MonthlyAnalyticsCard extends StatefulWidget {
  final List<SpendingPoint> monthlySpending;
  final List<SpendingPoint> weeklySpending;
  final double averageTripCost;
  final double mostExpensiveTrip;
  final double moneySaved;
  final double averageItemCost;

  const MonthlyAnalyticsCard({
    super.key,
    required this.monthlySpending,
    required this.weeklySpending,
    required this.averageTripCost,
    required this.mostExpensiveTrip,
    required this.moneySaved,
    required this.averageItemCost,
  });

  @override
  State<MonthlyAnalyticsCard> createState() => _MonthlyAnalyticsCardState();
}

class _MonthlyAnalyticsCardState extends State<MonthlyAnalyticsCard> {
  bool _showWeekly = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentDataPoints = _showWeekly ? widget.weeklySpending : widget.monthlySpending;

    // Convert spending points to FlSpots
    final List<FlSpot> spots = [];
    double maxAmount = 1000.0;
    for (int i = 0; i < currentDataPoints.length; i++) {
      final amt = currentDataPoints[i].amount;
      spots.add(FlSpot(i.toDouble(), amt));
      if (amt > maxAmount) {
        maxAmount = amt;
      }
    }

    // Add extra padding to chart top boundary
    maxAmount = maxAmount * 1.15;

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
          // Header with Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Spending Trends',
                    style: AppTheme.headline3.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.neutral900,
                    ),
                  ),
                  Text(
                    _showWeekly ? 'Last 4 Weeks' : 'Historical Months',
                    style: AppTheme.caption.copyWith(
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.neutral500,
                    ),
                  ),
                ],
              ),
              // Selector Toggle
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurfaceHigh : AppTheme.neutral200,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(2),
                child: Row(
                  children: [
                    _buildToggleButton(
                      label: 'Monthly',
                      isActive: !_showWeekly,
                      isDark: isDark,
                      onTap: () => setState(() => _showWeekly = false),
                    ),
                    _buildToggleButton(
                      label: 'Weekly',
                      isActive: _showWeekly,
                      isDark: isDark,
                      onTap: () => setState(() => _showWeekly = true),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // LINE CHART VIEWPORT
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: isDark ? AppTheme.darkBorder.withValues(alpha: 0.5) : AppTheme.neutral200,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Text(
                            CurrencyFormatter.formatCompact(value),
                            style: AppTheme.monoRegular.copyWith(
                              fontSize: 9,
                              color: isDark ? AppTheme.darkTextSecondary : AppTheme.neutral500,
                            ),
                            textAlign: Alignment.centerRight.x < 0 ? TextAlign.right : TextAlign.center,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < currentDataPoints.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              currentDataPoints[idx].label,
                              style: AppTheme.caption.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppTheme.darkTextSecondary : AppTheme.neutral600,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (currentDataPoints.length - 1).toDouble(),
                minY: 0,
                maxY: maxAmount,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppTheme.primary,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 5,
                        color: Colors.white,
                        strokeWidth: 3,
                        strokeColor: AppTheme.primary,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primary.withValues(alpha: 0.25),
                          AppTheme.primary.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // BOTTOM ANALYTICS SUB-CARDS GRID
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.8,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildSubStatCard(
                label: 'Avg. Grocery Trip',
                value: CurrencyFormatter.formatWhole(widget.averageTripCost),
                icon: Icons.storefront_rounded,
                iconColor: Colors.teal,
                isDark: isDark,
              ),
              _buildSubStatCard(
                label: 'Most Expensive',
                value: CurrencyFormatter.formatWhole(widget.mostExpensiveTrip),
                icon: Icons.trending_up_rounded,
                iconColor: AppTheme.error,
                isDark: isDark,
              ),
              _buildSubStatCard(
                label: 'Saved vs. Budget',
                value: CurrencyFormatter.formatWhole(widget.moneySaved),
                icon: Icons.savings_outlined,
                iconColor: AppTheme.primary,
                isDark: isDark,
              ),
              _buildSubStatCard(
                label: 'Average Item Cost',
                value: CurrencyFormatter.formatWhole(widget.averageItemCost),
                icon: Icons.local_offer_outlined,
                iconColor: Colors.blue,
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required bool isActive,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? (isDark ? AppTheme.darkSurfaceElevated : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: AppTheme.caption.copyWith(
            fontWeight: FontWeight.bold,
            color: isActive
                ? AppTheme.primary
                : (isDark ? AppTheme.darkTextSecondary : AppTheme.neutral500),
          ),
        ),
      ),
    );
  }

  Widget _buildSubStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurfaceHigh : AppTheme.neutral100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.neutral250,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: AppTheme.caption.copyWith(
                    fontSize: 9,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.neutral500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTheme.monoBold.copyWith(
                    fontSize: 13,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.neutral900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
