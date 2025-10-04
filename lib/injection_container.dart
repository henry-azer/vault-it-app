import 'package:get_it/get_it.dart';
import 'package:vault_it/core/managers/database-manager/i_database_manager.dart';
import 'package:vault_it/core/managers/database-manager/sqlite_database_manager.dart';
import 'package:vault_it/core/managers/storage-manager/i_storage_manager.dart';
import 'package:vault_it/core/managers/storage-manager/local_storage_manager.dart';
import 'package:vault_it/data/datasources/app_local_datasource.dart';
import 'package:vault_it/data/datasources/account_local_datasource.dart';
import 'package:vault_it/data/datasources/user_local_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> init() async {

  // !---- Managers ----!
  sl.registerLazySingleton<IStorageManager>(() => LocalStorageManager());
  
  // Initialize database manager
  final databaseManager = SqliteDatabaseManager();
  await databaseManager.init();
  sl.registerLazySingleton<IDatabaseManager>(() => databaseManager);

  // !---- Data Sources ----!
  sl.registerLazySingleton<AppLocalDataSource>(() => AppLocalDataSourceImpl(storageManager: sl()));
  sl.registerLazySingleton<UserLocalDataSource>(() => UserLocalDataSourceImpl(storageManager: sl()));
  sl.registerLazySingleton<AccountLocalDataSource>(() => AccountLocalDataSourceImpl(databaseManager: sl()));

  // !---- External ----!
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

}
