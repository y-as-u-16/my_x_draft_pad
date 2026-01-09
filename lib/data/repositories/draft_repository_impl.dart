import '../../domain/entities/draft_entity.dart';
import '../../domain/repositories/draft_repository.dart';
import '../datasources/draft_local_datasource.dart';
import '../models/draft_model.dart';

class DraftRepositoryImpl implements DraftRepository {
  final DraftLocalDataSource _localDataSource;

  DraftRepositoryImpl(this._localDataSource);

  @override
  Future<List<DraftEntity>> getAllDrafts() async {
    final models = await _localDataSource.getAllDrafts();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<DraftEntity?> getDraftById(int id) async {
    final model = await _localDataSource.getDraftById(id);
    return model?.toEntity();
  }

  @override
  Future<int> createDraft(DraftEntity draft) async {
    return _localDataSource.insertDraft(DraftModel.fromEntity(draft));
  }

  @override
  Future<void> updateDraft(DraftEntity draft) async {
    await _localDataSource.updateDraft(DraftModel.fromEntity(draft));
  }

  @override
  Future<void> deleteDraft(int id) async {
    await _localDataSource.deleteDraft(id);
  }
}