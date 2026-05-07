part of '../home_page.dart';

class _FeaturedCarousel extends StatefulWidget {
  const _FeaturedCarousel({required this.seriesList});

  final List<Series> seriesList;

  @override
  State<_FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<_FeaturedCarousel> {
  late final List<Topic> _featuredTopics;
  late final PageController _pageController;

  double _scrollPosition = 0;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _featuredTopics = widget.seriesList
        .expand((s) => s.topics)
        .take(5)
        .toList();

    final initialPage = _featuredTopics.isNotEmpty
        ? _featuredTopics.length ~/ 2
        : 0;

    _currentPage = initialPage;
    _scrollPosition = initialPage.toDouble();

    _pageController = PageController(
      viewportFraction: 0.80, // Changed from 0.86 to bring side cards closer
      initialPage: initialPage,
    );

    _pageController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_pageController.hasClients) {
      setState(() {
        _scrollPosition = _pageController.page ?? _currentPage.toDouble();
        _currentPage = _scrollPosition.round();
      });
    }
  }

  @override
  void dispose() {
    _pageController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_featuredTopics.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 320,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _featuredTopics.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final topic = _featuredTopics[index];
              final pageOffset = index - _scrollPosition;

              // Clamped beautiful scale factor
              final scale = (1 - (pageOffset.abs() * 0.08)).clamp(0.85, 1.0);

              // Gorgeous 3D cylindrical rotation perspective
              final rotationAngle = (pageOffset * -0.15).clamp(-0.25, 0.25);

              // Gentle depth translateY curve
              final translateY = pageOffset.abs() * 6;

              final transform = Matrix4.identity()
                ..setEntry(3, 2, 0.001) // subtle perspective
                ..translateByDouble(0, translateY, 0, 1)
                ..rotateY(rotationAngle)
                ..scaleByDouble(scale, scale, 1, 1);

              return Transform(
                transform: transform,
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _FeaturedTopicHero(
                    topic: topic,
                    scrollOffset: pageOffset,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        _SmoothPageIndicator(
          count: _featuredTopics.length,
          scrollPosition: _scrollPosition,
          activeColor: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }
}

class _SmoothPageIndicator extends StatelessWidget {
  const _SmoothPageIndicator({
    required this.count,
    required this.scrollPosition,
    required this.activeColor,
  });

  final int count;
  final double scrollPosition;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (index) {
          // Absolute distance from current scroll position
          final distance = (index - scrollPosition).abs();

          // Interpolate factor: 1.0 at active center, 0.0 when further
          final factor = (1 - distance).clamp(0.0, 1.0);

          // Width: 8 (inactive dot) to 24 (active pill)
          final width = 8 + (16 * factor);

          // Color fades smoothly between grey and active theme color
          final color = Color.lerp(
            Colors.grey.withAlpha(80),
            activeColor,
            factor,
          )!;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: width,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        },
      ),
    );
  }
}

class _FeaturedTopicHero extends StatelessWidget {
  const _FeaturedTopicHero({
    required this.topic,
    required this.scrollOffset,
  });

  final Topic topic;
  final double scrollOffset;

  @override
  Widget build(BuildContext context) {
    final hasImage = topic.graphics.data.isNotEmpty;
    final imageUrl = hasImage ? topic.graphics.data.first : '';

    // Calculate text content transition fading and shifting
    final contentFade = (1 - scrollOffset.abs() * 1.5).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(80),
            blurRadius: 16,
            spreadRadius: -4,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Color / Placeholder
            Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            // Hero Image with stunning parallax slide
            if (hasImage)
              Transform.scale(
                scale: 1.2,
                child: Transform.translate(
                  offset: Offset(scrollOffset * 30, 0),
                  child: Hero(
                    tag: 'topic_image_${topic.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BenaiahNetworkImage(
                        imageUrl: imageUrl,
                      ),
                    ),
                  ),
                ),
              ),
            // High-contrast Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withAlpha(50),
                    Colors.black.withAlpha(120),
                    Colors.black.withAlpha(220),
                  ],
                  stops: const [0, 0.4, 1],
                ),
              ),
            ),
            // Layered Parallax Content with dynamic fading
            Opacity(
              opacity: contentFade,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Glassmorphic FEATURED TOPIC badge
                    Transform.translate(
                      offset: Offset(scrollOffset * -15, 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(30),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withAlpha(60),
                              ),
                            ),
                            child: Text(
                              'FEATURED TOPIC'.tr(),
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Title with sub-parallax shift
                    Transform.translate(
                      offset: Offset(scrollOffset * -25, 0),
                      child: Hero(
                        tag: 'topic_title_${topic.id}',
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            topic.title,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Excerpt with separate shift speed
                    Transform.translate(
                      offset: Offset(scrollOffset * -35, 0),
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
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Colors.white.withAlpha(200),
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Premium navigation button with chevron and shadow
                    Transform.translate(
                      offset: Offset(scrollOffset * -45, 0),
                      child: ElevatedButton(
                        onPressed: () {
                          unawaited(
                            context.pushNamed(
                              RouteNames.topicDetail,
                              pathParameters: {'topicId': topic.id},
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          minimumSize: const Size(145, 46),
                          elevation: 4,
                          shadowColor: Colors.black.withAlpha(60),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Read Topic'.tr(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
