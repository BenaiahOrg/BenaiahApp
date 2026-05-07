import 'package:benaiah_app/features/content/presentation/widgets/scripture_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// A custom theme-aware Markdown renderer that applies Benaiah design guidelines.
///
/// It supports dynamic Light/Dark themes, customizable line-height, text selection,
/// and stylized headers, lists, code-blocks, and blockquotes.
class BenaiahMarkdown extends ConsumerStatefulWidget {
  const BenaiahMarkdown({
    required this.data,
    super.key,
    this.selectable = true,
    this.onTapLink,
    this.padding = EdgeInsets.zero,
  });

  /// The markdown source string to render.
  final String data;

  /// Whether the markdown text should be selectable/copyable.
  final bool selectable;

  /// Callback when a link is tapped.
  final void Function(String text, String? href, String title)? onTapLink;

  /// Padding around the markdown body.
  final EdgeInsetsGeometry padding;

  @override
  ConsumerState<BenaiahMarkdown> createState() => _BenaiahMarkdownState();
}

class _BenaiahMarkdownState extends ConsumerState<BenaiahMarkdown> {
  final _overlayController = OverlayPortalController();
  String? _passageId;
  String? _bibleId;
  Offset? _tapPosition;
  Offset? _lastPointerPosition;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Retrieve base text attributes
    final baseFontFamily = theme.textTheme.bodyLarge?.fontFamily;

    // Standard high-readability body text style
    final baseBodyStyle =
        theme.textTheme.bodyLarge?.copyWith(
          fontSize: 18,
          height: 1.8,
          letterSpacing: 0.2,
          fontFamily: baseFontFamily,
        ) ??
        TextStyle(
          fontSize: 18,
          height: 1.8,
          letterSpacing: 0.2,
          fontFamily: baseFontFamily,
        );

    // Build custom stylesheet
    final styleSheet = MarkdownStyleSheet(
      // Paragraph styling
      p: baseBodyStyle,
      pPadding: const EdgeInsets.only(bottom: 16),

      // Heading 1
      h1: theme.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
        height: 1.4,
        fontFamily: baseFontFamily,
      ),
      h1Padding: const EdgeInsets.only(top: 24, bottom: 12),

      // Heading 2
      h2: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
        height: 1.4,
        fontFamily: baseFontFamily,
      ),
      h2Padding: const EdgeInsets.only(top: 20, bottom: 10),

      // Heading 3
      h3: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
        height: 1.4,
        fontFamily: baseFontFamily,
      ),
      h3Padding: const EdgeInsets.only(top: 16, bottom: 8),

      // Heading 4
      h4: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
        height: 1.4,
        fontFamily: baseFontFamily,
      ),
      h4Padding: const EdgeInsets.only(top: 12, bottom: 6),

      // Strong / Bold
      strong: baseBodyStyle.copyWith(
        fontWeight: FontWeight.bold,
      ),

      // Emphasis / Italic
      em: baseBodyStyle.copyWith(
        fontStyle: FontStyle.italic,
      ),

      // Blockquotes (e.g. scripture quotes, highlights)
      blockquoteDecoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: theme.colorScheme.primary,
            width: 4,
          ),
        ),
      ),
      blockquotePadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      blockquote: baseBodyStyle.copyWith(
        fontStyle: FontStyle.italic,
        color: isDark ? Colors.grey[300] : Colors.grey[700],
      ),

      // Lists
      listBullet: baseBodyStyle.copyWith(
        fontWeight: FontWeight.bold,
      ),
      listBulletPadding: const EdgeInsets.only(right: 8),
      listIndent: 24,

      // Code blocks
      code: TextStyle(
        fontFamily: 'monospace',
        fontSize: 14,
        color: theme.colorScheme.primary,
        backgroundColor: isDark ? Colors.grey[950] : Colors.grey[200],
      ),
      codeblockDecoration: BoxDecoration(
        color: isDark ? Colors.grey[950] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.grey[850]! : Colors.grey[300]!,
        ),
      ),
      codeblockPadding: const EdgeInsets.all(12),

      // Horizontal lines
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
          ),
        ),
      ),
    );

    return OverlayPortal(
      controller: _overlayController,
      overlayChildBuilder: (context) {
        if (_passageId == null || _tapPosition == null) return const SizedBox.shrink();
        return ScriptureOverlay(
          passageId: _passageId!,
          bibleId: _bibleId,
          tapPosition: _tapPosition!,
          onDismiss: () {
            setState(() {
              _overlayController.hide();
              _passageId = null;
              _bibleId = null;
              _tapPosition = null;
            });
          },
        );
      },
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (event) {
          _lastPointerPosition = event.position;
        },
        child: Padding(
          padding: widget.padding,
          child: MarkdownBody(
            data: widget.data,
            selectable: widget.selectable,
            styleSheet: styleSheet,
            onTapLink: (text, href, title) {
              if (href != null && href.startsWith('bible://')) {
                try {
                  final uri = Uri.parse(href);
                  String passageId = '${uri.host}${uri.path}';
                  passageId = passageId
                      .replaceAll('/', '.')
                      .replaceAll(RegExp(r'\.+$'), '')
                      .toUpperCase();
                  final bibleId = uri.queryParameters['version'];



                  setState(() {
                    _passageId = passageId;
                    _bibleId = bibleId;
                    _tapPosition = _lastPointerPosition ?? const Offset(200, 300);
                    _overlayController.show();
                  });
                } catch (e) {
                  debugPrint('Error parsing bible link: $e');
                }
              } else if (widget.onTapLink != null) {
                widget.onTapLink!(text, href, title);
              } else {
                // Default fallback logging
                debugPrint(
                  'Tapped link: text="$text", href="$href", title="$title"',
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
