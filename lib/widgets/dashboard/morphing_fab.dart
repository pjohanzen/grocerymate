import 'package:flutter/material.dart';
import '../../config/theme.dart';

class MorphingFab extends StatefulWidget {
  final VoidCallback onNewList;
  final VoidCallback onScanBarcode;
  final VoidCallback onScanReceipt;
  final VoidCallback onTemplates;
  final VoidCallback onQuickAddItem;

  const MorphingFab({
    super.key,
    required this.onNewList,
    required this.onScanBarcode,
    required this.onScanReceipt,
    required this.onTemplates,
    required this.onQuickAddItem,
  });

  @override
  State<MorphingFab> createState() => _MorphingFabState();
}

class _MorphingFabState extends State<MorphingFab> with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.125).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    ); // Rotate 45 deg (0.125 turns)
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isOpen = !_isOpen;
    });
    if (_isOpen) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Hidden Expanded Action Items
        if (_isOpen) ...[
          _buildMiniAction(
            label: 'Quick Add Item',
            icon: Icons.add_shopping_cart_rounded,
            color: Colors.blue,
            isDark: isDark,
            onTap: () {
              _toggleMenu();
              widget.onQuickAddItem();
            },
          ),
          const SizedBox(height: 10),
          _buildMiniAction(
            label: 'New Grocery List',
            icon: Icons.create_new_folder_rounded,
            color: AppTheme.primary,
            isDark: isDark,
            onTap: () {
              _toggleMenu();
              widget.onNewList();
            },
          ),
          const SizedBox(height: 10),
          _buildMiniAction(
            label: 'Scan Barcode',
            icon: Icons.qr_code_scanner_rounded,
            color: Colors.teal,
            isDark: isDark,
            onTap: () {
              _toggleMenu();
              widget.onScanBarcode();
            },
          ),
          const SizedBox(height: 10),
          _buildMiniAction(
            label: 'Scan Receipt OCR',
            icon: Icons.receipt_long_rounded,
            color: Colors.purple,
            isDark: isDark,
            onTap: () {
              _toggleMenu();
              widget.onScanReceipt();
            },
          ),
          const SizedBox(height: 10),
          _buildMiniAction(
            label: 'Templates Deck',
            icon: Icons.bookmark_add_rounded,
            color: AppTheme.secondary,
            isDark: isDark,
            onTap: () {
              _toggleMenu();
              widget.onTemplates();
            },
          ),
          const SizedBox(height: 14),
        ],
        // The Floating Action Trigger Button
        FloatingActionButton(
          onPressed: _toggleMenu,
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
          elevation: 6,
          child: RotationTransition(
            turns: _rotationAnimation,
            child: const Icon(
              Icons.add,
              size: 28,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniAction({
    required String label,
    required IconData icon,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return ScaleTransition(
      scale: _expandAnimation,
      child: FadeTransition(
        opacity: _expandAnimation,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              color: isDark ? AppTheme.darkSurfaceHigh : Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Text(
                  label,
                  style: AppTheme.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.neutral900,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            FloatingActionButton.small(
              heroTag: 'mini_fab_$label',
              onPressed: onTap,
              backgroundColor: isDark ? AppTheme.darkSurfaceElevated : Colors.white,
              foregroundColor: color,
              shape: const CircleBorder(),
              elevation: 4,
              child: Icon(icon, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
