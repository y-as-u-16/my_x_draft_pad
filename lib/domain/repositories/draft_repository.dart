import '../entities/draft_entity.dart';

abstract class DraftRepository {
  Future<List<DraftEntity>> getAllDrafts();
  Future<DraftEntity?> getDraftById(int id);
  Future<int> createDraft(DraftEntity draft);
  Future<void> updateDraft(DraftEntity draft);
  Future<void> deleteDraft(int id);
}