import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../utils/currency_formatter.dart';

class BudgetOverviewHero extends StatefulWidget {
  final double totalBudget;
  final double totalSpent;
  final double remainingBudget;
  final double budgetPercentage;

  const BudgetOverviewHero({
    super.key,
    required this.totalBudget,
    required this.totalSpent,
    required this.remainingBudget,
    required this.budgetPercentage,
  });

  @override
  State<BudgetOverviewHero> createState() => _BudgetOverviewHeroState();
}

class _BudgetOverviewHeroState extends State<BudgetOverviewHero>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: widget.budgetPercentage).animate(
      CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant BudgetOverviewHero oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.budgetPercentage != widget.budgetPercentage) {
      _animation = Tween<double>(
        begin: oldWidget.budgetPercentage,
        end: widget.budgetPercentage,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Determine Color based on budget percentage
    Color statusColor = AppTheme.success;
    if (widget.budgetPercentage >= 1.0) {
      statusColor = AppTheme.error;
    } else if (widget.budgetPercentage >= 0.85) {
      statusColor = AppTheme.warning;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppTheme.darkSurfaceElevated, AppTheme.darkSurface]
              : [Colors.white, AppTheme.neutral100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.neutral300,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Left side: stats labels
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Budget Plan',
                  style: AppTheme.caption.copyWith(
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.neutral500,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: widget.totalBudget),
                  duration: const Duration(milliseconds: 1000),
                  builder: (context, val, _) {
                    return Text(
                      CurrencyFormatter.formatWhole(val),
                      style: AppTheme.headline2.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.neutral900,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildMiniStat(
                      label: 'Spent',
                      amount: widget.totalSpent,
                      isDark: isDark,
                      amountColor: statusColor,
                    ),
                    const SizedBox(width: 24),
                    _buildMiniStat(
                      label: 'Remaining',
                      amount: widget.remainingBudget,
                      isDark: isDark,
                      amountColor: widget.remainingBudget < 0 ? AppTheme.error : AppTheme.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Right side: animated circular progress ring
          const SizedBox(width: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor.withValues(alpha: 0.05),
                ),
              ),
              SizedBox(
                width: 80,
                height: 80,
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return CircularProgressIndicator(
                      value: _animation.value,
                      strokeWidth: 10,
                      backgroundColor: isDark ? AppTheme.darkBorder : AppTheme.neutral250,
                      color: statusColor,
                      strokeCap: StrokeCap.round,
                    );
                  },
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: widget.budgetPercentage * 100),
                    duration: const Duration(milliseconds: 1200),
                    builder: (context, val, _) {
                      return Text(
                        '${val.toStringAsFixed(0)}%',
                        style: AppTheme.monoBold.copyWith(
                          fontSize: 16,
                          color: isDark ? AppTheme.darkTextPrimary : AppTheme.neutral900,
                        ),
                      );
                    },
                  ),
                  Text(
                    'Used',
                    style: AppTheme.caption.copyWith(
                      fontSize: 10,
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.neutral500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat({
    required String label,
    required double amount,
    required bool isDark,
    required Color amountColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.caption.copyWith(
            fontSize: 11,
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.neutral500,
          ),
        ),
        const SizedBox(height: 2),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: amount),
          duration: const Duration(milliseconds: 1000),
          builder: (context, val, _) {
            return Text(
              CurrencyFormatter.formatWhole(val),
              style: AppTheme.monoBold.copyWith(
                fontSize: 14,
                color: amountColor,
              ),
            );
          },
        ),
      ],
    );
  }
}
