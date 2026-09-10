part of '../author_articles_page.dart';

class _AuthorArticlesScreen extends ConsumerWidget {
  const _AuthorArticlesScreen({required this.authorId});

  final String authorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: _AuthorArticlesBodySection(authorId: authorId),
    );
  }
}
