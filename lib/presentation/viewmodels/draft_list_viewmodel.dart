import 'package:flutter/foundation.dart';
import '../../domain/entities/draft_entity.dart';
import '../../domain/usecases/draft_usecases.dart';

class DraftListViewModel extends ChangeNotifier {
  final GetAllDraftsUseCase _getAllDraftsUseCase;
  final DeleteDraftUseCase _deleteDraftUseCase;

  DraftListViewModel({
    required GetAllDraftsUseCase getAllDraftsUseCase,
    required DeleteDraftUseCase deleteDraftUseCase,
  })  : _getAllDraftsUseCase = getAllDraftsUseCase,
        _deleteDraftUseCase = deleteDraftUseCase;

  List<DraftEntity> _drafts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<DraftEntity> get drafts => _drafts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isEmpty => _drafts.isEmpty;

  Future<void> loadDrafts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _drafts = await _getAllDraftsUseCase();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteDraft(int id) async {
    try {
      await _deleteDraftUseCase(id);
      await loadDrafts();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}