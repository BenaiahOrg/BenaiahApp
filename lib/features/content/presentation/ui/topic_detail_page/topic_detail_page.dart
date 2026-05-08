import 'dart:async';

import 'package:benaiah_app/core/error/app_error.dart';
import 'package:benaiah_app/core/network/bible_service.dart';
import 'package:benaiah_app/core/utils/image_utils.dart';
import 'package:benaiah_app/core/utils/string_utils.dart';
import 'package:benaiah_app/core/widgets/benaiah_markdown.dart';
import 'package:benaiah_app/core/widgets/benaiah_network_image.dart';
import 'package:benaiah_app/features/content/domain/entities/author.dart';
import 'package:benaiah_app/features/content/domain/entities/topic.dart';
import 'package:benaiah_app/features/content/presentation/providers/bible_passage_provider.dart';
import 'package:benaiah_app/features/content/presentation/providers/topic_detail_notifier.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'screen/topic_detail_screen.dart';
part 'sections/devotional_tab_section.dart';
part 'sections/graphics_tab_section.dart';
part 'sections/study_tab_section.dart';
part 'sections/topic_detail_body_section.dart';
part 'widgets/author_info_row.dart';
part 'widgets/floating_audio_player.dart';
part 'widgets/graphic_item.dart';

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
