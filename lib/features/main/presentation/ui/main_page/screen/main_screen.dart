part of '../main_page.dart';

class _MainScreen extends ConsumerWidget {
  const _MainScreen({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;

    return Scaffold(
      appBar: _MainTopSection(location: location),
      body: SafeArea(
        child: child,
      ),
      bottomNavigationBar: const _MainBottomSection(),
    );
  }
}
