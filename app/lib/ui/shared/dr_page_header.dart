import 'package:flutter/material.dart';

import '../../design/color_tokens.g.dart';
import '../../design/components/dr_button.dart';
import '../../design/dr_theme.dart';
import '../../design/space_tokens.g.dart';
import '../../design/type_tokens.g.dart';

class DrPageHeader extends StatelessWidget {
  const DrPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.backLabel,
    this.eyebrow,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final String? backLabel;
  final String? eyebrow;

  @override
  Widget build(BuildContext context) {
    final DrColors colors = context.drColors;
    final DrTypeTheme type = context.drType;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (onBack != null && backLabel != null) ...<Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: DrButton(
              label: backLabel!,
              onPressed: onBack,
              type: DrButtonType.tertiary,
              size: DrButtonSize.sm,
            ),
          ),
          const SizedBox(height: DrSpace.s12),
        ],
        if (eyebrow != null) ...<Widget>[
          Text(
            eyebrow!,
            style: type.caption1.copyWith(color: colors.textTertiary),
          ),
          const SizedBox(height: DrSpace.s4),
        ],
        Text(title, style: type.heading3.copyWith(color: colors.textPrimary)),
        if (subtitle != null) ...<Widget>[
          const SizedBox(height: DrSpace.s8),
          Text(subtitle!, style: type.body5.copyWith(color: colors.textSecondary)),
        ],
      ],
    );
  }
}
