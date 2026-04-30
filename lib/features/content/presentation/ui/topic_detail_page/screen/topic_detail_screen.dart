part of '../topic_detail_page.dart';

class _TopicDetailScreen extends ConsumerWidget {
  const _TopicDetailScreen({required this.topicId});

  final String topicId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: _TopicDetailBodySection(topicId: topicId),
    );
  }
}
