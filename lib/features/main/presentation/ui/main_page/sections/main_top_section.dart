part of '../main_page.dart';

class _MainTopSection extends StatelessWidget implements PreferredSizeWidget {
  const _MainTopSection({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(_getTitle(location).tr()),
    );
  }

  String _getTitle(String location) {
    if (location == RouteNames.settings) return 'Settings';
    return 'Home';
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
