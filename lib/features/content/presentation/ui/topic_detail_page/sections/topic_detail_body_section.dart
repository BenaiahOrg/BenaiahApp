part of '../topic_detail_page.dart';

class _TopicDetailBodySection extends ConsumerWidget {
  const _TopicDetailBodySection({required this.topicId});

  /// 44px pills plus 6px above and below.
  static const _tabBarHeight = 56.0;

  final String topicId;

  // Nothing is pre-fetched here. A linkified article can cite ~20 passages,
  // and requesting them all at once gets the app rate-limited, so the
  // scripture overlay fetches on tap. Graphics are print-sized originals (up
  // to 4258x7543, ~128MB decoded); pre-caching them would evict every list
  // thumbnail from the image cache, so the grid loads screen-sized copies.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicAsync = ref.watch(topicDetailProvider(topicId));

    return topicAsync.when(
      data: (topic) {
        final imageUrl = topic.graphics.data.firstOrNull ?? '';
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;

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
                  leading: const ImageHeaderBackButton(),
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainer,
                  flexibleSpace: LayoutBuilder(
                    builder: (context, constraints) {
                      final mediaQuery = MediaQuery.of(context);
                      final minHeight =
                          kToolbarHeight +
                          mediaQuery.padding.top +
                          _tabBarHeight;
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

                      return ImageHeaderStatusBar(
                        overArtwork: t > 0.1,
                        child: FlexibleSpaceBar(
                          centerTitle: false,
                          titlePadding: EdgeInsetsDirectional.only(
                            start: 24.0 + (48.0 * (1.0 - t)),
                            // Clear of the tab bar pinned below the title.
                            bottom: _tabBarHeight + 12 + (4.0 * t),
                            end: 24,
                          ),
                          title: Hero(
                            tag: 'topic_title_${topic.id}',
                            child: Material(
                              color: Colors.transparent,
                              child: Text(
                                topic.localizedTitle(
                                  context.locale.languageCode,
                                ),
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
                                              borderRadius: radiusTween
                                                  .evaluate(
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
                              const ImageHeaderScrim(),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(_tabBarHeight),
                    // Rounded on top like the player sheet, so the artwork
                    // shows around its corners while the header is open.
                    // Collapsed, the bar behind is the same color and the
                    // corners disappear.
                    child: Material(
                      color: scheme.surfaceContainer,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                      ),
                      // The selected tab is a filled pill in the same colors
                      // as a selected podcast category chip, so the app has
                      // one look for "this one is chosen".
                      child: TabBar(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        labelColor: scheme.onPrimary,
                        unselectedLabelColor: scheme.onSurfaceVariant,
                        labelStyle: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        unselectedLabelStyle: theme.textTheme.titleSmall,
                        indicator: ShapeDecoration(
                          color: scheme.primary,
                          shape: const StadiumBorder(),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicatorPadding: const EdgeInsets.symmetric(
                          horizontal: 4,
                        ),
                        dividerColor: Colors.transparent,
                        splashBorderRadius: BorderRadius.circular(22),
                        tabs: [
                          for (final label in [
                            'Devotional',
                            'Study',
                            'Graphics',
                          ])
                            Tab(text: label.tr(), height: 44),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ];
          },
          // The embedded YouTube player renders through an OverlayPortal to
          // escape scroll clipping. This local Overlay keeps it scrolling
          // beneath the pinned SliverAppBar; on the root Overlay it would
          // paint above it.
          body: Overlay(
            initialEntries: [
              OverlayEntry(
                builder: (context) => _TabSwitchGuard(
                  child: TabBarView(
                    children: [
                      _DevotionalTab(topic: topic),
                      _StudyTab(topic: topic),
                      _GraphicsTab(topic: topic),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const _TopicDetailSkeleton(),
      error: (error, stack) => Scaffold(
        appBar: AppBar(),
        body: BenaiahStateView.error(
          error: error,
          onRetry: () => ref.invalidate(topicDetailProvider(topicId)),
        ),
      ),
    );
  }
}

/// Holds touches off the pages while a tapped tab is sliding into view.
///
/// Jumping two tabs (Graphics to Devotional) animates through the middle page.
/// A touch during that slide interrupts the page animation, which then settles
/// on the middle page while the tab bar still highlights the tapped one, so
/// the reader sees Study content under a Devotional tab.
class _TabSwitchGuard extends StatelessWidget {
  const _TabSwitchGuard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final controller = DefaultTabController.of(context);

    return AnimatedBuilder(
      animation: controller.animation!,
      builder: (context, child) => IgnorePointer(
        ignoring: controller.indexIsChanging,
        child: child,
      ),
      child: child,
    );
  }
}

class _TopicDetailSkeleton extends StatelessWidget {
  const _TopicDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Shimmer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: const [
            ShimmerBox(height: 300, borderRadius: 0),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // The three tab pills.
                  Row(
                    spacing: 8,
                    children: [
                      Expanded(child: ShimmerBox(height: 44, borderRadius: 22)),
                      Expanded(child: ShimmerBox(height: 44, borderRadius: 22)),
                      Expanded(child: ShimmerBox(height: 44, borderRadius: 22)),
                    ],
                  ),
                  SizedBox(height: 20),
                  ShimmerBox(height: 14, borderRadius: 4),
                  SizedBox(height: 8),
                  ShimmerBox(height: 14, borderRadius: 4),
                  SizedBox(height: 8),
                  ShimmerBox(width: 200, height: 14, borderRadius: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
