import 'dart:async';

import 'package:benaiah_app/core/router/route_names.dart';
import 'package:benaiah_app/core/widgets/benaiah_network_image.dart';
import 'package:benaiah_app/core/widgets/benaiah_state_view.dart';
import 'package:benaiah_app/core/widgets/shimmer.dart';
import 'package:benaiah_app/features/podcast/domain/entities/podcast_host.dart';
import 'package:benaiah_app/features/podcast/presentation/providers/podcast_list_notifier.dart';
import 'package:benaiah_app/features/podcast/presentation/ui/widgets/podcast_episode_tile.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'screen/podcast_host_screen.dart';
part 'sections/podcast_host_body_section.dart';

/// Every episode a narrator/host worked on, and their bio — the podcast
/// equivalent of `AuthorArticlesPage`, which authors and graphic designers
/// already had.
class PodcastHostPage extends ConsumerWidget {
  const PodcastHostPage({required this.hostId, super.key});

  final String hostId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _PodcastHostScreen(hostId: hostId);
  }
}
