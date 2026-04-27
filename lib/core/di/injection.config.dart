// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:benaiah_app/core/network/dio_http_client.dart' as _i608;
import 'package:benaiah_app/core/network/dio_module.dart' as _i642;
import 'package:benaiah_app/core/network/http_client.dart' as _i751;
import 'package:benaiah_app/core/network/interceptors/auth_interceptor.dart'
    as _i243;
import 'package:benaiah_app/core/storage/secure_storage_module.dart' as _i1062;
import 'package:benaiah_app/features/about/data/data_sources/about_local_data_source.dart'
    as _i923;
import 'package:benaiah_app/features/about/data/data_sources/about_remote_data_source.dart'
    as _i949;
import 'package:benaiah_app/features/about/data/repositories/about_repository_impl.dart'
    as _i122;
import 'package:benaiah_app/features/about/domain/repositories/about_repository.dart'
    as _i53;
import 'package:benaiah_app/features/home/data/data_sources/home_local_data_source.dart'
    as _i451;
import 'package:benaiah_app/features/home/data/data_sources/home_remote_data_source.dart'
    as _i402;
import 'package:benaiah_app/features/home/data/repositories/home_repository_impl.dart'
    as _i222;
import 'package:benaiah_app/features/home/domain/repositories/home_repository.dart'
    as _i870;
import 'package:benaiah_app/features/main/data/data_sources/main_local_data_source.dart'
    as _i513;
import 'package:benaiah_app/features/main/data/data_sources/main_remote_data_source.dart'
    as _i399;
import 'package:benaiah_app/features/main/data/repositories/main_repository_impl.dart'
    as _i1043;
import 'package:benaiah_app/features/main/domain/repositories/main_repository.dart'
    as _i917;
import 'package:benaiah_app/features/settings/data/data_sources/settings_local_data_source.dart'
    as _i298;
import 'package:benaiah_app/features/settings/data/data_sources/settings_remote_data_source.dart'
    as _i65;
import 'package:benaiah_app/features/settings/data/repositories/settings_repository_impl.dart'
    as _i713;
import 'package:benaiah_app/features/settings/domain/repositories/settings_repository.dart'
    as _i292;
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final secureStorageModule = _$SecureStorageModule();
    final dioModule = _$DioModule();
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => secureStorageModule.secureStorage,
    );
    gh.lazySingleton<_i451.HomeLocalDataSource>(
      () => _i451.HomeLocalDataSourceImpl(),
    );
    gh.lazySingleton<_i298.SettingsLocalDataSource>(
      () => _i298.SettingsLocalDataSourceImpl(),
    );
    gh.lazySingleton<_i513.MainLocalDataSource>(
      () => _i513.MainLocalDataSourceImpl(),
    );
    gh.lazySingleton<_i243.AuthInterceptor>(
      () => _i243.AuthInterceptor(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i923.AboutLocalDataSource>(
      () => _i923.AboutLocalDataSourceImpl(),
    );
    gh.lazySingleton<_i361.Dio>(
      () => dioModule.dio(gh<_i243.AuthInterceptor>()),
    );
    gh.lazySingleton<_i751.HttpClient>(
      () => _i608.DioHttpClient(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i949.AboutRemoteDataSource>(
      () => _i949.AboutRemoteDataSourceImpl(gh<_i751.HttpClient>()),
    );
    gh.lazySingleton<_i65.SettingsRemoteDataSource>(
      () => _i65.SettingsRemoteDataSourceImpl(gh<_i751.HttpClient>()),
    );
    gh.lazySingleton<_i402.HomeRemoteDataSource>(
      () => _i402.HomeRemoteDataSourceImpl(gh<_i751.HttpClient>()),
    );
    gh.lazySingleton<_i870.HomeRepository>(
      () => _i222.HomeRepositoryImpl(
        gh<_i402.HomeRemoteDataSource>(),
        gh<_i451.HomeLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i292.SettingsRepository>(
      () => _i713.SettingsRepositoryImpl(
        gh<_i65.SettingsRemoteDataSource>(),
        gh<_i298.SettingsLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i53.AboutRepository>(
      () => _i122.AboutRepositoryImpl(
        gh<_i949.AboutRemoteDataSource>(),
        gh<_i923.AboutLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i399.MainRemoteDataSource>(
      () => _i399.MainRemoteDataSourceImpl(gh<_i751.HttpClient>()),
    );
    gh.lazySingleton<_i917.MainRepository>(
      () => _i1043.MainRepositoryImpl(
        gh<_i399.MainRemoteDataSource>(),
        gh<_i513.MainLocalDataSource>(),
      ),
    );
    return this;
  }
}

class _$SecureStorageModule extends _i1062.SecureStorageModule {}

class _$DioModule extends _i642.DioModule {}
