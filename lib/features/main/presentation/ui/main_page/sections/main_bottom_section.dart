part of '../main_page.dart';

class _MainBottomSection extends ConsumerWidget {
  const _MainBottomSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BottomNavigationBar(
      currentIndex: _getCurrentIndex(location),
      onTap: (index) => _onTap(context, ref, index),
      selectedItemColor: isDark ? Colors.white : Colors.black,
      unselectedItemColor: Colors.grey,
      backgroundColor: isDark ? Colors.black : Colors.white,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_outlined),
          activeIcon: const Icon(Icons.home),
          label: 'Home'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.podcasts_outlined),
          activeIcon: const Icon(Icons.podcasts),
          label: 'Podcasts'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings_outlined),
          activeIcon: const Icon(Icons.settings),
          label: 'Settings'.tr(),
        ),
      ],
    );
  }

  int _getCurrentIndex(String location) {
    if (location == RouteNames.podcasts) return 1;
    if (location == RouteNames.settings) return 2;
    return 0;
  }

  void _onTap(BuildContext context, WidgetRef ref, int index) {
    NavUtils.updateIndex(ref, index);
    switch (index) {
      case 0:
        context.go(RouteNames.home);
      case 1:
        context.go(RouteNames.podcasts);
      case 2:
        context.go(RouteNames.settings);
    }
  }
}
