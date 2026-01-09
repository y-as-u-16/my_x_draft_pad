import '../entities/settings_entity.dart';
import '../repositories/settings_repository.dart';

class GetSettingsUseCase {
  final SettingsRepository _repository;

  GetSettingsUseCase(this._repository);

  Future<SettingsEntity> call() {
    return _repository.getSettings();
  }
}

class SaveMaxLengthUseCase {
  final SettingsRepository _repository;

  SaveMaxLengthUseCase(this._repository);

  Future<void> call(int maxLength) {
    return _repository.saveMaxLength(maxLength);
  }
}

class SaveThemeModeUseCase {
  final SettingsRepository _repository;

  SaveThemeModeUseCase(this._repository);

  Future<void> call(bool isDarkMode) {
    return _repository.saveThemeMode(isDarkMode);
  }
}