import 'package:benaiah_app/core/network/interceptors/auth_interceptor.dart';
import 'package:benaiah_app/core/network/interceptors/logging_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@module
abstract class DioModule {
  @lazySingleton
  Dio dio(AuthInterceptor authInterceptor) =>
      Dio(
          BaseOptions(
            baseUrl: 'https://api.benaiah.org',
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            sendTimeout: const Duration(seconds: 15),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        )
        ..interceptors.addAll([
          authInterceptor,
          LoggingInterceptor(),
        ]);
}
