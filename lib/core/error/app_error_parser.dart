import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:benaiah_app/core/error/app_error.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

final class AppErrorParser {
  const AppErrorParser._();

  /// Single entry point: pass any caught error + stack trace,
  /// get back a typed [AppError].
  static AppError parse(Object error, StackTrace stackTrace) {
    if (error is SocketException) {
      return const NetworkError();
    }

    if (error is DioException) {
      return _parseDioException(error);
    }

    // Unknown error → report to Sentry, return generic message.
    unawaited(Sentry.captureException(error, stackTrace: stackTrace));
    return GenericError(stackTrace: stackTrace, cause: error);
  }

  static AppError _parseDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const NetworkError();
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 0;
        final data = error.response?.data;
        final message =
            _extractMessage(data) ?? _fallbackForCode(statusCode);
        return ServerError(
          statusCode: statusCode,
          message: message,
        );
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        unawaited(
          Sentry.captureException(error, stackTrace: error.stackTrace),
        );
        return GenericError(
          stackTrace: error.stackTrace,
          cause: error,
        );
    }
  }

  static String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] as String? ??
          data['error'] as String?;
    }
    return null;
  }

  static String _fallbackForCode(int code) => switch (code) {
        400 => 'Bad request.',
        401 => 'Session expired. Please log in again.',
        403 => 'You do not have permission to do that.',
        404 => 'Resource not found.',
        429 => 'Too many requests. Please slow down.',
        >= 500 => 'Server error. Our team has been notified.',
        _ => 'An unexpected error occurred.',
      };
}
