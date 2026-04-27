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
          _buildParagraph(context, 'about_mission_body'.tr()),
          _buildParagraph(context, 'about_name_meaning_body'.tr()),
          _buildParagraph(context, 'about_team_body'.tr()),
          _buildParagraph(context, 'about_goals_body'.tr()),
          _buildParagraph(context, 'about_content_avail_body'.tr()),
          const SizedBox(height: 16),
          Text(
            'about_prayer_body'.tr(),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontStyle: FontStyle.italic,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 48),
          Center(
            child: Text(
              'Benaiah.org',
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
