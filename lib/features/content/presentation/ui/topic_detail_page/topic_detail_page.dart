import 'package:benaiah_app/core/error/app_error.dart';
import 'package:benaiah_app/core/utils/image_utils.dart';
import 'package:benaiah_app/features/content/domain/entities/author.dart';
import 'package:benaiah_app/features/content/domain/entities/topic.dart';
import 'package:benaiah_app/features/content/presentation/providers/topic_detail_notifier.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'screen/topic_detail_screen.dart';
part 'sections/topic_detail_body_section.dart';

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
