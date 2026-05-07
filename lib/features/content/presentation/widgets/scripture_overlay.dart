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
    required this.onDismiss,
    required this.tapPosition,
    this.bibleId,
    super.key,
  });

  final String passageId;
  final String? bibleId;
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
    _animController.reverse().then((_) {
      widget.onDismiss();
    });
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
      languageCode: context.locale.languageCode,
      bibleId: widget.bibleId,
    );

    final passageAsync = ref.watch(biblePassageProvider(param));

    // Dynamic menu positioning configuration
    const double cardWidth = 320;

    // Clamp left coordinate to prevent screen boundary overflows
    final double left = (widget.tapPosition.dx - cardWidth / 2).clamp(
      16.0,
      screenWidth - cardWidth - 16.0,
    );

    // If tap is in the upper 45% of the screen, show popover below. Otherwise, show above.
    final bool isBelow = widget.tapPosition.dy < screenHeight * 0.45;
    final double? top = isBelow ? widget.tapPosition.dy + 12 : null;
    final double? bottom = isBelow
        ? null
        : (screenHeight - widget.tapPosition.dy) + 12;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Completely transparent full-screen tap-to-dismiss barrier
          GestureDetector(
            onTap: _handleDismiss,
            behavior: HitTestBehavior.translucent,
            child: Container(
              color: Colors.transparent,
            ),
          ),

          // Scale & Fade Animated Popover Card at the precise location
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
                  child: passageAsync.when(
                    data: (passage) => _buildContent(context, passage),
                    loading: () => _buildLoadingState(context),
                    error: (error, stack) =>
                        _buildErrorState(context, param, error),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, Passage passage) {
    final theme = Theme.of(context);
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
        // Title Header with scripture reference
        Row(
          children: [
            Expanded(
              child: Text(
                passage.reference,
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

        // Scrollable scripture text
        Flexible(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: SelectableText(
                _cleanHtml(passage.content),
                style: textStyle,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),
        const Divider(height: 1),
        const SizedBox(height: 8),

        // Bottom Action buttons (Copy & Share)
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.copy_rounded, size: 16),
                label: Text('Copy'.tr(), style: const TextStyle(fontSize: 13)),
                onPressed: () => _copyToClipboard(context, passage),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
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
                onPressed: () => _sharePassage(passage),
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
    debugPrint('🚨 BibleService: ScriptureOverlay error details: $error');

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
              child: SelectableText(
                error.toString(),
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

  Future<void> _copyToClipboard(BuildContext context, Passage passage) async {
    final cleanContent = _cleanHtml(passage.content);
    await Clipboard.setData(
      ClipboardData(text: '$cleanContent\n\n— ${passage.reference}'),
    );
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

  Future<void> _sharePassage(Passage passage) async {
    final cleanContent = _cleanHtml(passage.content);
    await SharePlus.instance.share(
      ShareParams(
        text: '$cleanContent\n\n— ${passage.reference}',
      ),
    );
  }
}
