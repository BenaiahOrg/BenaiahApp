import { readFile } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import admin from 'firebase-admin';

const scriptDir = dirname(fileURLToPath(import.meta.url));
const rootDir = join(scriptDir, '..', '..');
const contentPath = join(rootDir, 'assets', 'data', 'benaiah_content.json');
const podcastPath = join(rootDir, 'assets', 'data', 'benaiah_podcasts.json');

const serviceAccountPath =
  process.env.GOOGLE_APPLICATION_CREDENTIALS ??
  join(scriptDir, 'service-account.json');

const serviceAccount = JSON.parse(await readFile(serviceAccountPath, 'utf8'));

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  storageBucket: process.env.FIREBASE_STORAGE_BUCKET,
});

const db = admin.firestore();
const timestamp = admin.firestore.FieldValue.serverTimestamp();

const content = JSON.parse(await readFile(contentPath, 'utf8'));
const podcasts = JSON.parse(await readFile(podcastPath, 'utf8'));

const contributorIds = new Set();

function slugify(value) {
  return value
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '');
}

function contributorIdFromAuthor(author) {
  return slugify(author.name_en ?? 'Benaiah Team');
}

function contributorIdFromPodcastHost(host) {
  return host.id ?? slugify(host.name ?? 'Benaiah Team');
}

function contentContributorIds(section) {
  return (section?.authors ?? []).map((author) => {
    const id = contributorIdFromAuthor(author);
    contributorIds.add(id);
    return id;
  });
}

function contentSection(section) {
  return {
    title: section?.title ?? '',
    content: section?.content ?? '',
    youtubeUrl: section?.youtube_url ?? null,
    contributorIds: contentContributorIds(section),
  };
}

function graphicsSection(section) {
  return {
    urls: section?.data ?? [],
    contributorIds: contentContributorIds(section),
  };
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

for (const [seriesIndex, series] of content.entries()) {
  const seriesId = `s${seriesIndex}`;
  const topics = series.topics ?? [];
  const firstGraphic =
    topics.flatMap((topic) => topic.graphics?.data ?? [])[0] ?? '';
  const titleEn = series.series_en ?? series.series;
  const titleAm = series.series_am ?? series.series;

  await setDocument(db.collection('series').doc(seriesId), {
    title: series.series,
    titleEn,
    titleAm,
    description: `Exploring the ${series.series} theme with depth and biblical insight.`,
    descriptionEn: `Exploring the ${titleEn} theme with depth and biblical insight.`,
    descriptionAm: series.series_am
      ? `የ${titleAm}ን ጭብጥ በጥልቀት እና በመጽሐፍ ቅዱሳዊ ግንዛቤ መመርመር።`
      : `Exploring the ${series.series} theme with depth and biblical insight.`,
    imageUrl: firstGraphic,
    order: seriesIndex + 1,
    isPublished: true,
  });

  for (const [topicIndex, topic] of topics.entries()) {
    await setDocument(
      db.collection('series').doc(seriesId).collection('topics').doc(topic.id),
      {
        title: topic.title,
        titleEn: topic.title_en ?? topic.title,
        titleAm: topic.title_am ?? topic.title,
        order: topicIndex + 1,
        isPublished: true,
        devotionalEn: contentSection(topic.devotional_en),
        devotionalAm: contentSection(topic.devotional_am),
        studyMaterialEn: contentSection(topic.study_material_en),
        studyMaterialAm: contentSection(topic.study_material_am),
        graphics: graphicsSection(topic.graphics),
      },
    );
  }
}

for (const series of content) {
  for (const topic of series.topics ?? []) {
    for (const section of [
      topic.devotional_en,
      topic.devotional_am,
      topic.study_material_en,
      topic.study_material_am,
      topic.graphics,
    ]) {
      for (const author of section?.authors ?? []) {
        const id = contributorIdFromAuthor(author);
        contributorIds.add(id);
        await upsertContributor(id, {
          name: author.name_en ?? 'Benaiah Team',
          nameAm: author.name_am ?? null,
          role: author.role_en ?? null,
          roleAm: author.role_am ?? null,
          profileImageUrl: author.profileImageUrl ?? null,
          bio: author.role_en ?? null,
          contributorTypes: ['writing', 'graphics'],
        });
      }
    }
  }
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

await setDocument(db.collection('appConfig').doc('home'), {
  featuredSeriesIds: content.length > 0 ? ['s0'] : [],
  featuredTopicIds: content[0]?.topics?.[0]?.id ? [content[0].topics[0].id] : [],
  featuredPodcastEpisodeIds: podcasts[0]?.id ? [podcasts[0].id] : [],
});

console.log(
  `Seeded ${content.length} series, ${contributorIds.size} contributors, ` +
    `and ${podcasts.length} podcast episodes.`,
);
