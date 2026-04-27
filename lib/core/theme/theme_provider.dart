import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);

class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    unawaited(_loadTheme());
    return ThemeMode.system;
  }

  static const _themeKey = 'theme_mode';
  final _storage = const FlutterSecureStorage();

  Future<void> _loadTheme() async {
    final theme = await _storage.read(key: _themeKey);
    if (theme != null) {
      state = ThemeMode.values.firstWhere(
        (e) => e.name == theme,
        orElse: () => ThemeMode.system,
      );
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    await _storage.write(key: _themeKey, value: mode.name);
  }

  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setTheme(newMode);
  }
}
