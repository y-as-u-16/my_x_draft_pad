import 'package:my_x_draft_pad/domain/entities/draft_entity.dart';
import 'package:my_x_draft_pad/domain/repositories/draft_repository.dart';

/// DraftRepositoryのモック実装
class MockDraftRepository implements DraftRepository {
  List<DraftEntity> _drafts = [];
  int _nextId = 1;
  bool shouldThrowError = false;
  String errorMessage = 'Mock error';

  void setDrafts(List<DraftEntity> drafts) {
    _drafts = List.from(drafts);
  }

  void reset() {
    _drafts = [];
    _nextId = 1;
    shouldThrowError = false;
    errorMessage = 'Mock error';
  }

  @override
  Future<List<DraftEntity>> getAllDrafts() async {
    if (shouldThrowError) throw Exception(errorMessage);
    return _drafts;
  }

  @override
  Future<DraftEntity?> getDraftById(int id) async {
    if (shouldThrowError) throw Exception(errorMessage);
    try {
      return _drafts.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<int> createDraft(DraftEntity draft) async {
    if (shouldThrowError) throw Exception(errorMessage);
    final newDraft = draft.copyWith(id: _nextId);
    _drafts.add(newDraft);
    return _nextId++;
  }

  @override
  Future<void> updateDraft(DraftEntity draft) async {
    if (shouldThrowError) throw Exception(errorMessage);
    final index = _drafts.indexWhere((d) => d.id == draft.id);
    if (index != -1) {
      _drafts[index] = draft;
    }
  }

  @override
  Future<void> deleteDraft(int id) async {
    if (shouldThrowError) throw Exception(errorMessage);
    _drafts.removeWhere((d) => d.id == id);
  }
}
