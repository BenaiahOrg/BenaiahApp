import 'package:benaiah_app/core/router/nav_direction_provider.dart';
import 'package:benaiah_app/core/router/route_names.dart';
import 'package:benaiah_app/features/podcast/presentation/ui/widgets/floating_podcast_player.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:async';
import 'package:benaiah_app/features/content/presentation/ui/search/content_search_delegate.dart';
import 'package:benaiah_app/features/podcast/presentation/ui/search/podcast_search_delegate.dart';

part 'screen/main_screen.dart';
part 'sections/main_top_section.dart';
part 'sections/main_body_section.dart';
part 'sections/main_bottom_section.dart';

class MainPage extends ConsumerWidget {
  const MainPage({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _MainScreen(navigationShell: navigationShell);
  }
}
