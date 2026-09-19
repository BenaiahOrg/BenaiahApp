part of '../settings_page.dart';

class _SettingsBodySection extends ConsumerWidget {
  const _SettingsBodySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final languageCode = context.locale.languageCode;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        _SettingsGroup(
          label: 'Appearance'.tr(),
          children: [
            for (final (mode, icon, label) in const [
              (ThemeMode.light, Icons.light_mode_outlined, 'Light'),
              (ThemeMode.dark, Icons.dark_mode_outlined, 'Dark'),
              (ThemeMode.system, Icons.brightness_auto_outlined, 'System'),
            ])
              _SettingsOption(
                icon: icon,
                label: label.tr(),
                selected: themeMode == mode,
                onTap: () =>
                    unawaited(ref.read(themeProvider.notifier).setTheme(mode)),
              ),
          ],
        ),
        const SizedBox(height: 28),
        _SettingsGroup(
          label: 'Language'.tr(),
          children: [
            // Endonyms, not translated labels: a language picker should read
            // in the language it is offering.
            for (final (code, label) in const [
              ('en', 'English'),
              ('am', 'አማርኛ'),
            ])
              _SettingsOption(
                icon: Icons.translate_rounded,
                label: label,
                selected: languageCode == code,
                onTap: () => unawaited(context.setLocale(Locale(code))),
              ),
          ],
        ),
        const SizedBox(height: 28),
        _SettingsGroup(
          label: 'About'.tr(),
          children: [
            _SettingsOption(
              icon: Icons.info_outline_rounded,
              label: 'About'.tr(),
              onTap: () => context.push(RouteNames.about),
            ),
          ],
        ),
        const SizedBox(height: 40),
        const _SettingsFooter(),
      ],
    );
  }
}

/// A titled card of related rows: the section label sits outside the card, the
/// rows inside it, hairline-separated.
class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.label, required this.children});

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            label.toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: 56,
                    color: theme.colorScheme.onSurface.withAlpha(14),
                  ),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// One tappable row. [selected] is null for rows that navigate rather than
/// pick a value, which get a chevron instead of a checkmark.
class _SettingsOption extends StatelessWidget {
  const _SettingsOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool? selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = selected ?? false;
    final foreground = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: foreground.withAlpha(isSelected ? 255 : 160),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: foreground,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (selected == null)
              Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: theme.colorScheme.onSurface.withAlpha(100),
              )
            else if (isSelected)
              Icon(
                Icons.check_rounded,
                size: 20,
                color: theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}

/// Wordmark and build identity, so a tester reporting a bug can say which
/// build they are on without digging through system settings.
class _SettingsFooter extends StatelessWidget {
  const _SettingsFooter();

  /// Injected by the Flutter tool on every build, so the version shown here
  /// tracks pubspec without pulling in a package_info dependency.
  static const _version = String.fromEnvironment('FLUTTER_BUILD_NAME');
  static const _build = String.fromEnvironment('FLUTTER_BUILD_NUMBER');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final flavor = F.appFlavor == Flavor.prod
        ? ''
        : ' · ${F.name.toUpperCase()}';

    return Opacity(
      opacity: 0.45,
      child: Column(
        children: [
          Image.asset(
            isDark
                ? Assets.images.logoWhite.path
                : Assets.images.logoBlack.path,
            height: 28,
          ),
          const SizedBox(height: 10),
          if (_version.isNotEmpty)
            Text(
              '$_version${_build.isEmpty ? '' : ' ($_build)'}$flavor',
              style: theme.textTheme.bodySmall,
            ),
        ],
      ),
    );
  }
}
