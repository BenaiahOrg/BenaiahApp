import 'dart:async';
import 'package:benaiah_app/core/router/route_names.dart';
import 'package:benaiah_app/core/utils/string_utils.dart';
import 'package:benaiah_app/core/widgets/benaiah_network_image.dart';
import 'package:benaiah_app/features/content/domain/entities/topic.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FeaturedTopicHero extends StatelessWidget {
  const FeaturedTopicHero({
    required this.topic,
    required this.scrollOffset,
    super.key,
  });

  final Topic topic;
  final double scrollOffset;

  /// The catalog carries a subtopic description but no article text, so prefer
  /// the description and fall back to the devotional only once it is loaded.
  String _excerpt(BuildContext context, Topic topic) {
    final lang = context.locale.languageCode;

    final description = topic.localizedDescription(lang);
    if (description.isNotEmpty) return description;

    final devotional = topic.localizedDevotional(lang).data;
    if (devotional.isNotEmpty) return StringUtils.stripMarkdown(devotional);

    return 'Explore this topic in depth.'.tr();
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = topic.graphics.data.isNotEmpty;
    final imageUrl = hasImage ? topic.graphics.data.first : '';

    // Calculate text content transition fading and shifting
    final contentFade = (1 - scrollOffset.abs() * 1.5).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(80),
            blurRadius: 16,
            spreadRadius: -4,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              unawaited(
                context.pushNamed(
                  RouteNames.topicDetail,
                  pathParameters: {'topicId': topic.id},
                ),
              );
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background Color / Placeholder
                Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                // Hero Image with stunning parallax slide
                if (hasImage)
                  Hero(
                    tag: 'topic_image_${topic.id}',
                    child: Transform.scale(
                      scale: 1.2,
                      child: Transform.translate(
                        offset: Offset(scrollOffset * 30, 0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BenaiahNetworkImage(
                            imageUrl: imageUrl,
                          ),
                        ),
                      ),
                    ),
                  ),
                // High-contrast Gradient Overlay (adaptive for theme brightness)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: Theme.of(context).brightness == Brightness.dark
                          ? [
                              Colors.black.withAlpha(20),
                              Colors.black.withAlpha(70),
                              Colors.black.withAlpha(140),
                            ]
                          : [
                              Colors.black.withAlpha(50),
                              Colors.black.withAlpha(120),
                              Colors.black.withAlpha(220),
                            ],
                      stops: const [0, 0.4, 1],
                    ),
                  ),
                ),
                // Layered Parallax Content with dynamic fading
                Opacity(
                  opacity: contentFade,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Frosted-look FEATURED TOPIC badge. A real
                        // BackdropFilter blur here would re-sample the image
                        // behind it on every scroll frame (this whole card
                        // rebuilds as the carousel drags); a flat translucent
                        // fill reads the same without the per-frame cost.
                        Transform.translate(
                          offset: Offset(scrollOffset * -15, 0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(30),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withAlpha(60),
                              ),
                            ),
                            child: Text(
                              'FEATURED TOPIC'.tr(),
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Title with sub-parallax shift
                        Hero(
                          tag: 'topic_title_${topic.id}',
                          child: Transform.translate(
                            offset: Offset(scrollOffset * -25, 0),
                            child: Material(
                              color: Colors.transparent,
                              child: Text(
                                topic.localizedTitle(
                                  context.locale.languageCode,
                                ),
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Excerpt with separate shift speed
                        Hero(
                          tag: 'topic_excerpt_${topic.id}',
                          child: Transform.translate(
                            offset: Offset(scrollOffset * -35, 0),
                            child: Material(
                              color: Colors.transparent,
                              child: Text(
                                _excerpt(context, topic),
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Colors.white.withAlpha(200),
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
