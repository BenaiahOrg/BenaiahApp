import 'package:benaiah_app/core/di/injection.dart';
import 'package:benaiah_app/features/home/domain/repositories/home_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_notifier.g.dart';

@riverpod
class HomeNotifier extends _$HomeNotifier {
  late final HomeRepository _repository;

  @override
  void build() {
    _repository = container<HomeRepository>();
  }
}
