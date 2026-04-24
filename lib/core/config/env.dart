import 'package:benaiah_app/flavors.dart';

abstract class Env {
  // --dart-define overrides take priority, flavor defaults as fallback.

  static String get sentryDsn {
    const fromEnv = String.fromEnvironment('SENTRY_DSN');
    if (fromEnv.isNotEmpty) return fromEnv;
    return _flavorDefaults[F.appFlavor]!.sentryDsn;
  }

  static String get apiUrl {
    const fromEnv = String.fromEnvironment('API_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    return _flavorDefaults[F.appFlavor]!.apiUrl;
  }

  static final Map<Flavor, _FlavorEnv> _flavorDefaults = {
    Flavor.dev: const _FlavorEnv(
      sentryDsn: '',
      apiUrl: 'https://dev-api.benaiah.org',
    ),
    Flavor.qa: const _FlavorEnv(
      sentryDsn: '',
      apiUrl: 'https://qa-api.benaiah.org',
    ),
    Flavor.prod: const _FlavorEnv(
      sentryDsn: '',
      apiUrl: 'https://api.benaiah.org',
    ),
  };
}

class _FlavorEnv {
  const _FlavorEnv({
    required this.sentryDsn,
    required this.apiUrl,
  });

  final String sentryDsn;
  final String apiUrl;
}
