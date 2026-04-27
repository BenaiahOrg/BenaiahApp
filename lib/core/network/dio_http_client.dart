import 'package:benaiah_app/core/network/http_client.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: HttpClient)
class DioHttpClient implements HttpClient {
  DioHttpClient(this._dio);

  final Dio _dio;

  @override
  Future<HttpResponse> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    String? baseUrl,
    Map<String, dynamic>? headers,
  }) => _execute(
    () => _dio.get<dynamic>(
      _buildUrl(endpoint, baseUrl),
      queryParameters: queryParameters,
      options: Options(headers: headers),
    ),
  );

  @override
  Future<HttpResponse> post(
    String endpoint, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    String? baseUrl,
    Map<String, dynamic>? headers,
  }) => _execute(
    () => _dio.post<dynamic>(
      _buildUrl(endpoint, baseUrl),
      data: data,
      queryParameters: queryParameters,
      options: Options(headers: headers),
    ),
  );

  @override
  Future<HttpResponse> put(
    String endpoint, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    String? baseUrl,
    Map<String, dynamic>? headers,
  }) => _execute(
    () => _dio.put<dynamic>(
      _buildUrl(endpoint, baseUrl),
      data: data,
      queryParameters: queryParameters,
      options: Options(headers: headers),
    ),
  );

  @override
  Future<HttpResponse> patch(
    String endpoint, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    String? baseUrl,
    Map<String, dynamic>? headers,
  }) => _execute(
    () => _dio.patch<dynamic>(
      _buildUrl(endpoint, baseUrl),
      data: data,
      queryParameters: queryParameters,
      options: Options(headers: headers),
    ),
  );

  @override
  Future<HttpResponse> delete(
    String endpoint, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    String? baseUrl,
    Map<String, dynamic>? headers,
  }) => _execute(
    () => _dio.delete<dynamic>(
      _buildUrl(endpoint, baseUrl),
      data: data,
      queryParameters: queryParameters,
      options: Options(headers: headers),
    ),
  );

  Future<HttpResponse> _execute(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      final response = await request();
      return _toHttpResponse(response);
    } on DioException catch (e) {
      rethrow;
    }
  }

  String _buildUrl(String endpoint, String? baseUrl) {
    if (baseUrl != null) return '$baseUrl$endpoint';
    return endpoint;
  }

  HttpResponse _toHttpResponse(Response<dynamic> response) {
    return HttpResponse(
      statusCode: response.statusCode ?? 0,
      data: response.data,
      headers: response.headers.map.map(
        (key, value) => MapEntry(key, value.join(', ')),
      ),
    );
  }
}
