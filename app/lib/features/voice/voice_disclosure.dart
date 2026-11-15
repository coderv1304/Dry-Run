import 'package:flutter/material.dart';

import '../../design/color_tokens.g.dart';
import '../../design/components/dr_button.dart';
import '../../design/dr_theme.dart';
import '../../design/space_tokens.g.dart';
import '../../design/type_tokens.g.dart';
import '../../l10n/app_localizations.dart';

enum VoiceDisclosureChoice { enable, test, cancel }

/// The disclosure always comes before any microphone permission request.
Future<VoiceDisclosureChoice> showVoiceDisclosure(
  BuildContext context,
  AppLocalizations l10n,
) async {
  final VoiceDisclosureChoice? choice =
      await showDialog<VoiceDisclosureChoice>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) =>
        _VoiceDisclosureDialog(l10n: l10n),
  );
  return choice ?? VoiceDisclosureChoice.cancel;
}

class _VoiceDisclosureDialog extends StatelessWidget {
  const _VoiceDisclosureDialog({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final DrColors colors = context.drColors;
    final DrTypeTheme type = context.drType;
    return Dialog(
      backgroundColor: colors.surfacePrimary,
      insetPadding: const EdgeInsets.all(DrSpace.s16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DrRadius.r16),
        side: BorderSide(
          color: colors.borderPrimary,
          width: DrSize.strokeHairline,
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(DrSpace.s20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                l10n.voiceDisclosureTitle,
                style: type.heading6.copyWith(color: colors.textPrimary),
              ),
              const SizedBox(height: DrSpace.s12),
              Text(
                l10n.voiceDisclosureBody,
                style: type.body3.copyWith(color: colors.textSecondary),
              ),
              const SizedBox(height: DrSpace.s20),
              DrButton(
                label: l10n.voiceDisclosureConfirm,
                onPressed: () => Navigator.of(context)
                    .pop(VoiceDisclosureChoice.enable),
                type: DrButtonType.primary,
                size: DrButtonSize.lg,
                elder: true,
                expand: true,
              ),
              const SizedBox(height: DrSpace.s8),
              DrButton(
                label: l10n.voiceDisclosureTest,
                onPressed: () =>
                    Navigator.of(context).pop(VoiceDisclosureChoice.test),
                type: DrButtonType.secondary,
                size: DrButtonSize.md,
                expand: true,
              ),
              const SizedBox(height: DrSpace.s8),
              DrButton(
                label: l10n.voiceDisclosureCancel,
                onPressed: () =>
                    Navigator.of(context).pop(VoiceDisclosureChoice.cancel),
                type: DrButtonType.tertiary,
                size: DrButtonSize.md,
                expand: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
