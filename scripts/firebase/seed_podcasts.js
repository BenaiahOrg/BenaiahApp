import { readFile } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import admin from 'firebase-admin';

// Podcast-only counterpart to import_seed.js. That script also writes
// series/topics/appConfig, which is dead weight now that article content
// comes from the REST API instead of Firestore — this one sticks to what
// the app actually reads from Firestore: podcastEpisodes and contributors.

const scriptDir = dirname(fileURLToPath(import.meta.url));
const rootDir = join(scriptDir, '..', '..');
const podcastPath = join(rootDir, 'assets', 'data', 'benaiah_podcasts.json');

const serviceAccountPath =
  process.env.GOOGLE_APPLICATION_CREDENTIALS ??
  join(scriptDir, 'service-account.json');

const serviceAccount = JSON.parse(await readFile(serviceAccountPath, 'utf8'));

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();
const timestamp = admin.firestore.FieldValue.serverTimestamp();

const podcasts = JSON.parse(await readFile(podcastPath, 'utf8'));
const contributorIds = new Set();

function slugify(value) {
  return value
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '');
}

function contributorIdFromPodcastHost(host) {
  return host.id ?? slugify(host.name ?? 'Benaiah Team');
}

async function setDocument(ref, data) {
  await ref.set(
    {
      ...data,
      updatedAt: timestamp,
      createdAt: timestamp,
    },
    { merge: true },
  );
}

async function upsertContributor(id, data) {
  const ref = db.collection('contributors').doc(id);
  const snapshot = await ref.get();
  const existing = snapshot.exists ? snapshot.data() : {};
  const contributorTypes = Array.from(
    new Set([
      ...(existing?.contributorTypes ?? []),
      ...(data.contributorTypes ?? []),
    ]),
  );

  await setDocument(ref, {
    ...existing,
    ...data,
    contributorTypes,
  });
}

for (const episode of podcasts) {
  for (const host of episode.hosts ?? []) {
    const id = contributorIdFromPodcastHost(host);
    contributorIds.add(id);
    await upsertContributor(id, {
      name: host.name,
      nameAm: null,
      role: 'Podcast Host',
      roleAm: null,
      bio: host.bio,
      profileImageUrl: host.imageUrl,
      contributorTypes: ['podcast'],
    });
  }

  await setDocument(db.collection('podcastEpisodes').doc(episode.id), {
    title: episode.title,
    description: episode.description,
    audioUrl: episode.audioUrl,
    durationSeconds: episode.durationSeconds,
    imageUrl: episode.imageUrl,
    publishDate: admin.firestore.Timestamp.fromDate(
      new Date(episode.publishDate),
    ),
    episodeNumber: episode.episodeNumber,
    seasonNumber: episode.seasonNumber,
    category: episode.category ?? 'General',
    contributorIds: (episode.hosts ?? []).map((host) =>
      contributorIdFromPodcastHost(host),
    ),
    isPublished: true,
  });
}

console.log(
  `Seeded ${contributorIds.size} contributor(s) and ${podcasts.length} podcast episode(s).`,
);
