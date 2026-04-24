part of '../{{name.snakeCase()}}_page.dart';

class _{{name.pascalCase()}}Screen extends ConsumerWidget {
  const _{{name.pascalCase()}}Screen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('{{name.pascalCase()}}'),
      ),
      body: const _{{name.pascalCase()}}BodySection(),
    );
  }
}
