import 'package:get_it/get_it.dart';
import '../../data/datasources/draft_local_datasource.dart';
import '../../data/datasources/settings_local_datasource.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/draft_repository_impl.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/repositories/draft_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/usecases/draft_usecases.dart';
import '../../domain/usecases/settings_usecases.dart';
import '../../presentation/viewmodels/draft_edit_viewmodel.dart';
import '../../presentation/viewmodels/draft_list_viewmodel.dart';
import '../../presentation/viewmodels/settings_viewmodel.dart';
import '../../presentation/viewmodels/theme_viewmodel.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // Database
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // Data Sources
  sl.registerLazySingleton<DraftLocalDataSource>(
    () => DraftLocalDataSourceImpl(appDatabase: sl()),
  );
  sl.registerLazySingleton<SettingsLocalDataSource>(
    () => SettingsLocalDataSourceImpl(),
  );

  // Repositories
  sl.registerLazySingleton<DraftRepository>(
    () => DraftRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(sl()),
  );

  // Use Cases - Draft
  sl.registerLazySingleton(() => GetAllDraftsUseCase(sl()));
  sl.registerLazySingleton(() => GetDraftByIdUseCase(sl()));
  sl.registerLazySingleton(() => CreateDraftUseCase(sl()));
  sl.registerLazySingleton(() => UpdateDraftUseCase(sl()));
  sl.registerLazySingleton(() => DeleteDraftUseCase(sl()));

  // Use Cases - Settings
  sl.registerLazySingleton(() => GetSettingsUseCase(sl()));
  sl.registerLazySingleton(() => SaveMaxLengthUseCase(sl()));
  sl.registerLazySingleton(() => SaveThemeModeUseCase(sl()));

  // ViewModels
  sl.registerFactory(
    () => DraftListViewModel(
      getAllDraftsUseCase: sl(),
      deleteDraftUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => SettingsViewModel(
      getSettingsUseCase: sl(),
      saveMaxLengthUseCase: sl(),
      saveThemeModeUseCase: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => ThemeViewModel(
      getSettingsUseCase: sl(),
      saveThemeModeUseCase: sl(),
    ),
  );
}

DraftEditViewModel createDraftEditViewModel({
  required CreateDraftUseCase createDraftUseCase,
  required UpdateDraftUseCase updateDraftUseCase,
  required GetSettingsUseCase getSettingsUseCase,
  dynamic initialDraft,
}) {
  return DraftEditViewModel(
    createDraftUseCase: createDraftUseCase,
    updateDraftUseCase: updateDraftUseCase,
    getSettingsUseCase: getSettingsUseCase,
    initialDraft: initialDraft,
  );
}