import 'package:benaiah_app/core/router/route_names.dart';
import 'package:benaiah_app/core/router/router_redirect.dart';
import 'package:benaiah_app/core/router/router_refresh_listenable.dart';
import 'package:benaiah_app/features/about/presentation/ui/about_page/about_page.dart';
import 'package:benaiah_app/features/content/presentation/ui/series_detail_page/series_detail_page.dart';
import 'package:benaiah_app/features/content/presentation/ui/topic_detail_page/topic_detail_page.dart';
import 'package:benaiah_app/features/home/presentation/ui/home_page/home_page.dart';
import 'package:benaiah_app/features/main/presentation/ui/main_page/main_page.dart';
import 'package:benaiah_app/features/podcast/presentation/ui/podcast_detail_page/podcast_detail_page.dart';
import 'package:benaiah_app/features/podcast/presentation/ui/podcast_page/podcast_page.dart';
import 'package:benaiah_app/features/settings/presentation/ui/settings_page/settings_page.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

final routerRefreshListenableProvider = Provider<RouterRefreshListenable>((
  ref,
) {
  return RouterRefreshListenable();
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ref.watch(routerRefreshListenableProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refreshListenable,
    redirect: routerRedirect,
    observers: [
      SentryNavigatorObserver(),
    ],
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainPage(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.home,
                name: RouteNames.home,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: HomePage(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.podcasts,
                name: RouteNames.podcasts,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: PodcastPage(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.settings,
                name: RouteNames.settings,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: SettingsPage(),
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.about,
        name: RouteNames.about,
        builder: (context, state) => const AboutPage(),
      ),
      GoRoute(
        path: RouteNames.topicDetail,
        name: RouteNames.topicDetail,
        builder: (context, state) {
          final topicId = state.pathParameters['topicId']!;
          return TopicDetailPage(topicId: topicId);
        },
      ),
      GoRoute(
        path: RouteNames.seriesDetail,
        name: RouteNames.seriesDetail,
        builder: (context, state) {
          final seriesId = state.pathParameters['seriesId']!;
          return SeriesDetailPage(seriesId: seriesId);
        },
      ),
      GoRoute(
        path: RouteNames.podcastDetail,
        name: RouteNames.podcastDetail,
        builder: (context, state) {
          final episodeId = state.pathParameters['episodeId']!;
          return PodcastDetailPage(episodeId: episodeId);
        },
      ),
    ],
  );
});
