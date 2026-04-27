import 'package:benaiah_app/core/di/injection.dart';
import 'package:benaiah_app/features/about/domain/repositories/about_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'about_notifier.g.dart';

@riverpod
class AboutNotifier extends _$AboutNotifier {
  late final AboutRepository _repository;

  @override
  void build() {
    _repository = container<AboutRepository>();
  }
}
