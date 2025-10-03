import '../entities/account.dart';
import '../../core/managers/database-manager/i_database_manager.dart';
import '../../core/utils/app_local_storage_strings.dart';

abstract class AccountLocalDataSource {
  Future<List<Account>> getAccounts();
  Future<Account?> getAccountById(String id);
  Future<void> addAccount(Account account);
  Future<void> updateAccount(Account account);
  Future<void> deleteAccount(String id);
  Future<void> deleteAllAccounts();
  Future<List<Account>> searchAccounts(String query);
}

class AccountLocalDataSourceImpl implements AccountLocalDataSource {
  final IDatabaseManager databaseManager;

  AccountLocalDataSourceImpl({required this.databaseManager});

  @override
  Future<List<Account>> getAccounts() async {
    final List<Map<String, dynamic>> maps = await databaseManager.query(AppLocalStorageKeys.accountsTable);
    return maps.map((map) => Account.fromMap(map)).toList();
  }

  @override
  Future<Account?> getAccountById(String id) async {
    final List<Map<String, dynamic>> maps = await databaseManager.query(
      AppLocalStorageKeys.accountsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return Account.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<void> addAccount(Account account) async {
    await databaseManager.insert(AppLocalStorageKeys.accountsTable, account.toMap());
  }

  @override
  Future<void> updateAccount(Account account) async {
    await databaseManager.update(
      AppLocalStorageKeys.accountsTable,
      account.toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }

  @override
  Future<void> deleteAccount(String id) async {
    await databaseManager.delete(
      AppLocalStorageKeys.accountsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> deleteAllAccounts() async {
    await databaseManager.delete(AppLocalStorageKeys.accountsTable);
  }

  @override
  Future<List<Account>> searchAccounts(String query) async {
    final List<Map<String, dynamic>> maps = await databaseManager.query(
      AppLocalStorageKeys.accountsTable,
      where: 'title LIKE ? OR username LIKE ? OR url LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
    );
    return maps.map((map) => Account.fromMap(map)).toList();
  }
}
