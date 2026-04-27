import 'package:injectable/injectable.dart';

abstract class SettingsLocalDataSource {}

@LazySingleton(as: SettingsLocalDataSource)
class SettingsLocalDataSourceImpl
    implements SettingsLocalDataSource {}
