import '../entities/settings_entity.dart';

abstract class SettingsRepository {
  Future<SettingsEntity> getSettings();
  Future<void> saveMaxLength(int maxLength);
  Future<void> saveThemeMode(bool isDarkMode);
}
