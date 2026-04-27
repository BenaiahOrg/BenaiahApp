import 'package:benaiah_app/features/settings/data/data_sources/settings_local_data_source.dart';
import 'package:benaiah_app/features/settings/data/data_sources/settings_remote_data_source.dart';
import 'package:benaiah_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: SettingsRepository)
class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._remoteDataSource, this._localDataSource);

  final SettingsRemoteDataSource _remoteDataSource;
  final SettingsLocalDataSource _localDataSource;
}
