part of '../settings_page.dart';

class _SettingsScreen extends ConsumerWidget {
  const _SettingsScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      appBar: _SettingsTopSection(),
      body: _SettingsBodySection(),
      bottomNavigationBar: _SettingsBottomSection(),
    );
  }
}
