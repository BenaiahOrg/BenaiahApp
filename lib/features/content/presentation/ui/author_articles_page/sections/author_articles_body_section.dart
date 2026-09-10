part of '../author_articles_page.dart';

class _AuthorArticlesBodySection extends ConsumerWidget {
  const _AuthorArticlesBodySection({required this.authorId});

  final String authorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(authorProfileProvider(authorId));

    return profileAsync.when(
      data: (profile) => _AuthorProfileView(profile: profile),
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(),
        body: BenaiahStateView.error(
          error: error,
          onRetry: () => ref.invalidate(authorProfileProvider(authorId)),
        ),
      ),
    );
  }
}

class _AuthorProfileView extends StatelessWidget {
  const _AuthorProfileView({required this.profile});

  final AuthorProfile profile;

  @override
  Widget build(BuildContext context) {
    final lang = context.locale.languageCode;
    final author = profile.author;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          pinned: true,
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.surface,
          surfaceTintColor: Colors.transparent,
        ),
        SliverToBoxAdapter(
          child: _AuthorHeader(author: author, lang: lang),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
          sliver: SliverToBoxAdapter(
            child: Text(
              'Topics'.tr(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        if (profile.credits.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: BenaiahStateView.empty(
              icon: Icons.article_outlined,
              title: 'No articles found for this author'.tr(),
              compact: true,
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _AuthorCreditItem(
                    credit: profile.credits[index],
                    lang: lang,
                  );
                },
                childCount: profile.credits.length,
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 48)),
      ],
    );
  }
}

/// Square photo above the name, mirroring benaiah.org/team's presentation of
/// its authors, graphic designers, and narrators.
class _AuthorHeader extends StatelessWidget {
  const _AuthorHeader({required this.author, required this.lang});

  final Author author;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final role = author.localizedRole(lang);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BenaiahNetworkImage(
              imageUrl: author.profileImageUrl ?? '',
              width: 120,
              height: 120,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            author.localizedName(lang),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (role != null && role.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              role,
              style: theme.textTheme.titleSmall?.copyWith(
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AuthorCreditItem extends StatelessWidget {
  const _AuthorCreditItem({required this.credit, required this.lang});

  final AuthorCredit credit;
  final String lang;

  String _roleLabel(BuildContext context) {
    final labels = [
      if (credit.roles.contains(ArticleRole.devotional)) 'Devotional'.tr(),
      if (credit.roles.contains(ArticleRole.studyMaterial)) 'Study'.tr(),
      if (credit.roles.contains(ArticleRole.graphics)) 'Graphics'.tr(),
    ];
    return labels.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    final topic = credit.topic;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: topic.graphics.data.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: BenaiahNetworkImage(
                  imageUrl: topic.graphics.data.first,
                  width: 56,
                  height: 56,
                ),
              )
            : Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.article,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
        title: Text(
          topic.localizedTitle(lang),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(_roleLabel(context)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          unawaited(
            context.pushNamed(
              RouteNames.topicDetail,
              pathParameters: {'topicId': topic.id},
            ),
          );
        },
      ),
    );
  }
}
