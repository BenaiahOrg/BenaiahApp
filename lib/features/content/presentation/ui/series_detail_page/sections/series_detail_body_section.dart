part of '../series_detail_page.dart';

class _SeriesDetailBodySection extends ConsumerWidget {
  const _SeriesDetailBodySection({required this.seriesId});

  final String seriesId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seriesAsync = ref.watch(seriesDetailProvider(seriesId));

    return seriesAsync.when(
      data: (series) {
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 250,
              pinned: true,
              centerTitle: false,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
              flexibleSpace: LayoutBuilder(
                builder: (context, constraints) {
                  final mediaQuery = MediaQuery.of(context);
                  final minHeight = kToolbarHeight + mediaQuery.padding.top;
                  const maxHeight = 250.0;
                  final delta = maxHeight - minHeight;
                  final currentHeight = constraints.biggest.height;
                  final t =
                      ((currentHeight - minHeight) / delta).clamp(0.0, 1.0);

                  final titleColor = Color.lerp(
                        Theme.of(context).colorScheme.onSurface,
                        Colors.white,
                        t,
                      ) ??
                      Colors.white;

                  return FlexibleSpaceBar(
                    centerTitle: false,
                    titlePadding: EdgeInsetsDirectional.only(
                      start: 24.0 + (48.0 * (1.0 - t)),
                      bottom: 16.0 + (32.0 * t),
                      end: 24,
                    ),
                    title: Text(
                      series.localizedTitle(context.locale.languageCode),
                      style: TextStyle(
                        color: titleColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        _SeriesGraphicsSlideshow(series: series),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black87],
                            ),
                          ),
                        ),
                      ],
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
                    Text(
                      'About this series'.tr(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      series.localizedDescription(context.locale.languageCode),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Topics'.tr(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final topic = series.topics[index];
                    return _TopicItem(topic: topic);
                  },
                  childCount: series.topics.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 48)),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text(
          error is AppError
              ? error.userMessage
              : 'Error: {}'.tr(
                  args: [error.toString()],
                ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _TopicItem extends StatelessWidget {
  const _TopicItem({required this.topic});

  final Topic topic;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: topic.graphics.data.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: BenaiahNetworkImage(
                  imageUrl: topic.graphics.data.first,
                  width: 80,
                  height: 80,
                ),
              )
            : Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.article,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
        title: Text(
          topic.localizedTitle(context.locale.languageCode),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Text('Read devotional, study material & graphics'.tr()),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          unawaited(
            context.pushNamed(
              RouteNames.topicDetail,
              pathParameters: {'topicId': topic.id},
            ),
          );
        },
      ),
    );
  }
}

class _SeriesGraphicsSlideshow extends StatefulWidget {
  const _SeriesGraphicsSlideshow({required this.series});
  final Series series;

  @override
  State<_SeriesGraphicsSlideshow> createState() =>
      _SeriesGraphicsSlideshowState();
}

class _SeriesGraphicsSlideshowState extends State<_SeriesGraphicsSlideshow> {
  late final PageController _pageController;
  late final List<String> _shuffledGraphics;
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    final allGraphics = <String>[];
    for (final topic in widget.series.topics) {
      allGraphics.addAll(topic.graphics.data);
    }

    if (allGraphics.isNotEmpty) {
      _shuffledGraphics = List<String>.from(allGraphics)..shuffle();
      _startSlideshow();
    } else {
      _shuffledGraphics = const [];
    }
  }

  void _startSlideshow() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      if (_shuffledGraphics.length <= 1) return;

      setState(() {
        _currentPage = (_currentPage + 1) % _shuffledGraphics.length;
      });

      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_shuffledGraphics.isEmpty) {
      return const BenaiahNetworkImage(imageUrl: '');
    }

    return PageView.builder(
      controller: _pageController,
      itemCount: _shuffledGraphics.length,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return BenaiahNetworkImage(
          imageUrl: _shuffledGraphics[index],
        );
      },
    );
  }
}
