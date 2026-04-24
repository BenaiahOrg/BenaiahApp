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
    gh.lazySingleton<_i243.AuthInterceptor>(
      () => _i243.AuthInterceptor(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i361.Dio>(
      () => dioModule.dio(gh<_i243.AuthInterceptor>()),
    );
    gh.lazySingleton<_i751.HttpClient>(
      () => _i608.DioHttpClient(gh<_i361.Dio>()),
    );
    return this;
  }
}

class _$SecureStorageModule extends _i1062.SecureStorageModule {}

class _$DioModule extends _i642.DioModule {}
