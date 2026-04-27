import 'package:benaiah_app/core/di/injection.dart';
import 'package:benaiah_app/features/main/domain/repositories/main_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'main_notifier.g.dart';

@riverpod
class MainNotifier extends _$MainNotifier {
  late final MainRepository _repository;

  @override
  void build() {
    _repository = container<MainRepository>();
  }
}
