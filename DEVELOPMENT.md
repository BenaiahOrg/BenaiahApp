# Development

How to set up, run, test and build the Benaiah app. For what the app
is and does, see the [README](README.md).

## Where the content comes from

Nothing is bundled with the app; everything below is fetched at runtime.

| Content | Source |
|---|---|
| Series, topics, articles, authors, graphics | Benaiah Articles REST API (`/api/v1/articles` on www.benaiah.org), see `lib/core/network/api_endpoints.dart` |
| Podcast episodes and hosts | Cloud Firestore in the `benaiah-app` project, see [FIREBASE_BACKEND.md](FIREBASE_BACKEND.md) |
| Scripture pop-ups | [YouVersion Platform](https://platform.youversion.com) API |
| Artwork | Cloudinary, requested at the size it is drawn |

## Getting started

Prerequisites: [FVM](https://fvm.app) (or [Puro](https://puro.dev)), the
Android SDK, and Xcode with CocoaPods for iOS.

```bash
bash scripts/project_setup.sh      # Windows: scripts\project_setup.bat
```

This installs the Flutter version pinned in `.fvmrc`, fetches packages,
generates code, installs pods, and creates `secrets.json` from
`secrets.json.example`. Put your YouVersion developer token in it:

```json
{ "YOUVERSION_DEVELOPER_TOKEN": "..." }
```

`secrets.json` is gitignored. Without a token the app still runs, but
scripture pop-ups cannot load.

## Running

There are three flavors, `dev`, `qa` and `prod`, each with its own
application id and Firebase app.

- VS Code: pick **Benaiah [DEV]**, **[QA]** or **[PROD]** in Run and Debug.
- Make: `make -f scripts/Makefile run-dev` (see `make -f scripts/Makefile help`).
- CLI:

  ```bash
  fvm flutter run --flavor dev -t lib/main.dart --dart-define-from-file=secrets.json
  ```

All three pass `secrets.json` to the build.

## Code generation

Generated code (injectable, Riverpod, asset constants) is not committed.
Regenerate it after changing annotated code or assets:

```bash
make -f scripts/Makefile gen
```

## Tests

```bash
make -f scripts/Makefile test        # unit tests, no network
make -f scripts/Makefile test-live   # checks every published article is served
```

## Building

```bash
make -f scripts/Makefile build-prod    # APK
make -f scripts/Makefile bundle-prod   # App Bundle for Play
```

Release builds are signed with the key described in a `key.properties` file
at the repository root (`storeFile`, `storePassword`, `keyAlias`,
`keyPassword`); it is gitignored. Without it they fall back to the shared
debug key, which is fine for testers but not for the store.

iOS builds use CocoaPods: Swift Package Manager is disabled in `pubspec.yaml`
because it resolves a newer Firebase SDK than `cloud_firestore` supports.

## Project structure

```
lib/
  core/           shared infrastructure
    config/       per-flavor environment values
    di/           get_it + injectable setup
    error/        AppError types and the Result wrapper
    network/      Dio client, API endpoints, YouVersion service
    router/       GoRouter configuration
    theme/        colors, typography, light/dark themes
    utils/        scripture linking, Cloudinary sizing, external links
    widgets/      shared widgets (markdown, network image, state views)
  features/
    content/      series, topics, articles, authors, scripture pop-ups
    podcast/      episodes, hosts and the audio player
    home/         home screen
    main/         bottom-navigation shell
    settings/     theme and language settings
    about/        about page
  main.dart       startup: flavor, Firebase, Sentry, dependency injection
assets/
  translations/   langs.csv with key, en and am columns
scripts/          Makefile, setup scripts, Firestore rules and indexes
bricks/           Mason templates for new features and pages
```

Repositories return a `Result<T>` (`Success` or `Failure` carrying an
`AppError`); providers throw the error so screens can render it with
`BenaiahStateView.error`.

## Scaffolding

[Mason](https://docs.brickhub.dev) bricks generate new features and pages in
the project's layout:

```bash
mason make feature --name <feature_name>
mason make page --feature <feature_name> --name <page_name>
```

Run `make -f scripts/Makefile gen` afterwards, and delete any generated layer
the feature does not need.

## Tech stack

Riverpod (hooks_riverpod with code generation), GoRouter, Dio, get_it with
injectable, easy_localization, Firebase (Firestore), just_audio, and Sentry.
