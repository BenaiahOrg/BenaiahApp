import 'package:benaiah_app/core/config/env.dart';
import 'package:benaiah_app/core/network/interceptors/auth_interceptor.dart';
import 'package:benaiah_app/core/network/interceptors/logging_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sentry_dio/sentry_dio.dart';

@module
abstract class DioModule {
  @lazySingleton
  Dio dio(AuthInterceptor authInterceptor) =>
      Dio(
          BaseOptions(
            baseUrl: Env.apiUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            sendTimeout: const Duration(seconds: 15),
            // Only `Accept` here. A default `Content-Type` would be sent on
            // bodyless GETs too, which pushes every request out of the CORS
            // "simple request" set and into a preflight the API answers with
            // 405. Dio still sets Content-Type automatically when there is a
            // body to describe.
            headers: {
              'Accept': 'application/json',
            },
          ),
        )
        ..addSentry()
        ..interceptors.addAll([
          authInterceptor,
          LoggingInterceptor(),
        ]);
}
