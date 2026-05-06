abstract class StringUtils {
  /// Strips common markdown formatting structures to produce clean plain-text.
  ///
  /// This is extremely useful for short teasers, previews, and list card snippets.
  static String stripMarkdown(String? markdown) {
    if (markdown == null || markdown.isEmpty) return '';

    var text = markdown;

    // Remove blockquote signs (e.g. "> Quote" -> "Quote")
    text = text.replaceAll(RegExp(r'^\s*>\s*', multiLine: true), '');

    // Remove Header tags (e.g. "# Heading" -> "Heading")
    text = text.replaceAll(RegExp(r'^\s*#+\s+', multiLine: true), '');

    // Remove list markers (e.g. "* Item", "- Item", "1. Item")
    text = text.replaceAll(RegExp(r'^\s*[*+-]\s+', multiLine: true), '');
    text = text.replaceAll(RegExp(r'^\s*\d+\.\s+', multiLine: true), '');

    // Remove images and links markdown style: ![alt](url) or [link](url)
    // and keep only the display text.
    text = text.replaceAllMapped(
      RegExp(r'!\[([^\]]*)\]\([^\)]*\)'),
      (match) => match.group(1) ?? '',
    );
    text = text.replaceAllMapped(
      RegExp(r'\[([^\]]*)\]\([^\)]*\)'),
      (match) => match.group(1) ?? '',
    );

    // Remove code block backticks `code` -> code
    text = text.replaceAll(RegExp('`([^`]+)`'), r'$1');

    // Remove Bold/Italics asterisks or underscores (**bold**, *italic*, __bold__, _italic_)
    text = text.replaceAll(RegExp(r'(\*\*|__)(.*?)\1'), r'$2');
    text = text.replaceAll(RegExp(r'(\*|_)(.*?)\1'), r'$2');

    // Remove horizontal rule markers (---, ***, ___)
    text = text.replaceAll(RegExp(r'^\s*[-*_]{3,}\s*$', multiLine: true), '');

    // Normalize multiple consecutive spaces/tabs and newlines to a single space
    text = text.replaceAll(RegExp(r'\s+'), ' ');

    return text.trim();
  }
}
