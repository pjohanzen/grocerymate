import 'package:flutter/material.dart';
import 'local_storage_service.dart';

class ThemeService {
  ThemeService._();

  /// Loads the saved ThemeMode from local settings.
  static ThemeMode loadThemeMode() {
    final mode = LocalStorageService.getSetting<String>('theme_mode');
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  /// Persists the selected ThemeMode to local settings.
  static Future<void> saveThemeMode(ThemeMode mode) async {
    final modeStr = mode == ThemeMode.light
        ? 'light'
        : mode == ThemeMode.dark
            ? 'dark'
            : 'system';
    await LocalStorageService.setSetting('theme_mode', modeStr);
  }
}
