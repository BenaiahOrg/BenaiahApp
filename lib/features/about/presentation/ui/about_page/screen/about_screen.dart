part of '../about_page.dart';

class _AboutScreen extends HookConsumerWidget {
  const _AboutScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 600),
    );

    // One short entrance that decelerates into place. With Reduce Motion on,
    // the page is simply there.
    useEffect(() {
      if (reduceMotion) {
        animationController.value = 1;
      } else {
        animationController.forward();
      }
      return null;
    }, []);

    final fadeAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOutCubic,
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _AboutTopSection(fadeAnimation: fadeAnimation),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: fadeAnimation,
              child: const _AboutBodySection(),
            ),
          ),
          const SliverToBoxAdapter(
            child: _AboutBottomSection(),
          ),
        ],
      ),
    );
  }
}
