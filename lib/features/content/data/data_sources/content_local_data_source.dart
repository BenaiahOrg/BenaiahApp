import 'package:injectable/injectable.dart';

abstract class ContentLocalDataSource {}

@LazySingleton(as: ContentLocalDataSource)
class ContentLocalDataSourceImpl
    implements ContentLocalDataSource {}
