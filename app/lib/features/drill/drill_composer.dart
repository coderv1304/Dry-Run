import 'package:flutter/material.dart';

import '../../design/color_tokens.g.dart';
import '../../design/components/dr_button.dart';
import '../../design/components/dr_icon.dart';
import '../../design/components/dr_text_field.dart';
import '../../design/icons.g.dart';
import '../../design/dr_theme.dart';
import '../../design/space_tokens.g.dart';
import '../../l10n/app_localizations.dart';

class DrillComposer extends StatelessWidget {
  const DrillComposer({
    super.key,
    required this.l10n,
    required this.controller,
    required this.sending,
    required this.retrying,
    required this.onSend,
    required this.onRetry,
    required this.onChanged,
  });

  final AppLocalizations l10n;
  final TextEditingController controller;
  final bool sending;
  final bool retrying;
  final VoidCallback onSend;
  final VoidCallback onRetry;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final DrColors colors = context.drColors;
    final Widget field = DrTextField(
      label: l10n.drillYourTurn,
      hint: l10n.drillInputHint,
      controller: controller,
      enabled: !sending && !retrying,
      maxLines: 3,
      elder: true,
      onChanged: onChanged,
    );
    final Widget action = DrButton(
      label: retrying
          ? l10n.drillErrorRetry
          : sending
              ? l10n.drillSending
              : l10n.drillSend,
      onPressed: sending ? null : (retrying ? onRetry : onSend),
      type: DrButtonType.primary,
      size: DrButtonSize.lg,
      elder: true,
      leadingIcon: DrIcon(
        data: DrIcons.arrowRight,
        size: DrSize.iconMd,
        color: colors.textOnAction,
      ),
    );
    return Container(
      padding: const EdgeInsets.all(DrSpace.s12),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(DrRadius.r16),
        border: Border.all(color: colors.borderPrimary, width: DrSize.strokeHairline),
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxWidth < 560) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                field,
                const SizedBox(height: DrSpace.s8),
                Align(alignment: Alignment.centerRight, child: action),
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(child: field),
              const SizedBox(width: DrSpace.s8),
              action,
            ],
          );
        },
      ),
    );
  }
}
