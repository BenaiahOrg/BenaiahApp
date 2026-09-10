import 'package:benaiah_app/core/error/app_error.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Shared presentation for the non-happy paths: nothing to show, or a failure.
///
/// Every async surface in the app funnels through this so an empty shelf and a
/// dropped connection look deliberate instead of like a broken screen.
class BenaiahStateView extends StatelessWidget {
  const BenaiahStateView({
    required this.icon,
    required this.title,
    super.key,
    this.message,
    this.onRetry,
    this.retryLabel,
    this.compact = false,
  });

  /// Failure state built from a caught error, typed or otherwise.
  factory BenaiahStateView.error({
    required Object error,
    VoidCallback? onRetry,
    bool compact = false,
    Key? key,
  }) {
    final isOffline = error is NetworkError;
    return BenaiahStateView(
      key: key,
      icon: isOffline ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
      title: isOffline ? 'You are offline'.tr() : 'Something went wrong'.tr(),
      message: error is AppError
          ? error.userMessage
          : 'Something went wrong. Please try again.'.tr(),
      onRetry: onRetry,
      compact: compact,
    );
  }

  /// Empty state for a surface that loaded fine but has nothing in it.
  factory BenaiahStateView.empty({
    required String title,
    String? message,
    IconData icon = Icons.inbox_outlined,
    VoidCallback? onRetry,
    bool compact = false,
    Key? key,
  }) {
    return BenaiahStateView(
      key: key,
      icon: icon,
      title: title,
      message: message,
      onRetry: onRetry,
      compact: compact,
    );
  }

  final IconData icon;
  final String title;
  final String? message;
  final VoidCallback? onRetry;
  final String? retryLabel;

  /// Tightens spacing for use inside a tab or card rather than a full page.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 32,
          vertical: compact ? 24 : 48,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: compact ? 40 : 56, color: muted),
            SizedBox(height: compact ? 12 : 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (message != null && message!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: muted),
              ),
            ],
            if (onRetry != null) ...[
              SizedBox(height: compact ? 16 : 24),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(retryLabel ?? 'Try again'.tr()),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
