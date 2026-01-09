import 'package:flutter/material.dart';
import '../../domain/usecases/settings_usecases.dart';

class ThemeViewModel extends ChangeNotifier {
  final GetSettingsUseCase _getSettingsUseCase;
  final SaveThemeModeUseCase _saveThemeModeUseCase;

  ThemeViewModel({
    required GetSettingsUseCase getSettingsUseCase,
    required SaveThemeModeUseCase saveThemeModeUseCase,
  }) : _getSettingsUseCase = getSettingsUseCase,
       _saveThemeModeUseCase = saveThemeModeUseCase;

  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> loadThemeMode() async {
    try {
      final settings = await _getSettingsUseCase();
      _themeMode = settings.isDarkMode ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    } catch (e) {
      // Fallback to light theme
      _themeMode = ThemeMode.light;
      notifyListeners();
    }
  }

  Future<void> setThemeMode(bool isDarkMode) async {
    try {
      await _saveThemeModeUseCase(isDarkMode);
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    } catch (e) {
      // Silently fail
    }
  }
}
