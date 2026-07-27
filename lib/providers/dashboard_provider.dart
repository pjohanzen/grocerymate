import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/analytics_service.dart';
import 'list_provider.dart';
import 'pantry_provider.dart';

final dashboardStatsProvider = Provider<DashboardStats>((ref) {
  // Watch providers so dashboard stats dynamically rebuild on changes
  ref.watch(groceryListsProvider);
  ref.watch(pantryProvider);
  
  return AnalyticsService.calculateStats();
});

final selectedDonutCategoryIndexProvider = StateProvider<int?>((ref) => null);

final activeTabProvider = StateProvider<int>((ref) => 0);
