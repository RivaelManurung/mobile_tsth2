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

// Auth Feature Dependencies

// Barang Feature Dependencies
import 'package:inventory_tsth2/features/barang/data/datasources/barang_remote_data_source.dart';
import 'package:inventory_tsth2/features/barang/data/repositories/barang_repository_impl.dart';
import 'package:inventory_tsth2/features/barang/domain/repositories/barang_repository.dart';
import 'package:inventory_tsth2/features/barang/domain/usecases/get_all_barang_usecase.dart';
import 'package:inventory_tsth2/features/barang/domain/usecases/get_barang_by_id_usecase.dart';
import 'package:inventory_tsth2/features/barang/presentation/bloc/barang_bloc.dart';

// Gudang Feature Dependencies
import 'package:inventory_tsth2/features/gudang/data/datasources/gudang_remote_data_source.dart';
import 'package:inventory_tsth2/features/gudang/data/repositories/gudang_repository_impl.dart';
import 'package:inventory_tsth2/features/gudang/domain/repositories/gudang_repository.dart';
import 'package:inventory_tsth2/features/gudang/domain/usecases/get_all_gudang_usecase.dart';
import 'package:inventory_tsth2/features/gudang/domain/usecases/get_gudang_by_id_usecase.dart';
import 'package:inventory_tsth2/features/gudang/presentation/bloc/gudang_bloc.dart';

// Barang Category Feature Dependencies
import 'package:inventory_tsth2/features/barang_category/data/datasources/barang_category_remote_data_source.dart';
import 'package:inventory_tsth2/features/barang_category/data/repositories/barang_category_repository_impl.dart';
import 'package:inventory_tsth2/features/barang_category/domain/repositories/barang_category_repository.dart';
import 'package:inventory_tsth2/features/barang_category/domain/usecases/get_all_barang_categories_usecase.dart';
import 'package:inventory_tsth2/features/barang_category/presentation/bloc/barang_category_bloc.dart';

// Transaction Type Feature Dependencies

import 'package:inventory_tsth2/features/transaksi_type/data/datasources/transaction_type_remote_data_source.dart';
import 'package:inventory_tsth2/features/transaksi_type/data/repositories/transaction_type_repository_impl.dart';
import 'package:inventory_tsth2/features/transaksi_type/domain/repositories/transaction_type_repository.dart';
import 'package:inventory_tsth2/features/transaksi_type/domain/usecases/get_all_transaction_types_usecase.dart';
import 'package:inventory_tsth2/features/transaksi_type/presentation/bloc/transaction_type_bloc.dart';

// JenisBarang Feature Dependencies
import 'package:inventory_tsth2/features/jenis_barang/data/datasources/jenis_barang_remote_data_source.dart';
import 'package:inventory_tsth2/features/jenis_barang/data/repositories/jenis_barang_repository_impl.dart';
import 'package:inventory_tsth2/features/jenis_barang/domain/repositories/jenis_barang_repository.dart';
import 'package:inventory_tsth2/features/jenis_barang/domain/usecases/get_all_jenis_barang_usecase.dart';
import 'package:inventory_tsth2/features/jenis_barang/presentation/bloc/jenis_barang_bloc.dart';

// Satuan Feature Dependencies
import 'package:inventory_tsth2/features/satuan/data/datasources/satuan_remote_data_source.dart';
import 'package:inventory_tsth2/features/satuan/data/repositories/satuan_repository_impl.dart';
import 'package:inventory_tsth2/features/satuan/domain/repositories/satuan_repository.dart';
import 'package:inventory_tsth2/features/satuan/domain/usecases/get_all_satuan_usecase.dart';
import 'package:inventory_tsth2/features/satuan/presentation/bloc/satuan_bloc.dart';

// Service Locator instance
final sl = GetIt.instance;

Future<void> init() async {
  // #############################################
  // # Features - Auth
  // #############################################
  _registerAuth();

  // #############################################
  // # Features - Barang
  // #############################################
  _registerBarang();

  // #############################################
  // # Features - Gudang
  // #############################################
  _registerGudang();

  // #############################################
  // # Features - Barang Category
  // #############################################
  _registerBarangCategory();

  // #############################################
  // # Features - Transaction Type
  // #############################################
  _registerTransactionType();
// #############################################
  // # Features - Jenis Barang
  // #############################################
  _registerJenisBarang();
  // #############################################
  // # Features - Satuan
  // #############################################
  _registerSatuan();

  // #############################################
  // # External Dependencies
  // #############################################
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => const FlutterSecureStorage());
}

