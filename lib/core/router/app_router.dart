import 'package:benaiah_app/core/router/nav_direction_provider.dart';
import 'package:benaiah_app/core/router/route_names.dart';
import 'package:benaiah_app/core/router/router_redirect.dart';
import 'package:benaiah_app/core/router/router_refresh_listenable.dart';
import 'package:benaiah_app/features/about/presentation/ui/about_page/about_page.dart';
import 'package:benaiah_app/features/main/presentation/ui/main_page/main_page.dart';
import 'package:benaiah_app/features/settings/presentation/ui/settings_page/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainPage(child: child),
        routes: [
          GoRoute(
            path: RouteNames.home,
            name: RouteNames.home,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const SizedBox(), // TODO: Implement Home Content
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                final previousIndex = ref.read(previousNavIndexProvider);
                final currentIndex = ref.read(navIndexProvider);
                final begin = currentIndex >= previousIndex
                    ? const Offset(1, 0)
                    : const Offset(-1, 0);
                return SlideTransition(
                  position: animation.drive(
                    Tween<Offset>(begin: begin, end: Offset.zero)
                        .chain(CurveTween(curve: Curves.easeInOut)),
                  ),
                  child: child,
                );
              },
            ),
          ),
          GoRoute(
            path: RouteNames.settings,
            name: RouteNames.settings,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const SettingsPage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                final previousIndex = ref.read(previousNavIndexProvider);
                final currentIndex = ref.read(navIndexProvider);
                final begin = currentIndex >= previousIndex
                    ? const Offset(1, 0)
                    : const Offset(-1, 0);
                return SlideTransition(
                  position: animation.drive(
                    Tween<Offset>(begin: begin, end: Offset.zero)
                        .chain(CurveTween(curve: Curves.easeInOut)),
                  ),
                  child: child,
                );
              },
            ),
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.about,
        name: RouteNames.about,
        builder: (context, state) => const AboutPage(),
      ),
    ],
  );
});
