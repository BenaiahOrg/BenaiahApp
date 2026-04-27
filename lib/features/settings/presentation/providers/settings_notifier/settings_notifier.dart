import 'package:benaiah_app/core/di/injection.dart';
import 'package:benaiah_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_notifier.g.dart';

@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  late final SettingsRepository _repository;

  @override
  void build() {
    _repository = container<SettingsRepository>();
  }
}
