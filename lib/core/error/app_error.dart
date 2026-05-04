import 'package:easy_localization/easy_localization.dart';

sealed class AppError implements Exception {
  const AppError();

  String get userMessage;
}

final class NetworkError extends AppError {
  const NetworkError({this.message = 'No internet connection.'});

  final String message;

  @override
  String get userMessage => message.tr();
}

final class ServerError extends AppError {
  const ServerError({required this.statusCode, required this.message});

  final int statusCode;
  final String message;

  @override
  String get userMessage => message.tr();
}

final class GenericError extends AppError {
  const GenericError({required this.stackTrace, this.cause});

  final StackTrace stackTrace;
  final Object? cause;

  @override
  String get userMessage => 'Something went wrong. Please try again.'.tr();
}
