import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../di/injection_container.dart';
import '../network/connectivity_service.dart';
import '../network/error_banner_service.dart';
import '../../l10n/generated/app_localizations.dart';

class ConnectivityBanner extends StatelessWidget {
  final Widget child;

  const ConnectivityBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final connectivity = sl<ConnectivityService>();
    final errorBanner = sl<ErrorBannerService>();
    final l10n = AppLocalizations.of(context);

    return Observer(
      builder: (_) {
        final online = connectivity.isConnected;
        final errorMsg = errorBanner.errorMessage;

        return Column(
          children: [
            Expanded(child: child),
            if (!online && l10n != null)
              _BannerBar(
                icon: Icons.wifi_off,
                color: const Color(0xFFB71C1C),
                message: l10n.errorNetwork,
                subtitle: l10n.retry,
                context: context,
              )
            else if (errorMsg != null && online && l10n != null)
              _BannerBar(
                icon: Icons.error_outline,
                color: const Color(0xFF7B3F00),
                message: errorMsg,
                actionLabel: l10n.retry,
                onAction: errorBanner.retry,
                onDismiss: errorBanner.dismiss,
                context: context,
              ),
          ],
        );
      },
    );
  }
}

class _BannerBar extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String message;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onDismiss;
  final BuildContext context;

  const _BannerBar({
    required this.icon,
    required this.color,
    required this.message,
    required this.context,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext ctx) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        color: color,
        padding: EdgeInsets.fromLTRB(16, 10, 8, bottomPad + 10),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
            if (actionLabel != null && onAction != null)
              TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                child: Text(
                  actionLabel!,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            if (onDismiss != null)
              IconButton(
                onPressed: onDismiss,
                icon: const Icon(Icons.close, color: Colors.white70, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
          ],
        ),
      ),
    );
  }
}
