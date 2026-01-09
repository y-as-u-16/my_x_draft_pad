import 'package:flutter/foundation.dart';
import '../../domain/entities/settings_entity.dart';
import '../../domain/usecases/settings_usecases.dart';

class SettingsViewModel extends ChangeNotifier {
  final GetSettingsUseCase _getSettingsUseCase;
  final SaveMaxLengthUseCase _saveMaxLengthUseCase;
  final SaveThemeModeUseCase _saveThemeModeUseCase;

  SettingsViewModel({
    required GetSettingsUseCase getSettingsUseCase,
    required SaveMaxLengthUseCase saveMaxLengthUseCase,
    required SaveThemeModeUseCase saveThemeModeUseCase,
  }) : _getSettingsUseCase = getSettingsUseCase,
       _saveMaxLengthUseCase = saveMaxLengthUseCase,
       _saveThemeModeUseCase = saveThemeModeUseCase;

  SettingsEntity _settings = const SettingsEntity(
    maxLength: 280,
    isDarkMode: false,
  );
  bool _isLoading = false;
  String? _errorMessage;

  SettingsEntity get settings => _settings;
  int get maxLength => _settings.maxLength;
  bool get isDarkMode => _settings.isDarkMode;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadSettings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _settings = await _getSettingsUseCase();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> saveMaxLength(int maxLength) async {
    try {
      await _saveMaxLengthUseCase(maxLength);
      _settings = _settings.copyWith(maxLength: maxLength);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> saveThemeMode(bool isDarkMode) async {
    try {
      await _saveThemeModeUseCase(isDarkMode);
      _settings = _settings.copyWith(isDarkMode: isDarkMode);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
