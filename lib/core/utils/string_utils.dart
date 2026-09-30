abstract class StringUtils {
  /// Strips common markdown and HTML formatting to plain text, for teasers,
  /// previews and list card snippets.
  static String stripMarkdown(String? markdown) {
    if (markdown == null || markdown.isEmpty) return '';

    var text = markdown;

    // HTML tags: <p>, <br>, <strong>, ...
    text = text.replaceAll(RegExp('<[^>]*>'), '');

    text = text
        .replaceAll('&amp;', '&')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&#39;', "'")
        .replaceAll('&quot;', '"')
        .replaceAll('&#x27;', "'")
        .replaceAll('&#x2F;', '/');

    // Blockquotes: "> Quote" -> "Quote".
    text = text.replaceAll(RegExp(r'^\s*>\s*', multiLine: true), '');

    // Headings: "# Heading" -> "Heading".
    text = text.replaceAll(RegExp(r'^\s*#+\s+', multiLine: true), '');

    // List markers: "* Item", "- Item", "1. Item".
    text = text.replaceAll(RegExp(r'^\s*[*+-]\s+', multiLine: true), '');
    text = text.replaceAll(RegExp(r'^\s*\d+\.\s+', multiLine: true), '');

    // Images and links keep only their text: ![alt](url), [text](url).
    text = text.replaceAllMapped(
      RegExp(r'!\[([^\]]*)\]\([^\)]*\)'),
      (match) => match.group(1) ?? '',
    );
    text = text.replaceAllMapped(
      RegExp(r'\[([^\]]*)\]\([^\)]*\)'),
      (match) => match.group(1) ?? '',
    );

    // Inline code: `code` -> code.
    text = text.replaceAll(RegExp('`([^`]+)`'), r'$1');

    // Bold and italics: **bold**, __bold__, *italic*, _italic_.
    text = text.replaceAll(RegExp(r'(\*\*|__)(.*?)\1'), r'$2');
    text = text.replaceAll(RegExp(r'(\*|_)(.*?)\1'), r'$2');

    // Horizontal rules: ---, ***, ___.
    text = text.replaceAll(RegExp(r'^\s*[-*_]{3,}\s*$', multiLine: true), '');

    text = text.replaceAll(RegExp(r'\s+'), ' ');

    return text.trim();
  }

  /// Inserts a space where a digit is immediately followed by a capitalized
  /// word with no separator — a common CMS copy-paste artifact where two
  /// fields (e.g. a title and a description) got concatenated with nothing
  /// between them, like "...Episode 01This is an episode about...".
  static String fixMissingWordBoundary(String text) {
    return text.replaceAllMapped(
      RegExp(r'(\d)([A-Z][a-z]{2,})'),
      (match) => '${match.group(1)} ${match.group(2)}',
    );
  }

  /// Extracts the 11-character YouTube video ID from a given YouTube URL.
  /// Returns null if the URL is not a valid YouTube link.
  static String? tryGetYoutubeId(String url) {
    if (url.contains('youtu.be/')) {
      final parts = url.split('youtu.be/');
      if (parts.length > 1) {
        return parts[1].split('?').first.split('/').first;
      }
    }
    final regExp = RegExp(
      r'^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(url);
    if (match != null && match.groupCount >= 2) {
      final id = match.group(2);
      if (id != null && id.length == 11) {
        return id;
      }
    }
    return null;
  }
}
