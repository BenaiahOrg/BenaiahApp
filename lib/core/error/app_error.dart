sealed class AppError {
  const AppError();

  String get userMessage;
}

final class NetworkError extends AppError {
  const NetworkError({this.message = 'No internet connection.'});

  final String message;

  @override
  String get userMessage => message;
}

final class ServerError extends AppError {
  const ServerError({required this.statusCode, required this.message});

  final int statusCode;
  final String message;

  @override
  String get userMessage => message;
}

final class GenericError extends AppError {
  const GenericError({required this.stackTrace, this.cause});

  final StackTrace stackTrace;
  final Object? cause;

  @override
  String get userMessage => 'Something went wrong. Please try again.';
}
