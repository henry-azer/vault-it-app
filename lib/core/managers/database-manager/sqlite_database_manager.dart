import 'package:vault_it/core/managers/database-manager/i_database_manager.dart';
import 'package:vault_it/core/utils/app_local_storage_strings.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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
      onUpgrade: _onUpgrade,
      version: 1,
      onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE ${AppLocalStorageKeys.accountsTable}(id TEXT PRIMARY KEY, title TEXT, url TEXT, username TEXT, password TEXT, notes TEXT, addedDate TEXT, lastModified TEXT, isFavorite INTEGER DEFAULT 0, passwordHistory TEXT, sortOrder INTEGER DEFAULT 0)',
    );
    
    await db.execute(
      'CREATE TABLE ${AppLocalStorageKeys.categoriesTable}(id TEXT PRIMARY KEY, name TEXT NOT NULL, color TEXT, icon TEXT, createdDate TEXT NOT NULL, sortOrder INTEGER DEFAULT 0)',
    );
    
    await db.execute(
      'CREATE TABLE ${AppLocalStorageKeys.accountCategoriesTable}(accountId TEXT NOT NULL, categoryId TEXT NOT NULL, PRIMARY KEY (accountId, categoryId), FOREIGN KEY (accountId) REFERENCES ${AppLocalStorageKeys.accountsTable}(id) ON DELETE CASCADE, FOREIGN KEY (categoryId) REFERENCES ${AppLocalStorageKeys.categoriesTable}(id) ON DELETE CASCADE)',
    );
    
    await db.execute(
      'CREATE INDEX idx_account_categories_accountId ON ${AppLocalStorageKeys.accountCategoriesTable}(accountId)',
    );
    
    await db.execute(
      'CREATE INDEX idx_account_categories_categoryId ON ${AppLocalStorageKeys.accountCategoriesTable}(categoryId)',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {}

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
