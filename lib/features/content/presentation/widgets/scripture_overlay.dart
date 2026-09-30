import 'dart:async';

import 'package:benaiah_app/core/error/app_error.dart';
import 'package:benaiah_app/core/error/app_error_parser.dart';
import 'package:benaiah_app/core/network/bible_service.dart';
import 'package:benaiah_app/features/content/presentation/providers/bible_passage_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:youversion_sdk/youversion_sdk.dart';

class ScriptureOverlay extends ConsumerStatefulWidget {
  const ScriptureOverlay({
    required this.passageId,
    required this.bibleId,
    required this.onDismiss,
    required this.tapPosition,
    super.key,
  });

  final String passageId;
  final String bibleId;
  final Offset tapPosition;
  final VoidCallback onDismiss;

  @override
  ConsumerState<ScriptureOverlay> createState() => _ScriptureOverlayState();
}

class _ScriptureOverlayState extends ConsumerState<ScriptureOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleDismiss() {
    unawaited(
      _animController.reverse().then((_) {
        widget.onDismiss();
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    final param = BiblePassageParam(
      passageId: widget.passageId,
      bibleId: widget.bibleId,
    );

    final passageAsync = ref.watch(biblePassageProvider(param));

    // Riverpod retries a failed provider (up to ten times, with backoff) and
    // reports each retry as loading with the error attached, so `when` would
    // spin for minutes before showing the failure. Check the error first.
    final Widget body;
    if (passageAsync.hasValue) {
      body = _buildContent(context, passageAsync.requireValue);
    } else if (passageAsync.hasError) {
      body = _buildErrorState(context, param, passageAsync.error!);
    } else {
      body = _buildLoadingState(context);
    }

    const double cardWidth = 320;

    final left = (widget.tapPosition.dx - cardWidth / 2).clamp(
      16.0,
      screenWidth - cardWidth - 16.0,
    );

    final isBelow = widget.tapPosition.dy < screenHeight * 0.45;
    final top = isBelow ? widget.tapPosition.dy + 12 : null;
    final bottom = isBelow ? null : (screenHeight - widget.tapPosition.dy) + 12;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          GestureDetector(
            onTap: _handleDismiss,
            behavior: HitTestBehavior.translucent,
            child: Container(
              color: Colors.transparent,
            ),
          ),

          Positioned(
            left: left,
            top: top,
            bottom: bottom,
            width: cardWidth,
            child: ScaleTransition(
              scale: _scaleAnimation,
              alignment: isBelow ? Alignment.topCenter : Alignment.bottomCenter,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: screenHeight * 0.40,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? theme.colorScheme.surface : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(isDark ? 160 : 30),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withAlpha(20)
                          : Colors.black.withAlpha(8),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: body,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, ScripturePassage scripture) {
    final theme = Theme.of(context);
    final passage = scripture.passage;
    final copyright = scripture.copyright;
    final isAmharic = context.locale.languageCode == 'am';

    final textStyle = TextStyle(
      fontSize: isAmharic ? 16 : 17,
      height: 1.5,
      fontStyle: FontStyle.italic,
      fontFamily: isAmharic ? 'BenaiahAm' : 'BenaiahEn',
      color: theme.colorScheme.onSurface,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _citation(scripture),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.1,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: _handleDismiss,
              tooltip: 'Close'.tr(),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(height: 1),
        const SizedBox(height: 12),

        Flexible(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    _cleanHtml(passage.content),
                    style: textStyle,
                  ),
                  // Each version's license asks for its notice with the
                  // quoted text; it sits one tap away so it doesn't crowd
                  // the verse.
                  if (copyright != null) ...[
                    const SizedBox(height: 8),
                    _buildCopyright(context, scripture, copyright),
                  ],
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),
        const Divider(height: 1),
        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(36),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.copy_rounded, size: 16),
                label: Text('Copy'.tr(), style: const TextStyle(fontSize: 13)),
                onPressed: () => _copyToClipboard(context, scripture),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  minimumSize: const Size.fromHeight(36),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.share_rounded, size: 16),
                label: Text('Share'.tr(), style: const TextStyle(fontSize: 13)),
                onPressed: () => _sharePassage(scripture),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        CircularProgressIndicator(
          color: theme.colorScheme.primary,
          strokeWidth: 2.5,
        ),
        const SizedBox(height: 16),
        Text(
          'Fetching scripture...'.tr(),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontSize: 14,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    BiblePassageParam param,
    Object error,
  ) {
    final theme = Theme.of(context);
    debugPrint('BibleService: ScriptureOverlay error details: $error');
    // The raw DioException text is written for developers; readers get the
    // same friendly copy as every other failure in the app.
    final appError = switch (error) {
      AppError() => error,
      YouVersionNetworkException() => const NetworkError(),
      _ => AppErrorParser.parse(error, StackTrace.current),
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: _handleDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        Icon(
          Icons.error_outline_rounded,
          size: 32,
          color: theme.colorScheme.error,
        ),
        const SizedBox(height: 12),
        Text(
          'Failed to load scripture'.tr(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),
        Flexible(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                appError.userMessage,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            visualDensity: VisualDensity.compact,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: const Icon(Icons.refresh_rounded, size: 16),
          label: Text('Retry'.tr(), style: const TextStyle(fontSize: 13)),
          onPressed: () => ref.invalidate(biblePassageProvider(param)),
        ),
      ],
    );
  }

  String _cleanHtml(String htmlString) {
    return htmlString
        .replaceAll(RegExp('<[^>]*>|&nbsp;'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// A small "© NIV" mark; tapping it shows the full notice as a tooltip,
  /// so the popover keeps its size and the verse stays the focus.
  Widget _buildCopyright(
    BuildContext context,
    ScripturePassage scripture,
    String copyright,
  ) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withAlpha(120);
    final label = scripture.versionLabel;

    return Tooltip(
      message: copyright,
      triggerMode: TooltipTriggerMode.tap,
      showDuration: const Duration(seconds: 8),
      preferBelow: false,
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(12),
      textStyle: theme.textTheme.bodySmall?.copyWith(
        fontSize: 11,
        height: 1.4,
        color: theme.colorScheme.onInverseSurface,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label == null ? '©' : '© $label',
              style: theme.textTheme.labelSmall?.copyWith(color: muted),
            ),
            const SizedBox(width: 3),
            Icon(Icons.info_outline_rounded, size: 12, color: muted),
          ],
        ),
      ),
    );
  }

  /// "John 3:16 (NIV)": the version travels with the reference wherever the
  /// verse is shown or shared, as the translations' licenses require.
  String _citation(ScripturePassage scripture) {
    final label = scripture.versionLabel;
    final reference = scripture.passage.reference;
    return label == null ? reference : '$reference ($label)';
  }

  String _shareText(ScripturePassage scripture) {
    final cleanContent = _cleanHtml(scripture.passage.content);
    return '$cleanContent\n\n— ${_citation(scripture)}';
  }

  Future<void> _copyToClipboard(
    BuildContext context,
    ScripturePassage scripture,
  ) async {
    await Clipboard.setData(ClipboardData(text: _shareText(scripture)));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Scripture copied to clipboard!'.tr()),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _sharePassage(ScripturePassage scripture) async {
    await SharePlus.instance.share(ShareParams(text: _shareText(scripture)));
  }
}
