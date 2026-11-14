import 'package:flutter/material.dart';

import '../color_tokens.g.dart';
import '../icons.g.dart';
import '../dr_theme.dart';
import '../space_tokens.g.dart';
import '../type_tokens.g.dart';
import 'dr_button.dart';
import 'dr_icon.dart';

/// Loading state: blocks shaped like the real layout, never a spinner.
class DrSkeleton extends StatelessWidget {
  const DrSkeleton({super.key, this.lines = 3});

  final int lines;

  @override
  Widget build(BuildContext context) {
    final DrColors colors = context.drColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int index = 0; index < lines; index++)
          Padding(
            padding: EdgeInsets.only(bottom: index == lines - 1 ? DrSpace.s0 : DrSpace.s12),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: index == 0 ? 1 : (index % 2 == 0 ? 0.6 : 0.85),
              child: Container(
                height: index == 0 ? DrSpace.s20 : DrSpace.s16,
                decoration: BoxDecoration(
                  color: colors.surfaceDisabled,
                  borderRadius: BorderRadius.circular(DrRadius.r6),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Empty state: a composed getting started view, never a blank panel.
class DrEmptyView extends StatelessWidget {
  const DrEmptyView({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final DrColors colors = context.drColors;
    final DrTypeTheme type = context.drType;
    return Container(
      padding: const EdgeInsets.all(DrSpace.s24),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(DrRadius.r16),
        border: Border.all(color: colors.borderPrimary, width: DrSize.strokeHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(DrSpace.s8),
            decoration: BoxDecoration(
              color: colors.surfacePrimary,
              borderRadius: BorderRadius.circular(DrRadius.r8),
              border: Border.all(color: colors.borderPrimary, width: DrSize.strokeHairline),
            ),
            child: DrIcon(
              data: DrIcons.clipboardText,
              size: DrSize.iconLg,
              color: colors.iconSecondary,
            ),
          ),
          const SizedBox(height: DrSpace.s16),
          Text(title, style: type.title2.copyWith(color: colors.textPrimary)),
          const SizedBox(height: DrSpace.s8),
          Text(message, style: type.body6.copyWith(color: colors.textSecondary)),
          if (actionLabel != null && onAction != null) ...<Widget>[
            const SizedBox(height: DrSpace.s16),
            DrButton(
              label: actionLabel!,
              onPressed: onAction,
              type: DrButtonType.tertiary,
              size: DrButtonSize.sm,
              leadingIcon: DrIcon(
                data: DrIcons.arrowRight,
                size: DrSize.iconSm,
                color: colors.textPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Error state: inline and specific, with a retry action. Never a system alert.
class DrErrorView extends StatelessWidget {
  const DrErrorView({
    super.key,
    required this.title,
    required this.message,
    required this.retryLabel,
    this.onRetry,
  });

  final String title;
  final String message;
  final String retryLabel;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final DrColors colors = context.drColors;
    final DrTypeTheme type = context.drType;
    return Container(
      padding: const EdgeInsets.all(DrSpace.s24),
      decoration: BoxDecoration(
        color: colors.surfaceErrorSubtle,
        borderRadius: BorderRadius.circular(DrRadius.r16),
        border: Border.all(color: colors.borderError, width: DrSize.strokeHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          DrIcon(
            data: DrIcons.warningCircle,
            size: DrSize.iconXl,
            color: colors.iconError,
          ),
          const SizedBox(height: DrSpace.s16),
          Text(title, style: type.title2.copyWith(color: colors.textPrimary)),
          const SizedBox(height: DrSpace.s8),
          Text(message, style: type.body6.copyWith(color: colors.textSecondary)),
          const SizedBox(height: DrSpace.s16),
          DrButton(
            label: retryLabel,
            onPressed: onRetry,
            type: DrButtonType.secondary,
            size: DrButtonSize.sm,
          ),
        ],
      ),
    );
  }
}
