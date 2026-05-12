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
