part of '../topic_detail_page.dart';

class _YouTubeLinkButton extends StatelessWidget {
  const _YouTubeLinkButton({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Sleek premium YouTube color palette
    final backgroundColor = isDark
        ? const Color(0xFF1E1E1E)
        : const Color(0xFFF9F9F9);
    final borderColor = isDark
        ? const Color(0xFF2C2C2C)
        : const Color(0xFFE5E5E5);
    final textColor = isDark ? Colors.white : Colors.black;

    return Center(
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () async {
            final uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Could not launch video link'.tr())),
                );
              }
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Custom beautifully-designed YouTube brand icon
                Container(
                  width: 32,
                  height: 22,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF0000),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Watch Video'.tr(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
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
