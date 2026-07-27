import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/analytics_service.dart';

class UpcomingShopping extends StatelessWidget {
  final UpcomingTrip? trip;
  final VoidCallback onSchedulePressed;

  const UpcomingShopping({
    super.key,
    this.trip,
    required this.onSchedulePressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (trip == null) {
      // Empty state encouraging scheduling
      return Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurfaceElevated : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppTheme.darkBorder : AppTheme.neutral300,
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.calendar_today_rounded,
                color: AppTheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No Shopping Trips Planned',
                    style: AppTheme.headline3.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.neutral900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Set shopping days on your lists to get alerts.',
                    style: AppTheme.bodyRegular.copyWith(
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.neutral500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: onSchedulePressed,
              style: TextButton.styleFrom(
                textStyle: AppTheme.label.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              child: const Text('Schedule'),
            ),
          ],
        ),
      );
    }

    final int days = trip!.daysRemaining;
    String countdownText = '';
    Color countdownColor = AppTheme.primary;

    if (days == 0) {
      countdownText = 'Shopping trip is today!';
      countdownColor = AppTheme.success;
    } else if (days == 1) {
      countdownText = 'Only 1 day left';
      countdownColor = AppTheme.warning;
    } else if (days < 0) {
      countdownText = 'Trip overdue!';
      countdownColor = AppTheme.error;
    } else {
      countdownText = 'Only $days days left';
    }

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
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: countdownColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.notifications_active_outlined,
              color: countdownColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip!.listName,
                  style: AppTheme.headline3.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.neutral900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '${trip!.dayLabel} • ',
                      style: AppTheme.bodyRegular.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.neutral600,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      trip!.timeLabel,
                      style: AppTheme.bodyRegular.copyWith(
                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.neutral500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: countdownColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              countdownText,
              style: AppTheme.caption.copyWith(
                color: countdownColor,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
