import 'package:sqflite/sqflite.dart';
import '../../core/constants/db_constants.dart';
import '../db/app_database.dart';
import '../models/draft_model.dart';

abstract class DraftLocalDataSource {
  Future<int> insertDraft(DraftModel draft);
  Future<int> updateDraft(DraftModel draft);
  Future<int> deleteDraft(int id);
  Future<List<DraftModel>> getAllDrafts();
  Future<DraftModel?> getDraftById(int id);
}

class DraftLocalDataSourceImpl implements DraftLocalDataSource {
  final AppDatabase _appDatabase;

  DraftLocalDataSourceImpl({AppDatabase? appDatabase})
      : _appDatabase = appDatabase ?? AppDatabase();

  Future<Database> get _db => _appDatabase.database;

  @override
  Future<int> insertDraft(DraftModel draft) async {
    final db = await _db;
    final map = draft.toMap();
    map.remove('id');
    return await db.insert(DbConstants.tableDrafts, map);
  }

  @override
  Future<int> updateDraft(DraftModel draft) async {
    final db = await _db;
    return await db.update(
      DbConstants.tableDrafts,
      draft.toMap(),
      where: '${DbConstants.columnId} = ?',
      whereArgs: [draft.id],
    );
  }

  @override
  Future<int> deleteDraft(int id) async {
    final db = await _db;
    return await db.delete(
      DbConstants.tableDrafts,
      where: '${DbConstants.columnId} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<DraftModel>> getAllDrafts() async {
    final db = await _db;
    final maps = await db.query(
      DbConstants.tableDrafts,
      orderBy: '${DbConstants.columnUpdatedAt} DESC',
    );
    return maps.map((map) => DraftModel.fromMap(map)).toList();
  }

  @override
  Future<DraftModel?> getDraftById(int id) async {
    final db = await _db;
    final maps = await db.query(
      DbConstants.tableDrafts,
      where: '${DbConstants.columnId} = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return DraftModel.fromMap(maps.first);
  }
}
