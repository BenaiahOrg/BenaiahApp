import 'package:injectable/injectable.dart';

abstract class PodcastLocalDataSource {}

@LazySingleton(as: PodcastLocalDataSource)
class PodcastLocalDataSourceImpl
    implements PodcastLocalDataSource {}
