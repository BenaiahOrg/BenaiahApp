import 'package:benaiah_app/core/network/http_client.dart';
import 'package:injectable/injectable.dart';

abstract class SettingsRemoteDataSource {
  HttpClient get client;
}

@LazySingleton(as: SettingsRemoteDataSource)
class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  SettingsRemoteDataSourceImpl(this.client);

  @override
  final HttpClient client;
}
