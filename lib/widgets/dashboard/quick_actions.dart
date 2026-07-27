import 'package:flutter/material.dart';
import '../../config/theme.dart';

class QuickActionsGrid extends StatelessWidget {
  final VoidCallback onNewList;
  final VoidCallback onScanBarcode;
  final VoidCallback onScanReceipt;
  final VoidCallback onTemplates;

  const QuickActionsGrid({
    super.key,
    required this.onNewList,
    required this.onScanBarcode,
    required this.onScanReceipt,
    required this.onTemplates,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildActionCard(
          context: context,
          label: 'New List',
          icon: Icons.playlist_add_rounded,
          color: AppTheme.primary,
          isDark: isDark,
          onTap: onNewList,
        ),
        _buildActionCard(
          context: context,
          label: 'Scan Barcode',
          icon: Icons.qr_code_scanner_rounded,
          color: Colors.blue,
          isDark: isDark,
          onTap: onScanBarcode,
        ),
        _buildActionCard(
          context: context,
          label: 'Scan Receipt',
          icon: Icons.receipt_long_rounded,
          color: Colors.purple,
          isDark: isDark,
          onTap: onScanReceipt,
        ),
        _buildActionCard(
          context: context,
          label: 'Templates',
          icon: Icons.bookmark_add_rounded,
          color: AppTheme.secondary,
          isDark: isDark,
          onTap: onTemplates,
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurfaceElevated : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppTheme.darkBorder : AppTheme.neutral300,
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              Text(
                label,
                style: AppTheme.headline3.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.neutral900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
