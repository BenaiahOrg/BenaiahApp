import 'dart:async';

import 'package:benaiah_app/core/router/route_names.dart';
import 'package:benaiah_app/core/widgets/benaiah_network_image.dart';
import 'package:benaiah_app/features/podcast/domain/entities/podcast_episode.dart';
import 'package:benaiah_app/features/podcast/presentation/providers/podcast_list_notifier.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PodcastSearchDelegate extends SearchDelegate<String?> {
  PodcastSearchDelegate(this.ref);

  final WidgetRef ref;

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildList(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildList(context);
  }

  Widget _buildList(BuildContext context) {
    final episodesAsync = ref.watch(podcastListProvider);

    return episodesAsync.when(
      data: (episodes) {
        final queryLower = query.toLowerCase();
        final matchedEpisodes = episodes.where((ep) {
          return ep.title.toLowerCase().contains(queryLower) ||
              ep.description.toLowerCase().contains(queryLower) ||
              ep.hosts.any((h) => h.name.toLowerCase().contains(queryLower)) ||
              ep.category.toLowerCase().contains(queryLower);
        }).toList();

        if (matchedEpisodes.isEmpty) {
          return Center(child: Text('No results found.'.tr()));
        }

        return ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Episodes'.tr(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...matchedEpisodes.map(
              (ep) => ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: BenaiahNetworkImage(
                    imageUrl: ep.imageUrl,
                    width: 50,
                    height: 50,
                  ),
                ),
                title: Text(ep.title),
                subtitle: Text(
                  ep.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  close(context, null);
                  unawaited(
                    context.push(
                      RouteNames.podcastDetail.replaceAll(':episodeId', ep.id),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error loading content.'.tr())),
    );
  }
}
