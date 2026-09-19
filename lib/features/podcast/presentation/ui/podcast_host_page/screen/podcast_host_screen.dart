part of '../podcast_host_page.dart';

class _PodcastHostScreen extends ConsumerWidget {
  const _PodcastHostScreen({required this.hostId});

  final String hostId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: _PodcastHostBodySection(hostId: hostId),
    );
  }
}
