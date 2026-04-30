part of '../home_page.dart';

class _HomeBodySection extends ConsumerWidget {
  const _HomeBodySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seriesListAsync = ref.watch(seriesListProvider);

    return seriesListAsync.when(
      data: (seriesList) {
        if (seriesList.isEmpty) return const SizedBox.shrink();

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const _HomeTopSection(),
            if (seriesList.isNotEmpty)
              SliverToBoxAdapter(
                child: _FeaturedCarousel(seriesList: seriesList),
              ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Text(
                      'All Series',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      child: const Text('View All'),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 24,
                  childAspectRatio: 0.75,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final series = seriesList[index];
                    return _SeriesCard(series: series);
                  },
                  childCount: seriesList.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
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

class _FeaturedCarousel extends StatefulWidget {
  const _FeaturedCarousel({required this.seriesList});

  final List<Series> seriesList;

  @override
  State<_FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<_FeaturedCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;
  late final List<Topic> _featuredTopics;

  @override
  void initState() {
    super.initState();
    // Gather featured topics (e.g. up to 5 from the available series)
    _featuredTopics = widget.seriesList
        .expand((s) => s.topics)
        .take(5)
        .toList();
        
    int initialPage = _featuredTopics.isNotEmpty ? _featuredTopics.length ~/ 2 : 0;
    _currentPage = initialPage;
    _pageController = PageController(viewportFraction: 0.85, initialPage: initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_featuredTopics.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 400,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemCount: _featuredTopics.length,
            itemBuilder: (context, index) {
              final topic = _featuredTopics[index];
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  final double offset = _pageController.position.haveDimensions
                      ? _pageController.page! - index
                      : (index == _currentPage ? 0.0 : 1.0);
                  
                  final double scale = (1 - (offset.abs() * 0.12)).clamp(0.0, 1.0);
                  final double opacity = (1 - (offset.abs() * 0.4)).clamp(0.0, 1.0);
                  
                  return Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..scale(scale)
                      ..rotateY(offset * 0.1),
                    alignment: Alignment.center,
                    child: Opacity(
                      opacity: opacity,
                      child: child,
                    ),
                  );
                },
                child: _FeaturedTopicHero(topic: topic),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _featuredTopics.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.withAlpha(80),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FeaturedTopicHero extends StatelessWidget {
  const _FeaturedTopicHero({required this.topic});

  final Topic topic;

  @override
  Widget build(BuildContext context) {
    final hasImage = topic.graphics.data.isNotEmpty;
    final imageUrl = hasImage ? topic.graphics.data.first : '';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Color / Placeholder
            Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            // Hero Image
            if (hasImage)
              Hero(
                tag: 'topic_image_${topic.id}',
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withAlpha(204),
                  ],
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'FEATURED TOPIC',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    topic.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    topic.devotional.data.isNotEmpty
                        ? topic.devotional.data
                        : 'Explore this topic in depth.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
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
                      minimumSize: const Size(140, 48),
                    ),
                    child: const Text('Read Topic'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeriesCard extends StatelessWidget {
  const _SeriesCard({required this.series});

  final Series series;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        unawaited(
          context.pushNamed(
            RouteNames.seriesDetail,
            pathParameters: {'seriesId': series.id},
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                image: DecorationImage(
                  image: NetworkImage(series.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            series.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '${series.topics.length} Topics',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
