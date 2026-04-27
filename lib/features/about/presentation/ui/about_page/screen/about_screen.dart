part of '../about_page.dart';

class _AboutScreen extends HookConsumerWidget {
  const _AboutScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 1500),
    );

    useEffect(() {
      unawaited(animationController.forward());
      return null;
    }, []);

    final fadeAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeIn,
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
