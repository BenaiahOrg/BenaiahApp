import 'dart:async';
import 'package:benaiah_app/core/error/app_error.dart';
import 'package:benaiah_app/core/widgets/benaiah_markdown.dart';
import 'package:benaiah_app/core/widgets/benaiah_network_image.dart';
import 'package:benaiah_app/core/utils/date_time_utils.dart';
import 'package:benaiah_app/features/podcast/domain/entities/podcast_episode.dart';
import 'package:benaiah_app/features/podcast/presentation/providers/podcast_detail_notifier.dart';
import 'package:benaiah_app/features/podcast/presentation/providers/podcast_player_notifier.dart';
import 'package:benaiah_app/features/podcast/presentation/ui/widgets/podcast_player_sheet.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'screen/podcast_detail_screen.dart';
part 'sections/podcast_detail_header_section.dart';
part 'sections/podcast_detail_body_section.dart';
part 'sections/podcast_detail_hosts_section.dart';

class PodcastDetailPage extends ConsumerWidget {
  const PodcastDetailPage({required this.episodeId, super.key});

  final String episodeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _PodcastDetailScreen(episodeId: episodeId);
  }
}
