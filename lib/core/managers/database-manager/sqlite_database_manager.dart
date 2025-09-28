import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../utils/app_local_storage_strings.dart';
import 'i_database_manager.dart';

class SqliteDatabaseManager extends IDatabaseManager {
  static Database? _database;

  @override
  Future<void> init() async {
    if (_database != null) return;

    final databasePath = await getDatabasesPath();
    final path = join(databasePath, AppLocalStorageKeys.databaseName);
    
    _database = await openDatabase(
      path,
      onCreate: _onCreate,
      version: 1,
      onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE ${AppLocalStorageKeys.passwordsTable}(id TEXT PRIMARY KEY, title TEXT, url TEXT, username TEXT, password TEXT, notes TEXT, addeddate TEXT)',
    );
  }

  @override
  Future<List<Map<String, dynamic>>> query(String table, {String? where, List<dynamic>? whereArgs}) async {
    await init();
    return await _database!.query(table, where: where, whereArgs: whereArgs);
  }

  @override
  Future<int> insert(String table, Map<String, dynamic> data) async {
    await init();
    return await _database!.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<int> update(String table, Map<String, dynamic> data, {String? where, List<dynamic>? whereArgs}) async {
    await init();
    return await _database!.update(table, data, where: where, whereArgs: whereArgs, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<int> delete(String table, {String? where, List<dynamic>? whereArgs}) async {
    await init();
    return await _database!.delete(table, where: where, whereArgs: whereArgs);
  }

  @override
  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
