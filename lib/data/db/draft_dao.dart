import 'package:sqflite/sqflite.dart';
import '../models/draft.dart';
import '../../core/constants/db_constants.dart';
import 'app_database.dart';

abstract class DraftDao {
  Future<int> insertDraft(Draft draft);
  Future<int> updateDraft(Draft draft);
  Future<int> deleteDraft(int id);
  Future<List<Draft>> getAllDrafts();
  Future<Draft?> getDraftById(int id);
}

class DraftDaoImpl implements DraftDao {
  final AppDatabase _appDatabase;

  DraftDaoImpl({AppDatabase? appDatabase})
      : _appDatabase = appDatabase ?? AppDatabase();

  Future<Database> get _db => _appDatabase.database;

  @override
  Future<int> insertDraft(Draft draft) async {
    final db = await _db;
    final map = draft.toMap();
    map.remove('id');
    return await db.insert(DbConstants.tableDrafts, map);
  }

  @override
  Future<int> updateDraft(Draft draft) async {
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
  Future<List<Draft>> getAllDrafts() async {
    final db = await _db;
    final maps = await db.query(
      DbConstants.tableDrafts,
      orderBy: '${DbConstants.columnUpdatedAt} DESC',
    );
    return maps.map((map) => Draft.fromMap(map)).toList();
  }

  @override
  Future<Draft?> getDraftById(int id) async {
    final db = await _db;
    final maps = await db.query(
      DbConstants.tableDrafts,
      where: '${DbConstants.columnId} = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Draft.fromMap(maps.first);
  }
}