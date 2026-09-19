part of '../about_page.dart';

class _AboutBottomSection extends StatelessWidget {
  const _AboutBottomSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
      child: Column(
        children: [
          Text(
            'Connect With Us'.tr(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 20),
          const Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              _SocialLinkButton(
                icon: Icons.telegram,
                url: 'https://t.me/benaiah_org',
              ),
              _SocialLinkButton(
                label: 'IG',
                url: 'https://instagram.com/benaiah_org',
              ),
              _SocialLinkButton(
                icon: Icons.facebook,
                url: 'https://facebook.com/BenaiahOrgPage',
              ),
              _SocialLinkButton(
                label: 'in',
                url: 'https://linkedin.com/company/banaiah-org',
              ),
              _SocialLinkButton(
                label: 'X',
                url: 'https://x.com/benaiah_org',
              ),
              _SocialLinkButton(
                icon: Icons.email,
                url: 'mailto:BenaiahTeamOrg@gmail.com',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A round icon (or short brand-initial) button that opens an external
/// social/contact link. Mirrors the "Connect With Us" pattern on
/// benaiah.org, which the app itself had no equivalent of.
class _SocialLinkButton extends StatelessWidget {
  const _SocialLinkButton({required this.url, this.icon, this.label})
      : assert(
          icon != null || label != null,
          'Provide either an icon or a label',
        );

  final IconData? icon;
  final String? label;
  final String url;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white24 : Colors.black12;
    final fgColor = isDark ? Colors.white : Colors.black;

    return Material(
      color: Colors.transparent,
      shape: CircleBorder(side: BorderSide(color: borderColor)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => _open(context),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: icon != null
                ? Icon(icon, color: fgColor, size: 22)
                : Text(
                    label!,
                    style: TextStyle(
                      color: fgColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open link'.tr())),
      );
    }
  }
}
