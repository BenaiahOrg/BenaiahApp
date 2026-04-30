part of '../main_page.dart';

class _MainTopSection extends StatelessWidget implements PreferredSizeWidget {
  const _MainTopSection({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    // Only show the shared AppBar for Home and Settings.
    // About page handles its own SliverAppBar.
    if (location == RouteNames.about || location == RouteNames.home) {
      return const SizedBox.shrink();
    }

    return AppBar(
      title: Text(_getTitle(location).tr()),
    );
  }

  String _getTitle(String location) {
    if (location == RouteNames.settings) return 'settings';
    return 'home';
  }

  @override
  Size get preferredSize => (location == RouteNames.about || location == RouteNames.home)
      ? Size.zero 
      : const Size.fromHeight(kToolbarHeight);
}
