import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../config/theme.dart';

class BudgetProgressRing extends StatelessWidget {
  final double percentage;
  final double spent;
  final double? budget;
  final double size;
  final double strokeWidth;

  const BudgetProgressRing({
    super.key,
    required this.percentage,
    required this.spent,
    this.budget,
    this.size = 180,
    this.strokeWidth = 12,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.getBudgetColor(percentage);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              progress: 1.0,
              color: isDark ? AppTheme.darkSurfaceHigh : AppTheme.neutral200,
              strokeWidth: strokeWidth,
            ),
          ),
          // Progress ring
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: percentage.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return CustomPaint(
                size: Size(size, size),
                painter: _RingPainter(
                  progress: value,
                  color: color,
                  strokeWidth: strokeWidth,
                ),
              );
            },
          ),
          // Center text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(percentage * 100).round()}%',
                style: AppTheme.monoLarge.copyWith(
                  color: color,
                  fontSize: size * 0.17,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'spent',
                style: AppTheme.caption.copyWith(
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.neutral500,
                  fontSize: size * 0.07,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

class BudgetProgressBar extends StatelessWidget {
  final double percentage;
  final double height;

  const BudgetProgressBar({
    super.key,
    required this.percentage,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.getBudgetColor(percentage);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: SizedBox(
        height: height,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: percentage.clamp(0.0, 1.0)),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return LinearProgressIndicator(
              value: value,
              backgroundColor:
                  isDark ? AppTheme.darkSurfaceHigh : AppTheme.neutral200,
              valueColor: AlwaysStoppedAnimation(color),
            );
          },
        ),
      ),
    );
  }
}
