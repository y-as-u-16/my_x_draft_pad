import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/db_constants.dart';

abstract class SettingsLocalDataSource {
  Future<int> getMaxLength();
  Future<bool> getThemeMode();
  Future<void> saveMaxLength(int maxLength);
  Future<void> saveThemeMode(bool isDarkMode);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  @override
  Future<int> getMaxLength() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(DbConstants.settingMaxLength) ??
        DbConstants.defaultMaxLength;
  }

  @override
  Future<bool> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(DbConstants.settingThemeMode) ?? false;
  }

  @override
  Future<void> saveMaxLength(int maxLength) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(DbConstants.settingMaxLength, maxLength);
  }

  @override
  Future<void> saveThemeMode(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(DbConstants.settingThemeMode, isDarkMode);
  }
}