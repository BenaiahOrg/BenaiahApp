import 'dart:async';

import 'package:benaiah_app/core/router/route_names.dart';
import 'package:benaiah_app/core/utils/date_time_utils.dart';
import 'package:benaiah_app/core/widgets/benaiah_network_image.dart';
import 'package:benaiah_app/features/podcast/domain/entities/podcast_episode.dart';
import 'package:benaiah_app/features/podcast/presentation/providers/podcast_list_notifier.dart';
import 'package:benaiah_app/features/podcast/presentation/providers/podcast_player_notifier.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'screen/podcast_screen.dart';
part 'widgets/featured_episode_banner.dart';
part 'widgets/podcast_category_chips.dart';
part 'widgets/podcast_episode_list_tile.dart';

class PodcastPage extends ConsumerWidget {
  const PodcastPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _PodcastScreen();
  }
}
