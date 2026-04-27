import 'package:benaiah_app/core/network/http_client.dart';
import 'package:injectable/injectable.dart';

abstract class AboutRemoteDataSource {
  HttpClient get client;
}

@LazySingleton(as: AboutRemoteDataSource)
class AboutRemoteDataSourceImpl implements AboutRemoteDataSource {
  AboutRemoteDataSourceImpl(this.client);

  @override
  final HttpClient client;
}
