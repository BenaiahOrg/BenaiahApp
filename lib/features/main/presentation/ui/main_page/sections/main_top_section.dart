part of '../main_page.dart';

class _MainTopSection extends ConsumerWidget implements PreferredSizeWidget {
  const _MainTopSection({required this.location});

  final String location;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isBenaiahHeader = location == RouteNames.home || location == RouteNames.podcasts;

    return AppBar(
      centerTitle: false,
      title: isBenaiahHeader
          ? Text(
              'BENAIAH'.tr(),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            )
          : Text(
              _getTitle(location).tr(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
      actions: [
        if (location == RouteNames.home)
          IconButton(
            onPressed: () {
              unawaited(
                showSearch<String?>(
                  context: context,
                  delegate: ContentSearchDelegate(ref),
                ),
              );
            },
            icon: const Icon(Icons.search),
          )
        else if (location == RouteNames.podcasts)
          IconButton(
            onPressed: () {
              unawaited(
                showSearch<String?>(
                  context: context,
                  delegate: PodcastSearchDelegate(ref),
                ),
              );
            },
            icon: const Icon(Icons.search),
          ),
      ],
    );
  }

  String _getTitle(String location) {
    if (location == RouteNames.settings) return 'Settings';
    return '';
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
