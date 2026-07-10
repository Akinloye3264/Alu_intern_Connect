import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const _prefsKey = 'theme_mode';

  ThemeCubit() : super(ThemeMode.dark) {
    AppColors.isDark = true;
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final isLight = prefs.getBool(_prefsKey) == false;
    _apply(isLight ? ThemeMode.light : ThemeMode.dark);
  }

  Future<void> toggle() async {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    _apply(next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, next == ThemeMode.dark);
  }

  void _apply(ThemeMode mode) {
    AppColors.isDark = mode == ThemeMode.dark;
    emit(mode);
  }
}
