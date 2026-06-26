import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../providers/theme_provider.dart';
import '../providers/list_provider.dart';
import '../services/local_storage_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─── Display ───
          _buildSectionHeader('Display', isDark),
          const SizedBox(height: 8),
          _buildSettingCard(
            isDark: isDark,
            children: [
              ListTile(
                leading: const Icon(Icons.brightness_6_outlined),
                title: const Text('Theme'),
                subtitle: Text(
                  themeMode == ThemeMode.light
                      ? 'Light'
                      : themeMode == ThemeMode.dark
                          ? 'Dark'
                          : 'System',
                ),
                trailing: SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.light,
                      icon: Icon(Icons.light_mode, size: 18),
                    ),
                    ButtonSegment(
                      value: ThemeMode.system,
                      icon: Icon(Icons.phone_android, size: 18),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      icon: Icon(Icons.dark_mode, size: 18),
                    ),
                  ],
                  selected: {themeMode},
                  onSelectionChanged: (selection) {
                    ref
                        .read(themeModeProvider.notifier)
                        .setThemeMode(selection.first);
                  },
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ─── Currency & Units ───
          _buildSectionHeader('Currency & Units', isDark),
          const SizedBox(height: 8),
          _buildSettingCard(
            isDark: isDark,
            children: [
              ListTile(
                leading: const Icon(Icons.monetization_on_outlined),
                title: const Text('Currency'),
                subtitle: const Text('Philippine Peso (₱)'),
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'PHP',
                    style: AppTheme.monoBold.copyWith(
                      color: AppTheme.primary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const Divider(height: 1),
              const ListTile(
                leading: Icon(Icons.straighten_outlined),
                title: Text('Weight Units'),
                subtitle: Text('Metric (kg, g, L, ml)'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ─── Data Management ───
          _buildSectionHeader('Data Management', isDark),
          const SizedBox(height: 8),
          _buildSettingCard(
            isDark: isDark,
            children: [
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Clear Search History'),
                subtitle: const Text('Remove autocomplete suggestions'),
                onTap: () => _confirmClearHistory(context),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.delete_forever, color: AppTheme.error),
                title: Text('Clear All Data',
                    style: TextStyle(color: AppTheme.error)),
                subtitle: const Text('Delete all lists, items, and settings'),
                onTap: () => _confirmClearAll(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ─── About ───
          _buildSectionHeader('About', isDark),
          const SizedBox(height: 8),
          _buildSettingCard(
            isDark: isDark,
            children: [
              const ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('App Version'),
                subtitle: Text('GroceryMate v1.0.0'),
              ),
              const Divider(height: 1),
              const ListTile(
                leading: Icon(Icons.privacy_tip_outlined),
                title: Text('Privacy Policy'),
                trailing: Icon(Icons.open_in_new, size: 18),
              ),
              const Divider(height: 1),
              const ListTile(
                leading: Icon(Icons.description_outlined),
                title: Text('Terms of Service'),
                trailing: Icon(Icons.open_in_new, size: 18),
              ),
              const Divider(height: 1),
              const ListTile(
                leading: Icon(Icons.mail_outline),
                title: Text('Send Feedback'),
                trailing: Icon(Icons.open_in_new, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Stats
          Center(
            child: Text(
              '${LocalStorageService.totalListsCount} lists · ${LocalStorageService.totalItemsCount} items',
              style: AppTheme.caption.copyWith(
                color: isDark
                    ? AppTheme.darkTextSecondary
                    : AppTheme.neutral400,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title.toUpperCase(),
      style: AppTheme.label.copyWith(
        color: isDark ? AppTheme.darkTextSecondary : AppTheme.neutral500,
        letterSpacing: 1,
        fontSize: 11,
      ),
    );
  }

  Widget _buildSettingCard({
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurfaceElevated : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(children: children),
      ),
    );
  }

  void _confirmClearHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History?'),
        content: const Text(
            'This will remove all autocomplete suggestions. Your lists and items will not be affected.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              LocalStorageService.clearHistory();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search history cleared')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _confirmClearAll(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
            'This will permanently delete all your lists, items, and settings. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () async {
              await LocalStorageService.clearAllData();
              ref.read(groceryListsProvider.notifier).refresh();
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All data cleared')),
                );
              }
            },
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );
  }
}
