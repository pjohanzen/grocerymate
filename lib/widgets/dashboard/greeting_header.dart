import 'package:flutter/material.dart';
import '../../config/theme.dart';

class GreetingHeader extends StatelessWidget {
  final String greeting;
  final String dateText;
  final String motivationalMessage;

  const GreetingHeader({
    super.key,
    required this.greeting,
    required this.dateText,
    required this.motivationalMessage,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: AppTheme.headline1.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.neutral900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                motivationalMessage,
                style: AppTheme.bodyRegular.copyWith(
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.neutral600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                dateText,
                style: AppTheme.label.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Premium Avatar Placeholder
        Hero(
          tag: 'dashboard_avatar',
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primary, AppTheme.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'U',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
