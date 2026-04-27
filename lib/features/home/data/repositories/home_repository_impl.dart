import 'package:benaiah_app/features/home/data/data_sources/home_local_data_source.dart';
import 'package:benaiah_app/features/home/data/data_sources/home_remote_data_source.dart';
import 'package:benaiah_app/features/home/domain/repositories/home_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: HomeRepository)
class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl(this._remoteDataSource, this._localDataSource);

  final HomeRemoteDataSource _remoteDataSource;
  final HomeLocalDataSource _localDataSource;
}
