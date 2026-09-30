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
      // Under 1 so the neighboring cards show at the edges.
      viewportFraction: 0.8,
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

              // Per page away from the center, a card shrinks 8% (to no less
              // than 85%), turns 0.15 rad about the Y axis (at most 0.25),
              // and drops 6 px, so the row looks like a curved surface.
              final scale = (1 - (pageOffset.abs() * 0.08)).clamp(0.85, 1.0);
              final rotationAngle = (pageOffset * -0.15).clamp(-0.25, 0.25);
              final translateY = pageOffset.abs() * 6;

              final transform = Matrix4.identity()
                ..setEntry(3, 2, 0.001) // perspective for rotateY
                ..translateByDouble(0, translateY, 0, 1)
                ..rotateY(rotationAngle)
                ..scaleByDouble(scale, scale, 1, 1);

              return Transform(
                transform: transform,
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: FeaturedTopicHero(
                    topic: topic,
                    scrollOffset: pageOffset,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        SmoothPageIndicator(
          count: _featuredTopics.length,
          scrollPosition: _scrollPosition,
          activeColor: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }
}
