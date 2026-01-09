import 'package:flutter/foundation.dart';
import '../../domain/entities/draft_entity.dart';
import '../../domain/usecases/draft_usecases.dart';
import '../../domain/usecases/settings_usecases.dart';

class DraftEditViewModel extends ChangeNotifier {
  final CreateDraftUseCase _createDraftUseCase;
  final UpdateDraftUseCase _updateDraftUseCase;
  final GetSettingsUseCase _getSettingsUseCase;

  DraftEditViewModel({
    required CreateDraftUseCase createDraftUseCase,
    required UpdateDraftUseCase updateDraftUseCase,
    required GetSettingsUseCase getSettingsUseCase,
    DraftEntity? initialDraft,
  }) : _createDraftUseCase = createDraftUseCase,
       _updateDraftUseCase = updateDraftUseCase,
       _getSettingsUseCase = getSettingsUseCase,
       _draft = initialDraft,
       _content = initialDraft?.content ?? '';

  DraftEntity? _draft;
  String _content;
  int _maxLength = 280;
  bool _hasChanges = false;
  bool _isSaving = false;
  String? _errorMessage;

  DraftEntity? get draft => _draft;
  String get content => _content;
  int get maxLength => _maxLength;
  bool get hasChanges => _hasChanges;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  int get currentLength => _content.runes.length;
  bool get isEditing => _draft?.id != null;

  Future<void> loadSettings() async {
    try {
      final settings = await _getSettingsUseCase();
      _maxLength = settings.maxLength;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void updateContent(String value) {
    _content = value;
    _hasChanges = true;
    notifyListeners();
  }

  Future<bool> saveDraft() async {
    if (_isSaving) return false;

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_draft?.id != null) {
        final updatedDraft = _draft!.copyWith(content: _content);
        await _updateDraftUseCase(updatedDraft);
        _draft = updatedDraft.copyWith(updatedAt: DateTime.now());
      } else {
        final id = await _createDraftUseCase(_content);
        final now = DateTime.now();
        _draft = DraftEntity(
          id: id,
          content: _content,
          createdAt: now,
          updatedAt: now,
        );
      }
      _hasChanges = false;
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isSaving = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
