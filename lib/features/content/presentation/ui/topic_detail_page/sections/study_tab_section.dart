part of '../topic_detail_page.dart';

class _StudyTab extends StatelessWidget {
  const _StudyTab({required this.topic});
  final Topic topic;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Builder(
          builder: (context) {
            return CustomScrollView(
              key: const PageStorageKey('study'),
              slivers: [
                SliverOverlapInjector(
                  handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                    context,
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(24),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BenaiahMarkdown(
                          data: topic.studyMaterial.data,
                        ),
                        const SizedBox(height: 48),
                        const Divider(),
                        const SizedBox(height: 24),
                        Text(
                          'Study material by'.tr(),
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                                letterSpacing: 1.2,
                              ),
                        ),
                        const SizedBox(height: 16),
                        ...topic.studyMaterial.authors.map(
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
          child: FloatingAudioPlayer(
            title: 'Study Narration'.tr(),
            subtitle: topic.title,
            totalDurationSeconds: 312, // 5:12
            imageUrl: topic.graphics.data.isNotEmpty
                ? topic.graphics.data.first
                : '',
          ),
        ),
      ],
    );
  }
}
