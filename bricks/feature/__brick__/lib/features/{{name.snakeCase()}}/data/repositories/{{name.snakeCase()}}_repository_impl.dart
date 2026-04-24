import 'package:injectable/injectable.dart';

import '../../domain/repositories/{{name.snakeCase()}}_repository.dart';
import '../data_sources/{{name.snakeCase()}}_remote_data_source.dart';
import '../data_sources/{{name.snakeCase()}}_local_data_source.dart';

@LazySingleton(as: {{name.pascalCase()}}Repository)
class {{name.pascalCase()}}RepositoryImpl implements {{name.pascalCase()}}Repository {
  {{name.pascalCase()}}RepositoryImpl(this._remoteDataSource, this._localDataSource);

  final {{name.pascalCase()}}RemoteDataSource _remoteDataSource;
  final {{name.pascalCase()}}LocalDataSource _localDataSource;
}
