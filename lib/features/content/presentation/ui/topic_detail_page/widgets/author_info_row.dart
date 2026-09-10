part of '../topic_detail_page.dart';

class _AuthorInfoRow extends StatelessWidget {
  const _AuthorInfoRow({required this.author});
  final Author author;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          unawaited(
            context.pushNamed(
              RouteNames.authorArticles,
              pathParameters: {'authorId': author.id},
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: BenaiahNetworkImage(
                  imageUrl: author.profileImageUrl ?? '',
                  width: 40,
                  height: 40,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  author.localizedName(context.locale.languageCode),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.grey[500],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
