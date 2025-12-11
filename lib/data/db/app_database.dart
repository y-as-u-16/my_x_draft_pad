import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/constants/db_constants.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;
  AppDatabase._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, DbConstants.databaseName);

    return await openDatabase(
      path,
      version: DbConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${DbConstants.tableDrafts} (
        ${DbConstants.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.columnContent} TEXT NOT NULL,
        ${DbConstants.columnCreatedAt} INTEGER NOT NULL,
        ${DbConstants.columnUpdatedAt} INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DbConstants.tableAppSettings} (
        ${DbConstants.columnKey} TEXT PRIMARY KEY,
        ${DbConstants.columnValue} TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Future migrations go here
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}