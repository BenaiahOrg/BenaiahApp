import 'dart:async';

import 'package:benaiah_app/core/network/bible_service.dart';
import 'package:benaiah_app/core/router/route_names.dart';
import 'package:benaiah_app/core/utils/image_utils.dart';
import 'package:benaiah_app/core/utils/string_utils.dart';
import 'package:benaiah_app/core/widgets/benaiah_markdown.dart';
import 'package:benaiah_app/core/widgets/benaiah_state_view.dart';
import 'package:benaiah_app/core/widgets/benaiah_network_image.dart';
import 'package:benaiah_app/features/content/domain/entities/author.dart';
import 'package:benaiah_app/features/content/domain/entities/topic.dart';
import 'package:benaiah_app/features/content/domain/entities/topic_content.dart';
import 'package:benaiah_app/features/content/presentation/providers/bible_passage_provider.dart';
import 'package:benaiah_app/features/content/presentation/providers/topic_detail_notifier.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

part 'screen/topic_detail_screen.dart';
part 'sections/devotional_tab_section.dart';
part 'sections/graphics_tab_section.dart';
part 'sections/study_tab_section.dart';
part 'sections/topic_detail_body_section.dart';
part 'widgets/author_info_row.dart';
part 'widgets/embedded_youtube_player.dart';
part 'widgets/graphic_item.dart';
part 'widgets/youtube_link_button.dart';

class TopicDetailPage extends ConsumerWidget {
  const TopicDetailPage({required this.topicId, super.key});

  final String topicId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: _TopicDetailScreen(topicId: topicId),
    );
  }
}
