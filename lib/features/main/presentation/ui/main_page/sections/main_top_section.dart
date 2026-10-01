part of '../main_page.dart';

class _MainTopSection extends ConsumerWidget implements PreferredSizeWidget {
  const _MainTopSection({required this.location});

  final String location;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isBenaiahHeader =
        location == RouteNames.home || location == RouteNames.podcasts;

    return AppBar(
      centerTitle: false,
      title: isBenaiahHeader
          ? Image.asset(
              theme.brightness == Brightness.dark
                  ? Assets.images.wordmarkWhite.path
                  : Assets.images.wordmarkBlack.path,
              height: _wordmarkHeight,
              // Decoded at the size it is drawn, not the 1272px source.
              cacheHeight:
                  (_wordmarkHeight * MediaQuery.devicePixelRatioOf(context))
                      .round(),
              semanticLabel: 'Benaiah'.tr(),
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
            tooltip: MaterialLocalizations.of(context).searchFieldLabel,
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
            tooltip: MaterialLocalizations.of(context).searchFieldLabel,
          ),
      ],
    );
  }

  static const _wordmarkHeight = 32.0;

  String _getTitle(String location) {
    if (location == RouteNames.settings) return 'Settings';
    return '';
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
