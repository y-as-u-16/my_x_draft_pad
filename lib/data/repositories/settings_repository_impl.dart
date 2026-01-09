import '../../domain/entities/settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource _localDataSource;

  SettingsRepositoryImpl(this._localDataSource);

  @override
  Future<SettingsEntity> getSettings() async {
    final maxLength = await _localDataSource.getMaxLength();
    final isDarkMode = await _localDataSource.getThemeMode();
    return SettingsEntity(maxLength: maxLength, isDarkMode: isDarkMode);
  }

  @override
  Future<void> saveMaxLength(int maxLength) async {
    await _localDataSource.saveMaxLength(maxLength);
  }

  @override
  Future<void> saveThemeMode(bool isDarkMode) async {
    await _localDataSource.saveThemeMode(isDarkMode);
  }
}
