import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'screen/{{name.snakeCase()}}_screen.dart';
part 'sections/{{name.snakeCase()}}_body_section.dart';

class {{name.pascalCase()}}Page extends ConsumerWidget {
  const {{name.pascalCase()}}Page({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _{{name.pascalCase()}}Screen();
  }
}
