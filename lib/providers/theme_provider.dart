import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/theme_service.dart';
import '../services/local_storage_service.dart';

// ─── Theme Mode Provider ────────────────────────────────────────

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _load();
  }

  void _load() {
    state = ThemeService.loadThemeMode();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await ThemeService.saveThemeMode(mode);
  }

  void refresh() {
    _load();
  }
}

// ─── List View Mode ─────────────────────────────────────────────

enum ListViewMode { grid, list }

final listViewModeProvider =
    StateNotifierProvider<ListViewModeNotifier, ListViewMode>((ref) {
  return ListViewModeNotifier();
});

class ListViewModeNotifier extends StateNotifier<ListViewMode> {
  ListViewModeNotifier() : super(ListViewMode.grid) {
    _load();
  }

  void _load() {
    final mode = LocalStorageService.getSetting<String>('list_view_mode');
    state = mode == 'list' ? ListViewMode.list : ListViewMode.grid;
  }

  Future<void> toggle() async {
    state = state == ListViewMode.grid ? ListViewMode.list : ListViewMode.grid;
    await LocalStorageService.setSetting(
      'list_view_mode',
      state == ListViewMode.list ? 'list' : 'grid',
    );
  }

  void refresh() {
    _load();
  }
}
