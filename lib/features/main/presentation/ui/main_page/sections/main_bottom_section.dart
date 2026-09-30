part of '../main_page.dart';

/// The top-level sections, in branch order: icon, selected icon, label key.
const List<(IconData, IconData, String)> _destinations = [
  (Icons.home_outlined, Icons.home, 'Home'),
  (Icons.podcasts_outlined, Icons.podcasts, 'Podcasts'),
  (Icons.settings_outlined, Icons.settings, 'Settings'),
];

void _goBranch(
  WidgetRef ref,
  StatefulNavigationShell navigationShell,
  int index,
) {
  NavUtils.updateIndex(ref, index);
  navigationShell.goBranch(
    index,
    initialLocation: index == navigationShell.currentIndex,
  );
}

/// Bottom navigation bar for compact widths.
class _MainBottomSection extends ConsumerWidget {
  const _MainBottomSection({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NavigationBar(
      selectedIndex: navigationShell.currentIndex,
      onDestinationSelected: (index) =>
          _goBranch(ref, navigationShell, index),
      destinations: [
        for (final (icon, selectedIcon, label) in _destinations)
          NavigationDestination(
            icon: Icon(icon),
            selectedIcon: Icon(selectedIcon),
            label: label.tr(),
          ),
      ],
    );
  }
}

/// Navigation rail for tablets and landscape, where a bottom bar would
/// stretch three destinations across the full width.
class _MainNavigationRail extends ConsumerWidget {
  const _MainNavigationRail({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      right: false,
      child: NavigationRail(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) =>
            _goBranch(ref, navigationShell, index),
        labelType: NavigationRailLabelType.all,
        destinations: [
          for (final (icon, selectedIcon, label) in _destinations)
            NavigationRailDestination(
              icon: Icon(icon),
              selectedIcon: Icon(selectedIcon),
              label: Text(label.tr()),
            ),
        ],
      ),
    );
  }
}
