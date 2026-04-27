import 'package:benaiah_app/core/network/http_client.dart';
import 'package:injectable/injectable.dart';

abstract class HomeRemoteDataSource {
  HttpClient get client;
}

@LazySingleton(as: HomeRemoteDataSource)
class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  HomeRemoteDataSourceImpl(this.client);

  @override
  final HttpClient client;
}
