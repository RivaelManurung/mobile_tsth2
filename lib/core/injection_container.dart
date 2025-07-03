import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:inventory_tsth2/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:inventory_tsth2/features/authentication/data/datasources/local_dataSource.dart';
import 'package:inventory_tsth2/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:inventory_tsth2/features/authentication/domain/repositories/auth_repositories.dart';
import 'package:inventory_tsth2/features/authentication/domain/usecases/login_user_usecase.dart';
import 'package:inventory_tsth2/features/authentication/domain/usecases/logout_user.dart';
import 'package:inventory_tsth2/features/authentication/presentation/bloc/user_bloc.dart';


// Service Locator instance
final sl = GetIt.instance;

Future<void> init() async {
  // #############################################
  // # Features - Auth
  // #############################################

  // ---------------------------------------------
  // -- Bloc
  // ---------------------------------------------
  // Register UserBloc as a factory. A new instance will be created every time it's requested.
  sl.registerFactory(
    () => UserBloc(
      loginUserUsecase: sl(),
      logoutUserUsecase: sl(),
    ),
  );

  // ---------------------------------------------
  // -- Usecases
  // ---------------------------------------------
  // Register use cases as lazy singletons. They are instantiated only when first used.
  sl.registerLazySingleton(() => LoginUserUsecase(sl()));
  sl.registerLazySingleton(() => LogoutUserUsecase(sl()));

  // ---------------------------------------------
  // -- Repository
  // ---------------------------------------------
  // Register AuthRepository implementation as a lazy singleton.
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      authRemoteDatasource: sl(),
      localDatasource: sl(),
    ),
  );

  // ---------------------------------------------
  // -- Data sources
  // ---------------------------------------------
  // Register data source implementations as lazy singletons.
  sl.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasourceImpl(sl()),
  );
  sl.registerLazySingleton<LocalDatasource>(
    () => LocalDatasourceImpl(sl()),
  );


  // #############################################
  // # External Dependencies
  // #############################################
  // Register external packages as lazy singletons.
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => const FlutterSecureStorage());
}