part of '../about_page.dart';

class _AboutBottomSection extends StatelessWidget {
  const _AboutBottomSection();

  /// Same links, order and icons as the "Contact Us" row on benaiah.org.
  static final _links = [
    _SocialLink(
      icon: Assets.icons.social.telegram,
      label: 'Telegram',
      url: 'https://t.me/benaiah_org',
    ),
    _SocialLink(
      icon: Assets.icons.social.instagram,
      label: 'Instagram',
      url: 'https://instagram.com/benaiah_org',
    ),
    _SocialLink(
      icon: Assets.icons.social.threads,
      label: 'Threads',
      url: 'https://threads.net/@benaiah_org',
    ),
    _SocialLink(
      icon: Assets.icons.social.facebook,
      label: 'Facebook',
      url: 'https://facebook.com/BenaiahOrgPage',
    ),
    _SocialLink(
      icon: Assets.icons.social.linkedin,
      label: 'LinkedIn',
      url: 'https://linkedin.com/company/banaiah-org',
    ),
    _SocialLink(
      icon: Assets.icons.social.x,
      label: 'X',
      url: 'https://x.com/benaiah_org',
    ),
    _SocialLink(
      icon: Assets.icons.social.email,
      label: 'Email',
      translate: true,
      url: 'mailto:BenaiahTeamOrg@gmail.com',
    ),
    _SocialLink(
      icon: Assets.icons.social.contact,
      label: 'Contact us on Telegram',
      translate: true,
      url: 'https://t.me/Benaiah_Contact',
    ),
  ];

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
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              for (final link in _links) _SocialLinkButton(link: link),
            ],
          ),
        ],
      ),
    );
  }
}

class _SocialLink {
  const _SocialLink({
    required this.icon,
    required this.label,
    required this.url,
    this.translate = false,
  });

  final SvgGenImage icon;

  /// Read out by screen readers and shown on long press.
  final String label;
  final String url;

  /// Whether [label] is a translation key. Brand names stay as they are.
  final bool translate;
}

/// A round button showing a social/contact icon that opens its link
/// externally.
class _SocialLinkButton extends StatelessWidget {
  const _SocialLinkButton({required this.link});

  final _SocialLink link;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final borderColor = scheme.outlineVariant;
    final fgColor = scheme.onSurface;

    return Tooltip(
      message: link.translate ? link.label.tr() : link.label,
      child: Material(
        color: Colors.transparent,
        shape: CircleBorder(side: BorderSide(color: borderColor)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => _open(context),
          child: SizedBox(
            width: 48,
            height: 48,
            child: Center(
              child: link.icon.svg(
                width: 22,
                height: 22,
                colorFilter: ColorFilter.mode(fgColor, BlendMode.srcIn),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context) async {
    final opened = await ExternalLink.open(Uri.parse(link.url));
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open link'.tr())),
      );
    }
  }
}
