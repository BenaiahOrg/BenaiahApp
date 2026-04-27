import 'package:benaiah_app/features/about/data/data_sources/about_local_data_source.dart';
import 'package:benaiah_app/features/about/data/data_sources/about_remote_data_source.dart';
import 'package:benaiah_app/features/about/domain/repositories/about_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AboutRepository)
class AboutRepositoryImpl implements AboutRepository {
  AboutRepositoryImpl(this._remoteDataSource, this._localDataSource);

  final AboutRemoteDataSource _remoteDataSource;
  final AboutLocalDataSource _localDataSource;
}
