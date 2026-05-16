part of '../main_page.dart';

class _MainScreen extends ConsumerWidget {
  const _MainScreen({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;

    final isSpecialPage = location == RouteNames.about;

    return Scaffold(
      appBar: isSpecialPage ? null : _MainTopSection(location: location),
      body: Stack(
        children: [
          isSpecialPage
              ? navigationShell
              : SafeArea(child: navigationShell),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingPodcastPlayer(),
          ),
        ],
      ),
      bottomNavigationBar: _MainBottomSection(navigationShell: navigationShell),
    );
  }
}
