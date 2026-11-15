import 'package:flutter/material.dart';

import '../../design/color_tokens.g.dart';
import '../../design/dr_theme.dart';
import '../../design/space_tokens.g.dart';
import '../../design/type_tokens.g.dart';

/// A bordered surface that groups related copy. The border goes all the way
/// around, never on one side.
class DrSection extends StatelessWidget {
  const DrSection({
    super.key,
    required this.child,
    this.title,
    this.body,
    this.tone = DrSectionTone.plain,
  });

  final Widget child;
  final String? title;
  final String? body;
  final DrSectionTone tone;

  @override
  Widget build(BuildContext context) {
    final DrColors colors = context.drColors;
    final DrTypeTheme type = context.drType;
    final Color fill = switch (tone) {
      DrSectionTone.plain => colors.surfaceSecondary,
      DrSectionTone.subtle => colors.surfacePrimary,
      DrSectionTone.warning => colors.surfaceWarningSubtle,
    };
    final Color border = switch (tone) {
      DrSectionTone.plain => colors.borderPrimary,
      DrSectionTone.subtle => colors.borderPrimary,
      DrSectionTone.warning => colors.borderWarning,
    };
    return Container(
      padding: const EdgeInsets.all(DrSpace.s20),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(DrRadius.r16),
        border: Border.all(color: border, width: DrSize.strokeHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (title != null) ...<Widget>[
            Text(title!, style: type.title2.copyWith(color: colors.textPrimary)),
            if (body != null) ...<Widget>[
              const SizedBox(height: DrSpace.s8),
              Text(body!, style: type.body6.copyWith(color: colors.textSecondary)),
            ],
            const SizedBox(height: DrSpace.s16),
          ],
          child,
        ],
      ),
    );
  }
}

enum DrSectionTone { plain, subtle, warning }