// Helper methods to keep the init() function clean

void _registerAuth() {
  sl.registerFactory(
      () => UserBloc(loginUserUsecase: sl(), logoutUserUsecase: sl()));
  sl.registerLazySingleton(() => LoginUserUsecase(sl()));
  sl.registerLazySingleton(() => LogoutUserUsecase(sl()));
  sl.registerLazySingleton<AuthRepository>(() =>
      AuthRepositoryImpl(authRemoteDatasource: sl(), localDatasource: sl()));
  sl.registerLazySingleton<AuthRemoteDatasource>(
      () => AuthRemoteDatasourceImpl(sl()));
  sl.registerLazySingleton<LocalDatasource>(() => LocalDatasourceImpl(sl()));
}

void _registerBarang() {
  sl.registerFactory(
      () => BarangBloc(getAllBarangUsecase: sl(), getBarangByIdUsecase: sl()));
  sl.registerLazySingleton(() => GetAllBarangUsecase(sl()));
  sl.registerLazySingleton(() => GetBarangByIdUsecase(sl()));
  sl.registerLazySingleton<BarangRepository>(
      () => BarangRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<BarangRemoteDataSource>(
      () => BarangRemoteDataSourceImpl(dio: sl(), authLocalDataSource: sl()));
}

void _registerGudang() {
  sl.registerFactory(
      () => GudangBloc(getAllGudangUsecase: sl(), getGudangByIdUsecase: sl()));
  sl.registerLazySingleton(() => GetAllGudangUsecase(sl()));
  sl.registerLazySingleton(() => GetGudangByIdUsecase(sl()));
  sl.registerLazySingleton<GudangRepository>(
      () => GudangRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<GudangRemoteDataSource>(
      () => GudangRemoteDataSourceImpl(dio: sl(), authLocalDataSource: sl()));
}

void _registerBarangCategory() {
  sl.registerFactory(
      () => BarangCategoryBloc(getAllCategories: sl(), getCategoryById: sl()));
  sl.registerLazySingleton(() => GetAllBarangCategoriesUsecase(sl()));
  sl.registerLazySingleton(() => GetBarangByIdUsecase(sl()));
  sl.registerLazySingleton<BarangCategoryRepository>(
      () => BarangCategoryRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<BarangCategoryRemoteDataSource>(() =>
      BarangCategoryRemoteDataSourceImpl(dio: sl(), authLocalDataSource: sl()));
}

void _registerTransactionType() {
  sl.registerFactory(() => TransactionTypeBloc(getAllTransactionTypes: sl()));
  sl.registerLazySingleton(() => GetAllTransactionTypesUsecase(sl()));
  sl.registerLazySingleton<TransactionTypeRepository>(
      () => TransactionTypeRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<TransactionTypeRemoteDataSource>(() =>
      TransactionTypeRemoteDataSourceImpl(
          dio: sl(), authLocalDataSource: sl()));
}

void _registerJenisBarang() {
  sl.registerFactory(() => JenisBarangBloc(getAllJenisBarang: sl()));

  sl.registerLazySingleton(() => GetAllJenisBarangUsecase(sl()));
  // Register other usecases (create, update, delete) here

  sl.registerLazySingleton<JenisBarangRepository>(
      () => JenisBarangRepositoryImpl(remoteDataSource: sl()));

  sl.registerLazySingleton<JenisBarangRemoteDataSource>(() =>
      JenisBarangRemoteDataSourceImpl(dio: sl(), authLocalDataSource: sl()));
}

void _registerSatuan() {
  sl.registerFactory(() => SatuanBloc(getAllSatuan: sl()));

  sl.registerLazySingleton(() => GetAllSatuanUsecase(sl()));
  // Register other usecases (create, update, delete) here

  sl.registerLazySingleton<SatuanRepository>(
      () => SatuanRepositoryImpl(remoteDataSource: sl()));

  sl.registerLazySingleton<SatuanRemoteDataSource>(
      () => SatuanRemoteDataSourceImpl(dio: sl(), authLocalDataSource: sl()));
}
