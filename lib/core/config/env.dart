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

  static String get youversionDeveloperToken {
    const fromEnv = String.fromEnvironment('YOUVERSION_DEVELOPER_TOKEN');
    if (fromEnv.isNotEmpty) return fromEnv;
    return _flavorDefaults[F.appFlavor]!.youversionDeveloperToken;
  }

  static final Map<Flavor, _FlavorEnv> _flavorDefaults = {
    Flavor.dev: const _FlavorEnv(
      sentryDsn: '',
      apiUrl: 'https://dev-api.benaiah.org',
      youversionDeveloperToken: 'mock_dev_token',
    ),
    Flavor.qa: const _FlavorEnv(
      sentryDsn: '',
      apiUrl: 'https://qa-api.benaiah.org',
      youversionDeveloperToken: 'mock_qa_token',
    ),
    Flavor.prod: const _FlavorEnv(
      sentryDsn: '',
      apiUrl: 'https://api.benaiah.org',
      youversionDeveloperToken: 'mock_prod_token',
    ),
  };
}

class _FlavorEnv {
  const _FlavorEnv({
    required this.sentryDsn,
    required this.apiUrl,
    required this.youversionDeveloperToken,
  });

  final String sentryDsn;
  final String apiUrl;
  final String youversionDeveloperToken;
}

