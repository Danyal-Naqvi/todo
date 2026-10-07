import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const String _keyThemeMode = 'app_theme_mode';

  ThemeCubit() : super(ThemeMode.dark) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modeString = prefs.getString(_keyThemeMode);
      if (modeString == 'light') {
        emit(ThemeMode.light);
      } else if (modeString == 'dark') {
        emit(ThemeMode.dark);
      } else if (modeString == 'system') {
        emit(ThemeMode.system);
      } else {
        emit(ThemeMode.dark);
      }
    } catch (_) {
      emit(ThemeMode.dark);
    }
  }

  Future<void> toggleTheme() async {
    final nextMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    emit(nextMode);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyThemeMode, nextMode == ThemeMode.dark ? 'dark' : 'light');
    } catch (_) {}
  }

  Future<void> setTheme(ThemeMode mode) async {
    emit(mode);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyThemeMode, mode.name);
    } catch (_) {}
  }
}
