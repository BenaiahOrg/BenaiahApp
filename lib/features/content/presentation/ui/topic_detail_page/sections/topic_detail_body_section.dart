part of '../topic_detail_page.dart';

class _TopicDetailBodySection extends ConsumerWidget {
  const _TopicDetailBodySection({required this.topicId});

  final String topicId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicAsync = ref.watch(topicDetailProvider(topicId));

    return topicAsync.when(
      data: (topic) {
        final hasImage = topic.graphics.data.isNotEmpty;
        final imageUrl = hasImage
            ? topic.graphics.data.first
            : 'https://picsum.photos/seed/${topic.id}/800/600';

        return NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverOverlapAbsorber(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                  context,
                ),
                sliver: SliverAppBar(
                  expandedHeight: 300,
                  pinned: true,
                  elevation: 0,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  flexibleSpace: LayoutBuilder(
                    builder: (context, constraints) {
                      final isCollapsed =
                          constraints.biggest.height <=
                          kToolbarHeight +
                              MediaQuery.of(context).padding.top +
                              48;
                      final titleColor = isCollapsed
                          ? Theme.of(context).colorScheme.onSurface
                          : Colors.white;

                      return FlexibleSpaceBar(
                        centerTitle: false,
                        titlePadding: const EdgeInsetsDirectional.only(
                          start: 56,
                          bottom: 64,
                        ),
                        title: Text(
                          topic.title,
                          style: TextStyle(
                            color: titleColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            shadows: const [
                              Shadow(
                                offset: Offset(0, 1),
                                blurRadius: 3,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                        ),
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (imageUrl.isNotEmpty)
                              Hero(
                                tag: 'topic_image_${topic.id}',
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                              )
                            else
                              Container(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            const DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black87,
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(48),
                    child: Material(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: TabBar(
                        labelColor: Theme.of(context).colorScheme.primary,
                        unselectedLabelColor: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha(128),
                        indicatorColor: Theme.of(context).colorScheme.primary,
                        indicatorWeight: 3,
                        tabs: const [
                          Tab(text: 'Devotional'),
                          Tab(text: 'Study'),
                          Tab(text: 'Graphics'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              _DevotionalTab(topic: topic),
              _StudyTab(topic: topic),
              _GraphicsTab(topic: topic),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text(
          error is AppError ? error.userMessage : 'Error: $error',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _AuthorInfoRow extends StatelessWidget {
  const _AuthorInfoRow({required this.author});
  final Author author;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: author.profileImageUrl != null
                ? NetworkImage(author.profileImageUrl!)
                : null,
            child: author.profileImageUrl == null
                ? Text(author.name[0].toUpperCase())
                : null,
          ),
          const SizedBox(width: 12),
          Text(
            author.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DevotionalTab extends StatelessWidget {
  const _DevotionalTab({required this.topic});
  final Topic topic;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return CustomScrollView(
          key: const PageStorageKey('devotional'),
          slivers: [
            SliverOverlapInjector(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic.devotional.data,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.8,
                        fontSize: 18,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 48),
                    const Divider(),
                    const SizedBox(height: 24),
                    Text(
                      'Written by',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
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
          ],
        );
      },
    );
  }
}

class _StudyTab extends StatelessWidget {
  const _StudyTab({required this.topic});
  final Topic topic;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return CustomScrollView(
          key: const PageStorageKey('study'),
          slivers: [
            SliverOverlapInjector(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic.studyMaterial.data,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.8,
                        fontSize: 18,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 48),
                    const Divider(),
                    const SizedBox(height: 24),
                    Text(
                      'Study material by',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
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
          ],
        );
      },
    );
  }
}

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
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        );
      },
    );
  }
}

class _GraphicItem extends StatelessWidget {
  const _GraphicItem({required this.imageUrl, required this.topicTitle});
  final String imageUrl;
  final String topicTitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(150),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () async {
                          try {
                            await ImageUtils.downloadAndSaveImage(imageUrl);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Image saved to gallery'),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Error downloading image'),
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.download, color: Colors.white),
                        tooltip: 'Download',
                      ),
                      IconButton(
                        onPressed: () => ImageUtils.shareImage(
                          imageUrl,
                          topicTitle,
                        ),
                        icon: const Icon(Icons.share, color: Colors.white),
                        tooltip: 'Share',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
