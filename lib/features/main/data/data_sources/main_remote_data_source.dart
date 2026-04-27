import 'package:benaiah_app/core/network/http_client.dart';
import 'package:injectable/injectable.dart';

abstract class MainRemoteDataSource {
  HttpClient get client;
}

@LazySingleton(as: MainRemoteDataSource)
class MainRemoteDataSourceImpl implements MainRemoteDataSource {
  MainRemoteDataSourceImpl(this.client);

  @override
  final HttpClient client;
}
