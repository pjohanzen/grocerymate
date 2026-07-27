import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../providers/list_provider.dart';
import '../../providers/item_provider.dart';

class SmartSuggestionsList extends ConsumerWidget {
  final List<String> suggestions;

  const SmartSuggestionsList({
    super.key,
    required this.suggestions,
  });

  void _addSuggestedItem(BuildContext context, WidgetRef ref, String itemName) {
    final lists = ref.read(groceryListsProvider);
    if (lists.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please create a grocery shopping list first!')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Add "$itemName" to:',
                  style: AppTheme.headline3.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: lists.length,
                  itemBuilder: (context, idx) {
                    final list = lists[idx];
                    return ListTile(
                      leading: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _parseHexColor(list.colorHex),
                          shape: BoxShape.circle,
                        ),
                      ),
                      title: Text(list.name),
                      onTap: () {
                        // Add item
                        ref.read(listItemsProvider(list.id).notifier).addItem(
                              name: itemName,
                              quantity: 1.0,
                              unit: 'pcs',
                            );
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Added "$itemName" to "${list.name}"!'),
                            backgroundColor: AppTheme.success,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _parseHexColor(String hex) {
    final cleanHex = hex.replaceAll('#', '');
    return Color(int.parse('FF$cleanHex', radix: 16));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            'Smart Suggestions',
            style: AppTheme.headline3.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.neutral900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Based on items running low and shopping history.',
            style: AppTheme.caption.copyWith(
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.neutral500,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions.map((name) {
              return ActionChip(
                elevation: 0,
                pressElevation: 4,
                backgroundColor: isDark ? AppTheme.darkSurfaceHigh : AppTheme.neutral100,
                side: BorderSide(
                  color: isDark ? AppTheme.darkBorder : AppTheme.neutral250,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                avatar: const Icon(
                  Icons.add_rounded,
                  size: 14,
                  color: AppTheme.primary,
                ),
                label: Text(
                  name,
                  style: AppTheme.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.neutral700,
                  ),
                ),
                onPressed: () => _addSuggestedItem(context, ref, name),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
