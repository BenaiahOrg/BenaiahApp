part of '../topic_detail_page.dart';

class _DevotionalTab extends StatelessWidget {
  const _DevotionalTab({required this.topic});
  final Topic topic;

  @override
  Widget build(BuildContext context) {
    return _ArticleTab(
      content: topic.localizedDevotional(context.locale.languageCode),
      bylineLabel: 'Written by'.tr(),
      emptyTitle: 'Devotional not available'.tr(),
      emptyMessage: 'This devotional has not been published yet.'.tr(),
      storageKey: 'devotional',
    );
  }
}
