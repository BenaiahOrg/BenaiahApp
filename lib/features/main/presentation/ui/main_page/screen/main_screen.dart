part of '../main_page.dart';

class _MainScreen extends ConsumerWidget {
  const _MainScreen({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;

    final isSpecialPage = location == RouteNames.home || location == RouteNames.about;

    return Scaffold(
      appBar: isSpecialPage ? null : _MainTopSection(location: location),
      body: isSpecialPage ? child : SafeArea(child: child),
      bottomNavigationBar: const _MainBottomSection(),
    );
  }
}
