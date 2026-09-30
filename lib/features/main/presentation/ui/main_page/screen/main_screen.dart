part of '../main_page.dart';

class _MainScreen extends StatelessWidget {
  const _MainScreen({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    final isAboutPage = location == RouteNames.about;
    final useRail = MediaQuery.sizeOf(context).width >= AppLayout.mediumWidth;

    final content = Stack(
      children: [
        if (isAboutPage)
          navigationShell
        else
          // The rail already keeps clear of the left inset.
          SafeArea(left: !useRail, child: navigationShell),
        const Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: FloatingPodcastPlayer(),
        ),
      ],
    );

    // Home is the start destination: Back from Podcasts or Settings returns
    // there, and Back on Home leaves the app normally, so the system's
    // predictive back-to-home gesture keeps working.
    return PopScope(
      canPop: navigationShell.currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) navigationShell.goBranch(0);
      },
      child: Scaffold(
        appBar: isAboutPage ? null : _MainTopSection(location: location),
        body: useRail
            ? Row(
                children: [
                  _MainNavigationRail(navigationShell: navigationShell),
                  const VerticalDivider(width: 1, thickness: 1),
                  Expanded(child: content),
                ],
              )
            : content,
        bottomNavigationBar: useRail
            ? null
            : _MainBottomSection(navigationShell: navigationShell),
      ),
    );
  }
}
