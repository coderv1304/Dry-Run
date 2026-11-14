import 'package:flutter/material.dart';

import '../color_tokens.g.dart';
import '../icons.g.dart';
import '../dr_theme.dart';
import '../space_tokens.g.dart';
import '../type_tokens.g.dart';
import 'dr_icon.dart';

enum DrBannerVariant { warning, info, error }

/// Notice bar carrying the DRILL badge. Copy arrives from the caller so every
/// user visible string stays in its single source.
class DrBanner extends StatelessWidget {
  const DrBanner({
    super.key,
    required this.message,
    required this.badgeLabel,
    this.variant = DrBannerVariant.warning,
  });

  final String message;
  final String badgeLabel;
  final DrBannerVariant variant;

  @override
  Widget build(BuildContext context) {
    final DrColors colors = context.drColors;
    final DrTypeTheme type = context.drType;

    final ({
      Color fill,
      Color border,
      Color label,
      Color icon,
    }) palette = switch (variant) {
      DrBannerVariant.warning => (
          fill: colors.surfaceWarningSubtle,
          border: colors.borderWarning,
          label: colors.textWarning,
          icon: colors.iconWarning,
        ),
      DrBannerVariant.info => (
          fill: colors.surfaceInfoSubtle,
          border: colors.borderAction,
          label: colors.textInfo,
          icon: colors.iconDefault,
        ),
      DrBannerVariant.error => (
          fill: colors.surfaceErrorSubtle,
          border: colors.borderError,
          label: colors.textError,
          icon: colors.iconError,
        ),
    };

    return Container(
      padding: const EdgeInsets.all(DrSpace.s12),
      decoration: BoxDecoration(
        color: palette.fill,
        borderRadius: BorderRadius.circular(DrRadius.r12),
        border: Border.all(color: palette.border, width: DrSize.strokeHairline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DrSpace.s8,
              vertical: DrSpace.s4,
            ),
            decoration: BoxDecoration(
              color: colors.surfacePrimary,
              borderRadius: BorderRadius.circular(DrRadius.r6),
              border: Border.all(color: palette.border, width: DrSize.strokeHairline),
            ),
            child: Text(badgeLabel, style: type.caption3.copyWith(color: palette.label)),
          ),
          const SizedBox(width: DrSpace.s12),
          Expanded(
            child: Text(message, style: type.body5.copyWith(color: colors.textSecondary)),
          ),
          const SizedBox(width: DrSpace.s12),
          DrIcon(data: DrIcons.warningCircle, size: DrSize.iconLg, color: palette.icon),
        ],
      ),
    );
  }
}
