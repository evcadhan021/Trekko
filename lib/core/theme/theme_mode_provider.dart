import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appThemeModeProvider =
    StateNotifierProvider<AppThemeModeNotifier, ThemeMode>(
      (ref) => AppThemeModeNotifier(),
    );

class AppThemeModeNotifier extends StateNotifier<ThemeMode> {
  static const String _key = 'theme_mode_dark';

  AppThemeModeNotifier() : super(ThemeMode.light) {
    _loadSavedTheme();
  }

  Future<void> _loadSavedTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool(_key) ?? false;
      if (mounted) {
        state = isDark ? ThemeMode.dark : ThemeMode.light;
      }
    } catch (_) {
      // SharedPreferences is not safe to access before Flutter bindings are
      // initialized (for example, during tests). Keep the default theme until
      // the app's runtime is ready.
    }
  }

  void toggle(bool enabled) {
    state = enabled ? ThemeMode.dark : ThemeMode.light;

    try {
      SharedPreferences.getInstance()
          .then((prefs) {
            prefs.setBool(_key, enabled);
          })
          .catchError((_) {});
    } catch (_) {
      // Ignore persistence errors before Flutter binding initialization or in
      // non-platform test contexts. The provider state itself still updates.
    }
  }
}
