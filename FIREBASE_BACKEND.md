# Firebase backend

The app reads content from Cloud Firestore and falls back to the bundled JSON
files when Firebase is not configured yet.

## Collections

- `series/{seriesId}`
- `series/{seriesId}/topics/{topicId}`
- `contributors/{contributorId}`
- `podcastEpisodes/{episodeId}`
- `appConfig/home`

Large topic bodies live in topic documents instead of inside the parent series
document so Firestore document size stays healthy.

## Project setup

1. Create a Firebase project.
2. Run FlutterFire configuration for this app:

   ```sh
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

3. Make sure the generated/native config files exist for the platforms you use:

   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`
   - `macos/Runner/GoogleService-Info.plist`
   - `lib/firebase_options.dart` for web or explicit Dart options

4. Publish rules from `scripts/firebase/firestore.rules`.

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
