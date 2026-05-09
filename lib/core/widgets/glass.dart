import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class Glass extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final double blurSigma;
  final double opacity;
  final Color? color;
  final Color? borderColor;
  final double borderWidth;

  const Glass({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.blurSigma = 10,
    this.opacity = 0.92,
    this.color,
    this.borderColor,
    this.borderWidth = 1,
  });

  @override
  Widget build(BuildContext context) {
    final base = color ?? AppColors.surface.withValues(alpha: opacity);
    final border = borderColor ?? AppColors.border;

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: base,
            borderRadius: borderRadius,
            border: Border.all(color: border, width: borderWidth),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Relic-panel card: gradient fill + gold border + gold glow + inset highlight.
class GlassCard extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry? margin;
  final Clip clipBehavior;
  final Color? color;

  const GlassCard({
    super.key,
    this.child,
    this.margin,
    this.clipBehavior = Clip.none,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = child ?? const SizedBox.shrink();
    const radius = BorderRadius.all(Radius.circular(8));

    if (clipBehavior != Clip.none) {
      content = ClipRRect(borderRadius: radius, child: content);
    }

    return Padding(
      padding: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color ?? AppColors.surfaceCard,
              color != null
                  ? color!.withValues(alpha: 0.85)
                  : AppColors.surfaceCardEnd,
            ],
          ),
          borderRadius: radius,
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: AppColors.goldGlow,
              blurRadius: 16,
              spreadRadius: 0,
            ),
          ],
        ),
        child: content,
      ),
    );
  }
}

class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool? centerTitle;
  final PreferredSizeWidget? bottom;
  final Color? backgroundColor;
  final double? elevation;
  final bool automaticallyImplyLeading;

  const GlassAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.centerTitle,
    this.bottom,
    this.backgroundColor,
    this.elevation,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppColors.surface.withValues(alpha: 0.88);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: bg,
            border: const Border(
              bottom: BorderSide(color: AppColors.borderSubtle),
            ),
          ),
          child: AppBar(
            title: title,
            actions: actions,
            leading: leading,
            automaticallyImplyLeading: automaticallyImplyLeading,
            centerTitle: centerTitle,
            bottom: bottom,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));
}
