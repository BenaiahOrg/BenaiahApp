part of '../topic_detail_page.dart';

class _AuthorInfoRow extends StatelessWidget {
  const _AuthorInfoRow({required this.author});
  final Author author;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Text(
            author.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
