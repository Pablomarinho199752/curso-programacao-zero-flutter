import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  static const _storageKey = 'app_theme_dark_v1';

  SharedPreferences? _prefs;
  bool _isDark = false;

  bool get isDark => _isDark;
  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _isDark = _prefs?.getBool(_storageKey) ?? false;
  }

  Future<void> setDark(bool value) async {
    if (_isDark == value) return;
    _isDark = value;
    notifyListeners();
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setBool(_storageKey, value);
  }

  Future<void> toggle() => setDark(!_isDark);
}
