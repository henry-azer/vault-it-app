import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/managers/storage-manager/i_storage_manager.dart';
import 'core/managers/storage-manager/local_storage_manager.dart';
import 'core/managers/database-manager/i_database_manager.dart';
import 'core/managers/database-manager/sqlite_database_manager.dart';
import 'data/datasources/password_local_datasource.dart';
import 'data/datasources/user_local_datasource.dart';
import 'data/datasources/app_local_datasource.dart';

final sl = GetIt.instance;

Future<void> init() async {

  // !---- Data Sources ----!
  sl.registerLazySingleton<AppLocalDataSource>(() => AppLocalDataSourceImpl(storageManager: sl()));
  sl.registerLazySingleton<UserLocalDataSource>(() => UserLocalDataSourceImpl(storageManager: sl()));
  sl.registerLazySingleton<PasswordLocalDataSource>(() => PasswordLocalDataSourceImpl(databaseManager: sl()));

  // !---- Managers ----!
  sl.registerLazySingleton<IStorageManager>(() => LocalStorageManager());
  sl.registerLazySingleton<IDatabaseManager>(() => SqliteDatabaseManager());

  // !---- External ----!
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

}
