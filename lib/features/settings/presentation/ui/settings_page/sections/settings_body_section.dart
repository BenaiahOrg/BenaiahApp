part of '../settings_page.dart';

class _SettingsBodySection extends ConsumerWidget {
  const _SettingsBodySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader(context, 'appearance'.tr()),
        ListTile(
          title: Text('theme'.tr()),
          trailing: DropdownButton<ThemeMode>(
            value: themeMode,
            onChanged: (mode) {
              if (mode != null) {
                unawaited(ref.read(themeProvider.notifier).setTheme(mode));
              }
            },
            items: [
              DropdownMenuItem(
                value: ThemeMode.system,
                child: Text('system'.tr()),
              ),
              DropdownMenuItem(
                value: ThemeMode.light,
                child: Text('light'.tr()),
              ),
              DropdownMenuItem(value: ThemeMode.dark, child: Text('dark'.tr())),
            ],
          ),
        ),
        const Divider(),
        _buildSectionHeader(context, 'language'.tr()),
        ListTile(
          title: Text('language'.tr()),
          trailing: DropdownButton<Locale>(
            value: context.locale,
            onChanged: (locale) {
              if (locale != null) {
                unawaited(context.setLocale(locale));
              }
            },
            items: [
              DropdownMenuItem(
                value: const Locale('en'),
                child: Text('english'.tr()),
              ),
              DropdownMenuItem(
                value: const Locale('am'),
                child: Text('amharic'.tr()),
              ),
            ],
          ),
        ),
        const Divider(),
        _buildSectionHeader(context, 'about'.tr()),
        ListTile(
          title: Text('about'.tr()),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push(RouteNames.about),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
