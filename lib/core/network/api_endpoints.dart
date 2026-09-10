/// Routes for the Benaiah Articles public REST API (v1).
///
/// Base host lives in [Env.apiUrl]; everything here is a path below it.
abstract final class ApiEndpoints {
  static const _v1 = '/api/v1';

  /// Endpoint 1 — every published theme, with its subtopics inlined.
  static const articles = '$_v1/articles';

  /// Endpoint 2 — subtopics under one theme.
  static String theme(String themeSlug) => '$articles/${_seg(themeSlug)}';

  /// Endpoint 3 — one subtopic: authors, artists, availability flags.
  static String subtopic(String themeSlug, String subtopicSlug) =>
      '${theme(themeSlug)}/${_seg(subtopicSlug)}';

  /// Endpoint 4 — parsed article body for a `{type}_{lang}` slug.
  static String article(
    String themeSlug,
    String subtopicSlug,
    String articleSlug,
  ) => '${subtopic(themeSlug, subtopicSlug)}/${_seg(articleSlug)}';

  static String _seg(String value) => Uri.encodeComponent(value);
}

/// The `{type}_{lang}` article slug understood by Endpoint 4.
enum ArticleType {
  devotional('devotional'),
  studyMaterial('study_material');

  const ArticleType(this.wireName);

  final String wireName;

  String slugFor(String langCode) => '${wireName}_${_lang(langCode)}';

  /// The API only publishes `en` and `am`; anything else falls back to English.
  static String _lang(String langCode) => langCode == 'am' ? 'am' : 'en';
}
