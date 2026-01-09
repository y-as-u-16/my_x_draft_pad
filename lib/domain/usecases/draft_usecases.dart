import '../entities/draft_entity.dart';
import '../repositories/draft_repository.dart';

class GetAllDraftsUseCase {
  final DraftRepository _repository;

  GetAllDraftsUseCase(this._repository);

  Future<List<DraftEntity>> call() {
    return _repository.getAllDrafts();
  }
}

class GetDraftByIdUseCase {
  final DraftRepository _repository;

  GetDraftByIdUseCase(this._repository);

  Future<DraftEntity?> call(int id) {
    return _repository.getDraftById(id);
  }
}

class CreateDraftUseCase {
  final DraftRepository _repository;

  CreateDraftUseCase(this._repository);

  Future<int> call(String content) {
    final now = DateTime.now();
    final draft = DraftEntity(
      content: content,
      createdAt: now,
      updatedAt: now,
    );
    return _repository.createDraft(draft);
  }
}

class UpdateDraftUseCase {
  final DraftRepository _repository;

  UpdateDraftUseCase(this._repository);

  Future<void> call(DraftEntity draft) {
    final updatedDraft = draft.copyWith(updatedAt: DateTime.now());
    return _repository.updateDraft(updatedDraft);
  }
}

class DeleteDraftUseCase {
  final DraftRepository _repository;

  DeleteDraftUseCase(this._repository);

  Future<void> call(int id) {
    return _repository.deleteDraft(id);
  }
}