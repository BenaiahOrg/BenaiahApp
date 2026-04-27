import 'package:benaiah_app/features/main/data/data_sources/main_local_data_source.dart';
import 'package:benaiah_app/features/main/data/data_sources/main_remote_data_source.dart';
import 'package:benaiah_app/features/main/domain/repositories/main_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: MainRepository)
class MainRepositoryImpl implements MainRepository {
  MainRepositoryImpl(this._remoteDataSource, this._localDataSource);

  final MainRemoteDataSource _remoteDataSource;
  final MainLocalDataSource _localDataSource;
}
