# Firebase backend

Firebase backs the podcasts only. Series, topics, articles and graphics come
from the Benaiah Articles REST API (see `lib/core/network/api_endpoints.dart`).

The app reads from Cloud Firestore in the `benaiah-app` project. There is no
bundled fallback: offline, the podcast tab shows Firestore's on-device cache
from an earlier session, or an offline message.

## Collections

`podcastEpisodes/{episodeId}` — only documents with `isPublished == true`
are read, newest `publishDate` first.

| Field | Type | Notes |
|---|---|---|
| `title`, `description`, `category` | string | `category` drives the filter chips |
| `audioUrl`, `imageUrl` | string | streamable audio and cover art |
| `publishDate` | timestamp | |
| `durationSeconds`, `episodeNumber`, `seasonNumber` | int | |
| `contributorIds` | array of string | ids in `contributors` |
| `isPublished` | bool | |

`contributors/{contributorId}` — podcast hosts: `name`, `bio` (or `role`),
`profileImageUrl` (or `imageUrl`).

Edit both collections in the Firebase console. Reads are public and writes
need an `admin` custom claim, per `scripts/firebase/firestore.rules`.

## Rules and indexes

`firebase.json` points at `scripts/firebase/firestore.rules` and
`scripts/firebase/firestore.indexes.json`. The episode query needs the
composite index on `isPublished` + `publishDate`. Deploy both with the
Firebase CLI:

```sh
firebase deploy --only firestore --project benaiah-app
```

## App configuration

Every config file the app needs is committed, so a fresh clone runs without
any Firebase tooling. Each flavor is registered as its own Firebase app:

| Flavor | Android package / iOS bundle | Dart options |
|--------|------------------------------|--------------|
| dev    | `org.benaiah.app.dev`        | `lib/firebase_options_dev.dart` |
| qa     | `org.benaiah.app.qa`         | `lib/firebase_options_qa.dart` |
| prod   | `org.benaiah.app`            | `lib/firebase_options_prod.dart` |

`main.dart` picks the options for the running flavor. Android also carries
all three apps in `android/app/google-services.json`; iOS keeps one plist per
flavor in `ios/Runner/GoogleService-Info-{flavor}.plist`.

To regenerate a flavor's config (for example after registering a new
platform), run FlutterFire once per flavor:

```sh
dart pub global activate flutterfire_cli
flutterfire configure --project=benaiah-app \
  --out=lib/firebase_options_dev.dart \
  --android-package-name=org.benaiah.app.dev \
  --ios-bundle-id=org.benaiah.app.dev
```
