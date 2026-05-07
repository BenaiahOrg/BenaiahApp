part of '../topic_detail_page.dart';

class _GraphicsTab extends StatelessWidget {
  const _GraphicsTab({required this.topic});
  final Topic topic;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return CustomScrollView(
          key: const PageStorageKey('graphics'),
          slivers: [
            SliverOverlapInjector(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            ),
            if (topic.graphics.data.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final imageUrl =
                          'https://picsum.photos/seed/${topic.id}_$index/800/600';
                      return _GraphicItem(
                        imageUrl: imageUrl,
                        topicTitle: topic.title,
                      );
                    },
                    childCount: 3,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final imageUrl = topic.graphics.data[index];
                      return _GraphicItem(
                        imageUrl: imageUrl,
                        topicTitle: topic.title,
                      );
                    },
                    childCount: topic.graphics.data.length,
                  ),
                ),
              ),
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 48),
                    const Divider(),
                    const SizedBox(height: 24),
                    Text(
                      'Graphics by'.tr(),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            letterSpacing: 1.2,
                          ),
                    ),
                    const SizedBox(height: 16),
                    ...topic.graphics.authors.map(
                      (author) => _AuthorInfoRow(author: author),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        );
      },
    );
  }
}
