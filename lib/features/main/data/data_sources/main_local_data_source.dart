import 'package:injectable/injectable.dart';

abstract class MainLocalDataSource {}

@LazySingleton(as: MainLocalDataSource)
class MainLocalDataSourceImpl
    implements MainLocalDataSource {}
