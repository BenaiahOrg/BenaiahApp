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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            error is AppError
                ? error.userMessage
                : 'Error: {}'.tr(args: [error.toString()]),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
