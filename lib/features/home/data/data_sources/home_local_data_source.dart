import 'package:injectable/injectable.dart';

abstract class HomeLocalDataSource {}

@LazySingleton(as: HomeLocalDataSource)
class HomeLocalDataSourceImpl
    implements HomeLocalDataSource {}
