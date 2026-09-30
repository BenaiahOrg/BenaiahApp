// Each paragraph is a whole translation key in langs.csv, so it stays on one
// line instead of being split to fit 80 columns.
// ignore_for_file: lines_longer_than_80_chars

part of '../about_page.dart';

class _AboutBodySection extends StatelessWidget {
  const _AboutBodySection();

  static const _websiteUrl = 'https://www.benaiah.org';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildParagraph(
            context,
            'Benaiah is a digital mission initiative that extends a heartfelt invitation for all people to draw closer to God.'
                .tr(),
          ),
          _buildParagraph(
            context,
            "Benaiah, means God has Created or Built and we want that essence of God working and creating through us. It is also the name of a mighty, honorable and heroic warrior who was captain of King David's bodyguards."
                .tr(),
          ),
          _buildParagraph(
            context,
            'Our team is composed of 20 gifted individuals from all over Ethiopia and the US involving authors, graphic designers, narrators, developers and more all united by a passion for Christ and His word.'
                .tr(),
          ),
          _buildParagraph(
            context,
            "We aim to encourage believers and spread the good news of the gospels far and wide through Biblical insights and creative expressions like devotionals, study materials, graphics, narrations and more. So that everyone can come partake in God's endless love and mercy."
                .tr(),
          ),
          _buildParagraph(
            context,
            'We have been at work for 4 months and produced so much content that you are completely free to take, share and spread along with us. You can find us on all major platforms, in both English and Amharic.'
                .tr(),
          ),
          const SizedBox(height: 16),
          Text(
            'It is our prayer, that this blessed you and comforts your soul in more ways than imaginable.'
                .tr(),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontStyle: FontStyle.italic,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 48),
          Center(
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => unawaited(ExternalLink.open(Uri.parse(_websiteUrl))),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                child: Text(
                  'Benaiah.org'.tr(),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildParagraph(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          height: 1.6,
        ),
      ),
    );
  }
}
