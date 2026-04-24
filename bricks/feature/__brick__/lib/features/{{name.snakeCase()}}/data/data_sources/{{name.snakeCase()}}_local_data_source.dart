import 'package:injectable/injectable.dart';

abstract class {{name.pascalCase()}}LocalDataSource {}

@LazySingleton(as: {{name.pascalCase()}}LocalDataSource)
class {{name.pascalCase()}}LocalDataSourceImpl
    implements {{name.pascalCase()}}LocalDataSource {}
