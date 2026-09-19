part of '../podcast_detail_page.dart';

class _PodcastDetailScreen extends ConsumerWidget {
  const _PodcastDetailScreen({required this.episodeId});

  final String episodeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final episodeAsync = ref.watch(podcastDetailProvider(episodeId));
    final theme = Theme.of(context);

    return Scaffold(
      body: episodeAsync.when(
        data: (episode) {
          return CustomScrollView(
            slivers: [
              _PodcastDetailHeaderSection(episode: episode),
              _PodcastDetailBodySection(episode: episode),
              _PodcastDetailHostsSection(episode: episode),
            ],
          );
        },
        loading: () => const _PodcastDetailSkeleton(),
        error: (error, stack) => BenaiahStateView.error(
          error: error,
          onRetry: () => ref.invalidate(podcastDetailProvider(episodeId)),
        ),
      ),
    );
  }
}

class _PodcastDetailSkeleton extends StatelessWidget {
  const _PodcastDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: const [
          ShimmerBox(height: 280, borderRadius: 0),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 220, height: 22, borderRadius: 4),
                SizedBox(height: 20),
                ShimmerBox(height: 48, borderRadius: 24),
                SizedBox(height: 28),
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
    );
  }
}
