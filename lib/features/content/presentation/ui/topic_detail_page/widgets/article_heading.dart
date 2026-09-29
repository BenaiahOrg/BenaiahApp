part of '../topic_detail_page.dart';

/// Article title and publish date, as the site shows them above the body.
class _ArticleHeading extends StatelessWidget {
  const _ArticleHeading({required this.title, this.date});

  final String title;
  final String? date;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = this.date;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
        ),
        if (date != null) ...[
          const SizedBox(height: 8),
          Text(
            date,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(150),
              letterSpacing: 0.4,
            ),
          ),
        ],
      ],
    );
  }
}

/// The opening section heading. The server lifts it out of the body, so it is
/// drawn here to keep the article from starting mid-thought.
class _ArticleSectionHeader extends StatelessWidget {
  const _ArticleSectionHeader({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
          height: 1.4,
        ),
      ),
    );
  }
}
