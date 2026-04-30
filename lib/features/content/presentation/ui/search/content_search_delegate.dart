import 'package:benaiah_app/core/router/route_names.dart';
import 'package:benaiah_app/features/content/domain/entities/series.dart';
import 'package:benaiah_app/features/content/domain/entities/topic.dart';
import 'package:benaiah_app/features/content/presentation/providers/series_list_notifier.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ContentSearchDelegate extends SearchDelegate<String?> {
  ContentSearchDelegate(this.ref);

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
    final seriesListAsync = ref.watch(seriesListProvider);

    return seriesListAsync.when(
      data: (seriesList) {
        final queryLower = query.toLowerCase();
        final List<Series> matchedSeries = seriesList
            .where((s) =>
                s.title.toLowerCase().contains(queryLower) ||
                s.description.toLowerCase().contains(queryLower))
            .toList();

        final List<Topic> matchedTopics = seriesList
            .expand((s) => s.topics)
            .where((t) =>
                t.title.toLowerCase().contains(queryLower) ||
                t.devotional.data.toLowerCase().contains(queryLower) ||
                t.studyMaterial.data.toLowerCase().contains(queryLower))
            .toList();

        if (matchedSeries.isEmpty && matchedTopics.isEmpty) {
          return const Center(child: Text('No results found.'));
        }

        return ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            if (matchedSeries.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Series',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              ...matchedSeries.map((s) => ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        s.imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(s.title),
                    subtitle: Text(
                      s.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      close(context, null);
                      context.pushNamed(
                        RouteNames.seriesDetail,
                        pathParameters: {'seriesId': s.id},
                      );
                    },
                  )),
            ],
            if (matchedTopics.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Topics',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              ...matchedTopics.map((t) {
                final imageUrl = t.graphics.data.isNotEmpty
                    ? t.graphics.data.first
                    : 'https://picsum.photos/seed/${t.id}/200/200';
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(t.title),
                  subtitle: const Text('Read devotional & study material'),
                  onTap: () {
                    close(context, null);
                    context.pushNamed(
                      RouteNames.topicDetail,
                      pathParameters: {'topicId': t.id},
                    );
                  },
                );
              }),
            ],
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => const Center(child: Text('Error loading content.')),
    );
  }
}
