import 'package:injectable/injectable.dart';
import 'package:benaiah_app/core/network/http_client.dart';

abstract class {{name.pascalCase()}}RemoteDataSource {
  HttpClient get client;
}

@LazySingleton(as: {{name.pascalCase()}}RemoteDataSource)
class {{name.pascalCase()}}RemoteDataSourceImpl
    implements {{name.pascalCase()}}RemoteDataSource {
  {{name.pascalCase()}}RemoteDataSourceImpl(this.client);

  @override
  final HttpClient client;
}
