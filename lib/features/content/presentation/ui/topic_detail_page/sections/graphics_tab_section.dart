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
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverMasonryGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childCount: topic.graphics.data.isEmpty
                    ? 3
                    : topic.graphics.data.length,
                itemBuilder: (context, index) {
                  final imageUrl = topic.graphics.data.isEmpty
                      ? 'https://picsum.photos/seed/${topic.id}_$index/800/600'
                      : topic.graphics.data[index];
                  return _GraphicItem(
                    imageUrl: imageUrl,
                    topicTitle: topic.localizedTitle(
                      context.locale.languageCode,
                    ),
                  );
                },
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
