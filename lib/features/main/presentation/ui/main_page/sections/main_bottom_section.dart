part of '../main_page.dart';

class _MainBottomSection extends ConsumerWidget {
  const _MainBottomSection({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BottomNavigationBar(
      currentIndex: navigationShell.currentIndex,
      onTap: (index) => _onTap(ref, index),
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

  void _onTap(WidgetRef ref, int index) {
    NavUtils.updateIndex(ref, index);
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
