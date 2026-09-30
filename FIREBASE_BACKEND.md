# Firebase backend

> **Scope note.** Article content (series, topics, devotionals, study material,
> graphics) no longer comes from Firestore — it is served by the Benaiah
> Articles REST API. See [docs/BACKEND_API_NOTES.md](docs/BACKEND_API_NOTES.md).
> Firebase now backs **podcasts only**.

The app reads podcast episodes from Cloud Firestore. There is no bundled
fallback, so podcasts are empty when Firebase is unreachable.

## Collections

- `podcastEpisodes/{episodeId}`
- `contributors/{contributorId}` — podcast hosts

The `series`, `series/{id}/topics` and `appConfig/home` collections are no
longer read by the app.

## Project setup

The app is already connected to the `benaiah-app` project, and every config
file it needs is committed, so a fresh clone runs without any Firebase
tooling. Each flavor is registered as its own Firebase app:

| Flavor | Android package / iOS bundle | Dart options |
|--------|------------------------------|--------------|
| dev    | `org.benaiah.app.dev`        | `lib/firebase_options_dev.dart` |
| qa     | `org.benaiah.app.qa`         | `lib/firebase_options_qa.dart` |
| prod   | `org.benaiah.app`            | `lib/firebase_options_prod.dart` |

`main.dart` picks the options for the running flavor. Android also carries all
three apps in `android/app/google-services.json`; iOS keeps one plist per
flavor in `ios/Runner/GoogleService-Info-{flavor}.plist`.

To regenerate a flavor's config (e.g. after registering a new platform), run
FlutterFire once per flavor:

```sh
dart pub global activate flutterfire_cli
flutterfire configure --project=benaiah-app \
  --out=lib/firebase_options_dev.dart \
  --android-package-name=org.benaiah.app.dev \
  --ios-bundle-id=org.benaiah.app.dev
```

The Firebase CLI (`firebase login`) is only needed to deploy rules and
indexes from `scripts/firebase/`.

## Seed Firestore from the current JSON

Create a Firebase Admin service account JSON file, then place it at:

```txt
scripts/firebase/service-account.json
```

That path is gitignored. Then run:

```sh
cd scripts/firebase
npm install
npm run seed
```

The script imports:

- `assets/data/benaiah_content.json`
- `assets/data/benaiah_podcasts.json`

It writes series, nested topics, contributors, podcast episodes, and home
featured IDs.

If you use Firebase Storage for media later, upload files under paths like:

```txt
series/{seriesId}/cover.jpg
topics/{topicId}/graphics/{fileName}.jpg
podcasts/{episodeId}/audio.mp3
podcasts/{episodeId}/cover.jpg
contributors/{contributorId}/profile.jpg
```

Then store the public download URL in the related Firestore document.

## What to do next

1. Run `flutterfire configure` so platform config files are created.
2. Publish the Firestore rules from `scripts/firebase/firestore.rules`.
3. Seed the current JSON into Firestore with `npm install && npm run seed`
   inside `scripts/firebase`.
4. Open the app and verify content and podcasts load from Firestore.
5. When that looks good, add an admin flow or small internal dashboard for
   editing `series`, `topics`, `contributors`, and `podcastEpisodes`.
