import 'dart:async';
import 'dart:ui';
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
                    // Glassmorphic FEATURED TOPIC badge
                    Transform.translate(
                      offset: Offset(scrollOffset * -15, 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
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
                            topic.title,
                            style: Theme.of(context).textTheme.headlineMedium
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
                            topic.devotional.data.isNotEmpty
                                ? StringUtils.stripMarkdown(
                                    topic.devotional.data,
                                  )
                                : 'Explore this topic in depth.'.tr(),
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
                    const SizedBox(height: 20),
                    // Premium navigation button with chevron and shadow
                    Transform.translate(
                      offset: Offset(scrollOffset * -45, 0),
                      child: ElevatedButton(
                        onPressed: () {
                          unawaited(
                            context.pushNamed(
                              RouteNames.topicDetail,
                              pathParameters: {'topicId': topic.id},
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          minimumSize: const Size(145, 46),
                          elevation: 4,
                          shadowColor: Colors.black.withAlpha(60),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Read Topic'.tr(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                            ),
                          ],
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
    );
  }
}
