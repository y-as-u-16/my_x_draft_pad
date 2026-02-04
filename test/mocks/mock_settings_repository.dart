import 'package:my_x_draft_pad/domain/entities/settings_entity.dart';
import 'package:my_x_draft_pad/domain/repositories/settings_repository.dart';

/// SettingsRepositoryのモック実装
class MockSettingsRepository implements SettingsRepository {
  SettingsEntity _settings = const SettingsEntity(
    maxLength: 280,
    isDarkMode: false,
  );
  bool shouldThrowError = false;
  String errorMessage = 'Mock error';

  void setSettings(SettingsEntity settings) {
    _settings = settings;
  }

  void reset() {
    _settings = const SettingsEntity(maxLength: 280, isDarkMode: false);
    shouldThrowError = false;
    errorMessage = 'Mock error';
  }

  @override
  Future<SettingsEntity> getSettings() async {
    if (shouldThrowError) throw Exception(errorMessage);
    return _settings;
  }

  @override
  Future<void> saveMaxLength(int maxLength) async {
    if (shouldThrowError) throw Exception(errorMessage);
    _settings = _settings.copyWith(maxLength: maxLength);
  }

  @override
  Future<void> saveThemeMode(bool isDarkMode) async {
    if (shouldThrowError) throw Exception(errorMessage);
    _settings = _settings.copyWith(isDarkMode: isDarkMode);
  }
}
