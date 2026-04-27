part of '../home_page.dart';

class _HomeScreen extends ConsumerWidget {
  const _HomeScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      appBar: _HomeTopSection(),
      body: _HomeBodySection(),
      bottomNavigationBar: _HomeBottomSection(),
    );
  }
}
