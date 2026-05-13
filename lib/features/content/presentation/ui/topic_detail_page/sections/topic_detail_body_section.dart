part of '../topic_detail_page.dart';

class _TopicDetailBodySection extends ConsumerWidget {
  const _TopicDetailBodySection({required this.topicId});

  final String topicId;

  void _preFetchBiblePassages(
    WidgetRef ref,
    BuildContext context,
    Topic topic,
  ) {
    final lang = context.locale.languageCode;
    final markdownContent =
        '${topic.localizedDevotional(lang).data}\n${topic.localizedStudyMaterial(lang).data}';
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
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainer,
                  flexibleSpace: LayoutBuilder(
                    builder: (context, constraints) {
                      final mediaQuery = MediaQuery.of(context);
                      final minHeight =
                          kToolbarHeight + mediaQuery.padding.top + 48.0;
                      const maxHeight = 300.0;
                      final delta = maxHeight - minHeight;
                      final currentHeight = constraints.biggest.height;
                      final t = ((currentHeight - minHeight) / delta).clamp(
                        0.0,
                        1.0,
                      );

                      final titleColor =
                          Color.lerp(
                            Theme.of(context).colorScheme.onSurface,
                            Colors.white,
                            t,
                          ) ??
                          Colors.white;

                      final fontSize = 18.0 + (4.0 * t);

                      return FlexibleSpaceBar(
                        centerTitle: false,
                        titlePadding: EdgeInsetsDirectional.only(
                          start: 24.0 + (48.0 * (1.0 - t)),
                          bottom: 60.0 + (4.0 * t),
                          end: 24,
                        ),
                        title: Hero(
                          tag: 'topic_title_${topic.id}',
                          child: Material(
                            color: Colors.transparent,
                            child: Text(
                              topic.localizedTitle(context.locale.languageCode),
                              style: TextStyle(
                                color: titleColor,
                                fontWeight: FontWeight.bold,
                                fontSize: fontSize,
                                shadows: [
                                  Shadow(
                                    offset: const Offset(0, 1),
                                    blurRadius: 3,
                                    color: Colors.black.withValues(
                                      alpha: 0.54 * t,
                                    ),
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
                                flightShuttleBuilder:
                                    (
                                      flightContext,
                                      animation,
                                      flightDirection,
                                      fromHeroContext,
                                      toHeroContext,
                                    ) {
                                      final radiusTween = BorderRadiusTween(
                                        begin: BorderRadius.circular(16),
                                        end: BorderRadius.zero,
                                      );

                                      return AnimatedBuilder(
                                        animation: animation,
                                        builder: (context, child) {
                                          return ClipRRect(
                                            borderRadius: radiusTween.evaluate(
                                              animation,
                                            )!,
                                            child: toHeroContext.widget,
                                          );
                                        },
                                      );
                                    },
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
                              child: Opacity(
                                opacity: t,
                                child: Hero(
                                  tag: 'topic_excerpt_${topic.id}',
                                  child: Material(
                                    color: Colors.transparent,
                                    child: Text(
                                      topic
                                              .localizedDevotional(
                                                context.locale.languageCode,
                                              )
                                              .data
                                              .isNotEmpty
                                          ? StringUtils.stripMarkdown(
                                              topic
                                                  .localizedDevotional(
                                                    context.locale.languageCode,
                                                  )
                                                  .data,
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
