import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dashboard_screen.dart';
import 'home_screen.dart';
import 'pantry_screen.dart';
import 'templates_screen.dart';
import 'settings_screen.dart';
import '../config/theme.dart';
import '../providers/dashboard_provider.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  final List<Widget> _screens = [
    const DashboardScreen(),
    const HomeScreen(),
    const PantryScreen(),
    const TemplatesScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final activeIndex = ref.watch(activeTabProvider);

    return Scaffold(
      body: IndexedStack(
        index: activeIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: activeIndex,
        onDestinationSelected: (index) {
          ref.read(activeTabProvider.notifier).state = index;
        },
        backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
        indicatorColor: theme.colorScheme.primary.withValues(alpha: 0.15),
        elevation: 8,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: theme.colorScheme.primary),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: const Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(Icons.shopping_bag, color: theme.colorScheme.primary),
            label: 'Lists',
          ),
          NavigationDestination(
            icon: const Icon(Icons.kitchen_outlined),
            selectedIcon: Icon(Icons.kitchen, color: theme.colorScheme.primary),
            label: 'Pantry',
          ),
          NavigationDestination(
            icon: const Icon(Icons.bookmark_border_rounded),
            selectedIcon: Icon(Icons.bookmark_rounded, color: theme.colorScheme.primary),
            label: 'Templates',
          ),
          NavigationDestination(
            icon: const Icon(Icons.tune_rounded),
            selectedIcon: Icon(Icons.tune_rounded, color: theme.colorScheme.primary),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
