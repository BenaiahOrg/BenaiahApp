part of '../topic_detail_page.dart';

class _DevotionalTab extends StatelessWidget {
  const _DevotionalTab({required this.topic});
  final Topic topic;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Builder(
          builder: (context) {
            return CustomScrollView(
              key: const PageStorageKey('devotional'),
              slivers: [
                SliverOverlapInjector(
                  handle:
                      NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(24),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BenaiahMarkdown(
                          data: topic.devotional.data,
                        ),
                        const SizedBox(height: 48),
                        const Divider(),
                        const SizedBox(height: 24),
                        Text(
                          'Written by'.tr(),
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                    letterSpacing: 1.2,
                                  ),
                        ),
                        const SizedBox(height: 16),
                        ...topic.devotional.authors.map(
                          (author) => _AuthorInfoRow(author: author),
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          },
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _FloatingAudioPlayer(
            title: 'Devotional Narration'.tr(),
            subtitle: topic.title,
            totalDurationSeconds: 225, // 3:45
            imageUrl: topic.graphics.data.isNotEmpty
                ? topic.graphics.data.first
                : '',
          ),
        ),
      ],
    );
  }
}
