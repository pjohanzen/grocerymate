import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/analytics_service.dart';
import '../../utils/currency_formatter.dart';

class MostPurchasedList extends StatelessWidget {
  final List<MostPurchasedItem> items;

  const MostPurchasedList({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurfaceElevated : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.neutral300,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Most Purchased Items',
            style: AppTheme.headline3.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.neutral900,
            ),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = items[index];
              
              IconData trendIcon = Icons.trending_flat_rounded;
              Color trendColor = Colors.grey;
              if (item.trendDirection > 0) {
                trendIcon = Icons.trending_up_rounded;
                trendColor = AppTheme.success;
              } else if (item.trendDirection < 0) {
                trendIcon = Icons.trending_down_rounded;
                trendColor = AppTheme.error;
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.shopping_cart_outlined,
                        color: AppTheme.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: AppTheme.bodyLarge.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppTheme.darkTextPrimary : AppTheme.neutral900,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Bought ${item.purchaseCount} times • Avg: ${CurrencyFormatter.formatWhole(item.averagePrice)}',
                            style: AppTheme.caption.copyWith(
                              fontSize: 11,
                              color: isDark ? AppTheme.darkTextSecondary : AppTheme.neutral500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Icon(
                          trendIcon,
                          color: trendColor,
                          size: 16,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDate(item.lastPurchased),
                          style: AppTheme.caption.copyWith(
                            fontSize: 9,
                            color: isDark ? AppTheme.darkTextSecondary.withValues(alpha: 0.6) : AppTheme.neutral500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }
}
