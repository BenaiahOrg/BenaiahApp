abstract interface class HttpClient {
  Future<HttpResponse> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    String? baseUrl,
    Map<String, dynamic>? headers,
  });

  Future<HttpResponse> post(
    String endpoint, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    String? baseUrl,
    Map<String, dynamic>? headers,
  });

  Future<HttpResponse> put(
    String endpoint, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    String? baseUrl,
    Map<String, dynamic>? headers,
  });

  Future<HttpResponse> patch(
    String endpoint, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    String? baseUrl,
    Map<String, dynamic>? headers,
  });

  Future<HttpResponse> delete(
    String endpoint, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    String? baseUrl,
    Map<String, dynamic>? headers,
  });
}

class HttpResponse {
  const HttpResponse({
    required this.statusCode,
    required this.data,
    this.headers = const {},
  });

  final int statusCode;
  final dynamic data;
  final Map<String, dynamic> headers;
}

enum HttpExceptionType {
  connectionTimeout,
  sendTimeout,
  receiveTimeout,
  connectionError,
  badResponse,
  cancel,
  unknown,
}

class HttpException implements Exception {
  const HttpException({
    required this.type,
    required this.message,
    this.statusCode,
    this.data,
  });

  final HttpExceptionType type;
  final String message;
  final int? statusCode;
  final dynamic data;

  @override
  String toString() => 'HttpException($type): $message';
}
