import '../entities/password.dart';
import '../../core/managers/database-manager/i_database_manager.dart';
import '../../core/utils/app_local_storage_strings.dart';

abstract class PasswordLocalDataSource {
  Future<List<Password>> getPasswords();
  Future<Password?> getPasswordById(String id);
  Future<void> addPassword(Password password);
  Future<void> updatePassword(Password password);
  Future<void> deletePassword(String id);
  Future<void> deleteAllPasswords();
  Future<List<Password>> searchPasswords(String query);
}

class PasswordLocalDataSourceImpl implements PasswordLocalDataSource {
  final IDatabaseManager databaseManager;

  PasswordLocalDataSourceImpl({required this.databaseManager});

  @override
  Future<List<Password>> getPasswords() async {
    final List<Map<String, dynamic>> maps = await databaseManager.query(AppLocalStorageKeys.passwordsTable);
    return maps.map((map) => Password.fromMap(map)).toList();
  }

  @override
  Future<Password?> getPasswordById(String id) async {
    final List<Map<String, dynamic>> maps = await databaseManager.query(
      AppLocalStorageKeys.passwordsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return Password.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<void> addPassword(Password password) async {
    await databaseManager.insert(AppLocalStorageKeys.passwordsTable, password.toMap());
  }

  @override
  Future<void> updatePassword(Password password) async {
    await databaseManager.update(
      AppLocalStorageKeys.passwordsTable,
      password.toMap(),
      where: 'id = ?',
      whereArgs: [password.id],
    );
  }

  @override
  Future<void> deletePassword(String id) async {
    await databaseManager.delete(
      AppLocalStorageKeys.passwordsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> deleteAllPasswords() async {
    await databaseManager.delete(AppLocalStorageKeys.passwordsTable);
  }

  @override
  Future<List<Password>> searchPasswords(String query) async {
    final List<Map<String, dynamic>> maps = await databaseManager.query(
      AppLocalStorageKeys.passwordsTable,
      where: 'title LIKE ? OR username LIKE ? OR url LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
    );
    return maps.map((map) => Password.fromMap(map)).toList();
  }
}
