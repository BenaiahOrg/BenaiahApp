enum Flavor { dev, qa, prod }

class F {
  static late final Flavor appFlavor;

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
