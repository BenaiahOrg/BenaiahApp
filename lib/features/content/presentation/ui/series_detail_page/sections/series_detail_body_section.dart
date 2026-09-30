part of '../series_detail_page.dart';

class _SeriesDetailBodySection extends ConsumerWidget {
  const _SeriesDetailBodySection({required this.seriesId});

  final String seriesId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seriesAsync = ref.watch(seriesDetailProvider(seriesId));

    return seriesAsync.when(
      data: (series) {
        final description = series.localizedDescription(
          context.locale.languageCode,
        );

        final contentInsets = AppLayout.readingInsets(context);

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 250,
              pinned: true,
              centerTitle: false,
              leading: const ImageHeaderBackButton(),
              backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
              flexibleSpace: LayoutBuilder(
                builder: (context, constraints) {
                  final mediaQuery = MediaQuery.of(context);
                  final minHeight = kToolbarHeight + mediaQuery.padding.top;
                  const maxHeight = 250.0;
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

                  return ImageHeaderStatusBar(
                    overArtwork: t > 0.1,
                    child: FlexibleSpaceBar(
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
                          const ImageHeaderScrim(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SliverPadding(
              padding: contentInsets.copyWith(top: 24, bottom: 24),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (description.isNotEmpty) ...[
                      Text(
                        'About this series'.tr(),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
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
              padding: contentInsets,
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
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const SkeletonList(),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(),
        body: BenaiahStateView.error(
          error: error,
          onRetry: () => ref.invalidate(seriesDetailProvider(seriesId)),
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
    final lang = context.locale.languageCode;

    return ContentListTile(
      imageUrl: topic.graphics.data.firstOrNull ?? '',
      title: topic.localizedTitle(lang),
      subtitle: topic.localizedDescription(lang),
      onTap: () {
        unawaited(
          context.pushNamed(
            RouteNames.topicDetail,
            pathParameters: {'topicId': topic.id},
          ),
        );
      },
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

/// Cycles the series' graphics behind the header with a slow crossfade. With
/// Reduce Motion on it shows one graphic and stays put.
class _SeriesGraphicsSlideshowState extends State<_SeriesGraphicsSlideshow> {
  late final List<String> _shuffledGraphics;
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();

    final allGraphics = <String>[];
    for (final topic in widget.series.topics) {
      allGraphics.addAll(topic.graphics.data);
    }

    _shuffledGraphics = allGraphics.isNotEmpty
        ? (List<String>.from(allGraphics)..shuffle())
        : const [];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final animate =
        _shuffledGraphics.length > 1 &&
        !MediaQuery.disableAnimationsOf(context);
    if (animate && _timer == null) {
      _timer = Timer.periodic(const Duration(seconds: 6), (_) {
        if (!mounted) return;
        setState(() {
          _currentPage = (_currentPage + 1) % _shuffledGraphics.length;
        });
      });
    } else if (!animate) {
      _timer?.cancel();
      _timer = null;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_shuffledGraphics.isEmpty) {
      return const BenaiahNetworkImage(imageUrl: '');
    }

    final imageUrl = _shuffledGraphics[_currentPage];
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 900),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeOutCubic,
      layoutBuilder: (current, previous) => Stack(
        fit: StackFit.expand,
        children: [...previous, ?current],
      ),
      child: BenaiahNetworkImage(
        key: ValueKey(imageUrl),
        imageUrl: imageUrl,
      ),
    );
  }
}
