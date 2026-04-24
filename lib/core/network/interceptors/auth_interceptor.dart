import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor(this._storage);

  final FlutterSecureStorage _storage;

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: _accessTokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    final refreshToken = await _storage.read(key: _refreshTokenKey);
    if (refreshToken == null) {
      return handler.next(err);
    }

    try {
      final dio = Dio(BaseOptions(baseUrl: err.requestOptions.baseUrl));
      final response = await dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      final newAccessToken = response.data?['access_token'] as String?;
      final newRefreshToken = response.data?['refresh_token'] as String?;

      if (newAccessToken != null) {
        await _storage.write(key: _accessTokenKey, value: newAccessToken);
        if (newRefreshToken != null) {
          await _storage.write(key: _refreshTokenKey, value: newRefreshToken);
        }

        err.requestOptions.headers['Authorization'] =
            'Bearer $newAccessToken';

        final retryResponse = await dio.fetch<dynamic>(err.requestOptions);
        return handler.resolve(retryResponse);
      }

      return handler.next(err);
    } on DioException {
      await _storage.deleteAll();
      return handler.next(err);
    }
  }
}
