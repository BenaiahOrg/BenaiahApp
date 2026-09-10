enum Flavor { dev, qa, prod }

class F {
  /// Defaults to [Flavor.dev] so configuration reads during start-up can never
  /// throw; `main` overwrites it from the build-time flavor before any UI runs.
  static Flavor appFlavor = Flavor.dev;

  static String get name => appFlavor.name;

  static String get title {
    switch (appFlavor) {
      case Flavor.dev:
        return 'Benaiah [DEV]';
      case Flavor.qa:
        return 'Benaiah [QA]';
      case Flavor.prod:
        return 'Benaiah';
    }
  }
}
