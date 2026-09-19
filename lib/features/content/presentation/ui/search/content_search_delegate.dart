import 'dart:async';

import 'package:benaiah_app/core/router/route_names.dart';
import 'package:benaiah_app/core/widgets/benaiah_network_image.dart';
import 'package:benaiah_app/core/widgets/benaiah_state_view.dart';
import 'package:benaiah_app/core/widgets/shimmer.dart';
import 'package:benaiah_app/features/content/presentation/providers/series_list_notifier.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ContentSearchDelegate extends SearchDelegate<String?> {
  ContentSearchDelegate(this.ref)
      : super(searchFieldLabel: 'Search series and topics'.tr());

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
        final lang = context.locale.languageCode;
        final queryLower = query.trim().toLowerCase();

        bool matches(List<String> fields) {
          if (queryLower.isEmpty) return true;
          return fields.any((f) => f.toLowerCase().contains(queryLower));
        }

        final matchedSeries = seriesList
            .where((s) => matches([s.titleEn, s.titleAm, s.description]))
            .toList();

        final matchedTopics = seriesList
            .expand((s) => s.topics)
            .where((t) => matches([t.titleEn, t.titleAm]))
            .toList();

        if (matchedSeries.isEmpty && matchedTopics.isEmpty) {
          return BenaiahStateView.empty(
            icon: Icons.search_off_rounded,
            title: 'No results found.'.tr(),
          );
        }

        return ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            if (matchedSeries.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Series'.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...matchedSeries.map(
                (s) => ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: BenaiahNetworkImage(
                      imageUrl: s.imageUrl,
                      width: 50,
                      height: 50,
                    ),
                  ),
                  title: Text(s.localizedTitle(lang)),
                  subtitle: Text(
                    '{} Topics'.tr(args: ['${s.topics.length}']),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    close(context, null);
                    unawaited(
                      context.pushNamed(
                        RouteNames.seriesDetail,
                        pathParameters: {'seriesId': s.id},
                      ),
                    );
                  },
                ),
              ),
            ],
            if (matchedTopics.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Topics'.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...matchedTopics.map((t) {
                final imageUrl = t.graphics.data.firstOrNull ?? '';
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: BenaiahNetworkImage(
                      imageUrl: imageUrl,
                      width: 50,
                      height: 50,
                    ),
                  ),
                  title: Text(t.localizedTitle(lang)),
                  subtitle: Text(
                    'Read devotional, study material & graphics'.tr(),
                  ),
                  onTap: () {
                    close(context, null);
                    unawaited(
                      context.pushNamed(
                        RouteNames.topicDetail,
                        pathParameters: {'topicId': t.id},
                      ),
                    );
                  },
                );
              }),
            ],
          ],
        );
      },
      loading: () => const SkeletonPlainList(),
      error: (e, st) => BenaiahStateView.error(
        error: e,
        onRetry: () => ref.invalidate(seriesListProvider),
      ),
    );
  }
}
