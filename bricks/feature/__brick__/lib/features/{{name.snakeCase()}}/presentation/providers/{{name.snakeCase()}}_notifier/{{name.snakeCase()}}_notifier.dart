import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/repositories/{{name.snakeCase()}}_repository.dart';
import 'package:benaiah_app/core/di/injection.dart';

part '{{name.snakeCase()}}_notifier.g.dart';

@riverpod
class {{name.pascalCase()}}Notifier extends _${{name.pascalCase()}}Notifier {
  late final {{name.pascalCase()}}Repository _repository;

  @override
  void build() {
    _repository = container<{{name.pascalCase()}}Repository>();
  }
}
