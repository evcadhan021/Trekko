import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trekko/core/theme/theme_mode_provider.dart';

void main() {
  group('AppThemeModeNotifier', () {
    test('switches to dark mode when enabled', () {
      final notifier = AppThemeModeNotifier();

      notifier.toggle(true);

      expect(notifier.state, ThemeMode.dark);
    });

    test('switches back to light mode when disabled', () {
      final notifier = AppThemeModeNotifier();

      notifier.toggle(true);
      notifier.toggle(false);

      expect(notifier.state, ThemeMode.light);
    });
  });
}
