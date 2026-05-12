part of '../main_page.dart';

class _MainScreen extends ConsumerWidget {
  const _MainScreen({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;

    final isSpecialPage = location == RouteNames.about;

    return Scaffold(
      appBar: isSpecialPage ? null : _MainTopSection(location: location),
      body: Stack(
        children: [
          isSpecialPage ? child : SafeArea(child: child),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingPodcastPlayer(),
          ),
        ],
      ),
      bottomNavigationBar: const _MainBottomSection(),
    );
  }
}
