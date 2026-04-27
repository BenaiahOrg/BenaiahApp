import 'package:injectable/injectable.dart';

abstract class AboutLocalDataSource {}

@LazySingleton(as: AboutLocalDataSource)
class AboutLocalDataSourceImpl
    implements AboutLocalDataSource {}
