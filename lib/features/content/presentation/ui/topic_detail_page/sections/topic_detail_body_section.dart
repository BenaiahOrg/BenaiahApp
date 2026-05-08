part of '../topic_detail_page.dart';

class _TopicDetailBodySection extends ConsumerWidget {
  const _TopicDetailBodySection({required this.topicId});

  final String topicId;

  void _preFetchBiblePassages(
    WidgetRef ref,
    BuildContext context,
    Topic topic,
  ) {
    final markdownContent =
        '${topic.devotional.data}\n${topic.studyMaterial.data}';
    final bibleLinkRegex = RegExp(
      r'https?://(?:www\.)?bible\.com/bible/[^)\s"]+',
    );
    final matches = bibleLinkRegex.allMatches(markdownContent);

    for (final match in matches) {
      final href = match.group(0);
      if (href != null) {
        try {
          final parsed = BibleService.parseBibleLink(href);
          if (parsed != null) {
            final (passageId, bibleId) = parsed;
            final param = BiblePassageParam(
              passageId: passageId,
              bibleId: bibleId,
            );
            ref.read(biblePassageProvider(param));
          }
        } on Exception catch (e) {
          debugPrint('🚨 BenaiahApp pre-fetching error for link $href: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicAsync = ref.watch(topicDetailProvider(topicId));

    return topicAsync.when(
      data: (topic) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _preFetchBiblePassages(ref, context, topic);
        });

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
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainer,
                  flexibleSpace: LayoutBuilder(
                    builder: (context, constraints) {
                      final isCollapsed =
                          constraints.biggest.height <=
                          kToolbarHeight +
                              MediaQuery.of(context).padding.top +
                              48 +
                              20;
                      final titleColor = isCollapsed
                          ? Theme.of(context).colorScheme.onSurface
                          : Colors.white;

                      return FlexibleSpaceBar(
                        centerTitle: false,
                        titlePadding: EdgeInsetsDirectional.only(
                          start: isCollapsed ? 72 : 24,
                          bottom: isCollapsed ? 60 : 64,
                          end: 24,
                        ),
                        title: Hero(
                          tag: 'topic_title_${topic.id}',
                          child: Material(
                            color: Colors.transparent,
                            child: Text(
                              topic.title,
                              style: TextStyle(
                                color: titleColor,
                                fontWeight: FontWeight.bold,
                                fontSize: isCollapsed ? 18 : 22,
                                shadows: isCollapsed
                                    ? null
                                    : const [
                                        Shadow(
                                          offset: Offset(0, 1),
                                          blurRadius: 3,
                                          color: Colors.black54,
                                        ),
                                      ],
                              ),
                            ),
                          ),
                        ),
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (imageUrl.isNotEmpty)
                              Hero(
                                tag: 'topic_image_${topic.id}',
                                child: ClipRRect(
                                  child: BenaiahNetworkImage(
                                    imageUrl: imageUrl,
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
                            // Excerpt shown only when expanded
                            Positioned(
                              left: 24,
                              right: 24,
                              bottom: 104,
                              child: Hero(
                                  tag: 'topic_excerpt_${topic.id}',
                                  child: Material(
                                    color: Colors.transparent,
                                    child: Text(
                                      topic.devotional.data.isNotEmpty
                                          ? StringUtils.stripMarkdown(
                                              topic.devotional.data,
                                            )
                                          : 'Explore this topic in depth.'.tr(),
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11,
                                        fontWeight: FontWeight.normal,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
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
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      child: TabBar(
                        labelColor: Theme.of(context).colorScheme.primary,
                        unselectedLabelColor: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha(128),
                        indicatorColor: Theme.of(context).colorScheme.primary,
                        indicatorWeight: 3,
                        tabs: [
                          Tab(text: 'Devotional'.tr()),
                          Tab(text: 'Study'.tr()),
                          Tab(text: 'Graphics'.tr()),
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
          error is AppError
              ? error.userMessage
              : 'Error: {}'.tr(args: [error.toString()]),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
