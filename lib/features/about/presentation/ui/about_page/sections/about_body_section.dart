part of '../about_page.dart';

class _AboutBodySection extends StatelessWidget {
  const _AboutBodySection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildParagraph(context, 'Benaiah is a digital mission initiative that extends a heartfelt invitation for all people to draw closer to God.'.tr()),
          _buildParagraph(context, "Benaiah, means God has Created or Built and we want that essence of God working and creating through us. It is also the name of a mighty, honorable and heroic warrior who was captain of King David's bodyguards.".tr()),
          _buildParagraph(context, "Our team is composed of 20 gifted individuals from all over Ethiopia and the US involving authors, graphic designers, narrators, developers and more all united by a passion for Christ and His word.".tr()),
          _buildParagraph(context, "We aim to encourage believers and spread the good news of the gospels far and wide through Biblical insights and creative expressions like devotionals, study materials, graphics, narrations and more. So that everyone can come partake in God's endless love and mercy.".tr()),
          _buildParagraph(context, "We have been at work for 4 months and produced so much content that you are completely free to take, share and spread along with us. You can find us on all major platforms, in both English and Amharic.".tr()),
          const SizedBox(height: 16),
          Text(
            'It is our prayer, that this blessed you and comforts your soul in more ways than imaginable.'.tr(),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontStyle: FontStyle.italic,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 48),
          Center(
            child: Text(
              'Benaiah.org'.tr(),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                letterSpacing: 2,
                fontWeight: FontWeight.w300,
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
