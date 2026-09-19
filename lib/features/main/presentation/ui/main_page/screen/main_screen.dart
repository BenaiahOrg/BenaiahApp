part of '../main_page.dart';

class _MainScreen extends ConsumerStatefulWidget {
  const _MainScreen({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<_MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<_MainScreen> {
  DateTime? _lastBackPressTime;

  /// Home is the app's effective root: back from Podcasts or Settings
  /// returns to Home instead of exiting, and a second back press within
  /// [_exitPressWindow] of the first is required to actually exit from Home.
  static const _exitPressWindow = Duration(seconds: 2);

  void _handleBack(bool didPop) {
    if (didPop) return;

    if (widget.navigationShell.currentIndex != 0) {
      widget.navigationShell.goBranch(0);
      return;
    }

    final now = DateTime.now();
    final isSecondPress = _lastBackPressTime != null &&
        now.difference(_lastBackPressTime!) < _exitPressWindow;

    if (isSecondPress) {
      unawaited(SystemNavigator.pop());
      return;
    }

    _lastBackPressTime = now;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text('Press back again to exit'.tr()),
          duration: _exitPressWindow,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    final isSpecialPage = location == RouteNames.about;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => _handleBack(didPop),
      child: Scaffold(
        appBar: isSpecialPage ? null : _MainTopSection(location: location),
        body: Stack(
          children: [
            isSpecialPage
                ? widget.navigationShell
                : SafeArea(child: widget.navigationShell),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: FloatingPodcastPlayer(),
            ),
          ],
        ),
        bottomNavigationBar: _MainBottomSection(
          navigationShell: widget.navigationShell,
        ),
      ),
    );
  }
}
