part of '../topic_detail_page.dart';

class _StudyTab extends StatelessWidget {
  const _StudyTab({required this.topic});
  final Topic topic;

  @override
  Widget build(BuildContext context) {
    return _ArticleTab(
      content: topic.localizedStudyMaterial(context.locale.languageCode),
      bylineLabel: 'Study material by'.tr(),
      emptyTitle: 'Study material not available'.tr(),
      emptyMessage: 'This study material has not been published yet.'.tr(),
      storageKey: 'study',
    );
  }
}

/// Shared body for the devotional and study tabs: optional video, markdown,
/// then the byline for whichever language is on screen.
class _ArticleTab extends StatelessWidget {
  const _ArticleTab({
    required this.content,
    required this.bylineLabel,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.storageKey,
  });

  final TopicContent<String> content;
  final String bylineLabel;
  final String emptyTitle;
  final String emptyMessage;
  final String storageKey;

  @override
  Widget build(BuildContext context) {
    final youtubeUrl = content.youtubeUrl;
    final hasVideo = youtubeUrl != null && youtubeUrl.isNotEmpty;

    return CustomScrollView(
      key: PageStorageKey<String>(storageKey),
      slivers: [
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        if (content.data.isEmpty && !hasVideo)
          SliverFillRemaining(
            hasScrollBody: false,
            child: BenaiahStateView.empty(
              icon: Icons.menu_book_outlined,
              title: emptyTitle,
              message: emptyMessage,
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasVideo) ...[
                    if (StringUtils.tryGetYoutubeId(youtubeUrl) != null)
                      _EmbeddedYoutubePlayer(url: youtubeUrl)
                    else
                      _YouTubeLinkButton(url: youtubeUrl),
                    const SizedBox(height: 24),
                  ],
                  if (content.data.isNotEmpty)
                    BenaiahMarkdown(data: content.data)
                  else
                    BenaiahStateView.empty(
                      icon: Icons.menu_book_outlined,
                      title: emptyTitle,
                      message: emptyMessage,
                      compact: true,
                    ),
                  if (content.authors.isNotEmpty) ...[
                    const SizedBox(height: 48),
                    const Divider(),
                    const SizedBox(height: 24),
                    Text(
                      bylineLabel,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...content.authors.map(
                      (author) => _AuthorInfoRow(author: author),
                    ),
                  ],
                ],
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}
