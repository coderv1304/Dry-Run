import 'package:flutter/material.dart';

import '../../design/color_tokens.g.dart';
import '../../design/components/dr_banner.dart';
import '../../design/components/dr_button.dart';
import '../../design/dr_theme.dart';
import '../../design/space_tokens.g.dart';
import '../../design/type_tokens.g.dart';
import '../../l10n/app_localizations.dart';
import 'voice_controller.dart';

String voiceProblemText(AppLocalizations l10n, VoiceProblem problem) {
  return switch (problem) {
    VoiceProblem.none => '',
    VoiceProblem.permissionDenied => l10n.voiceProblemPermission,
    VoiceProblem.recognizerMissing => l10n.voiceProblemRecognizer,
    VoiceProblem.languageMissing => l10n.voiceProblemLanguage,
    VoiceProblem.ttsMissing => l10n.voiceProblemTts,
    VoiceProblem.listenFailed => l10n.voiceProblemListen,
    VoiceProblem.replyFailed => l10n.voiceProblemReply,
    VoiceProblem.replyTimeout => l10n.voiceProblemTimeout,
    VoiceProblem.speechFailed => l10n.voiceProblemSpeech,
    VoiceProblem.unavailable => l10n.voiceProblemUnavailable,
  };
}

/// The voice strip above the composer. Voice is additive: turning it off, or
/// any voice failure, leaves the text composer untouched.
class DrillVoiceBar extends StatelessWidget {
  const DrillVoiceBar({
    super.key,
    required this.l10n,
    required this.state,
    required this.onEnable,
    required this.onListen,
    required this.onStop,
    required this.onDisable,
    required this.onOpenCheck,
  });

  final AppLocalizations l10n;
  final VoiceState state;
  final VoidCallback onEnable;
  final VoidCallback onListen;
  final VoidCallback onStop;
  final VoidCallback onDisable;
  final VoidCallback onOpenCheck;

  @override
  Widget build(BuildContext context) {
    final DrColors colors = context.drColors;
    final DrTypeTheme type = context.drType;
    return Container(
      padding: const EdgeInsets.all(DrSpace.s12),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(DrRadius.r16),
        border: Border.all(
          color: colors.borderPrimary,
          width: DrSize.strokeHairline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (state.enabled) _enabled(context, type) else _disabled(context, type),
          if (state.lastRoundTrip != null) ...<Widget>[
            const SizedBox(height: DrSpace.s8),
            Text(
              l10n.voiceRoundTrip(state.lastRoundTrip!.inMilliseconds),
              style: type.caption2.copyWith(color: colors.textTertiary),
            ),
            if (state.overBudget) ...<Widget>[
              const SizedBox(height: DrSpace.s4),
              Text(
                l10n.voiceOverBudget,
                style: type.caption2.copyWith(color: colors.textSecondary),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _disabled(BuildContext context, DrTypeTheme type) {
    final DrColors colors = context.drColors;
    final bool preparing = state.phase == VoicePhase.preparing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          l10n.voiceHelper,
          style: type.caption2.copyWith(color: colors.textSecondary),
        ),
        if (state.problem != VoiceProblem.none) ...<Widget>[
          const SizedBox(height: DrSpace.s8),
          DrBanner(
            message: voiceProblemText(l10n, state.problem),
            badgeLabel: l10n.errorTitle,
            variant: state.problem == VoiceProblem.permissionDenied ||
                    state.problem == VoiceProblem.listenFailed
                ? DrBannerVariant.warning
                : DrBannerVariant.error,
          ),
        ],
        const SizedBox(height: DrSpace.s8),
        Wrap(
          spacing: DrSpace.s8,
          runSpacing: DrSpace.s8,
          children: <Widget>[
            DrButton(
              label: preparing ? l10n.voiceCheckTesting : l10n.voiceUse,
              onPressed: preparing ? null : onEnable,
              type: DrButtonType.secondary,
              size: DrButtonSize.md,
            ),
            DrButton(
              label: l10n.voiceCheckLink,
              onPressed: onOpenCheck,
              type: DrButtonType.tertiary,
              size: DrButtonSize.md,
            ),
          ],
        ),
      ],
    );
  }

  Widget _enabled(BuildContext context, DrTypeTheme type) {
    final DrColors colors = context.drColors;
    final VoicePhase phase = state.phase;
    final bool showProblem = state.problem != VoiceProblem.none;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (phase == VoicePhase.listening)
          DrBanner(
            message: l10n.voiceListening,
            badgeLabel: l10n.voiceBadge,
            variant: DrBannerVariant.info,
          )
        else if (phase == VoicePhase.thinking)
          Text(
            l10n.voiceThinking,
            style: type.body5.copyWith(color: colors.textSecondary),
          )
        else if (phase == VoicePhase.speaking)
          Text(
            l10n.voiceSpeaking,
            style: type.body5.copyWith(color: colors.textSecondary),
          )
        else
          Text(
            l10n.voiceReady,
            style: type.caption2.copyWith(color: colors.textSecondary),
          ),
        if (showProblem) ...<Widget>[
          const SizedBox(height: DrSpace.s8),
          DrBanner(
            message: voiceProblemText(l10n, state.problem),
            badgeLabel: l10n.errorTitle,
            variant: state.problem == VoiceProblem.listenFailed ||
                    state.problem == VoiceProblem.replyFailed ||
                    state.problem == VoiceProblem.replyTimeout
                ? DrBannerVariant.warning
                : DrBannerVariant.error,
          ),
        ],
        const SizedBox(height: DrSpace.s8),
        Wrap(
          spacing: DrSpace.s8,
          runSpacing: DrSpace.s8,
          children: <Widget>[
            if (phase == VoicePhase.listening)
              DrButton(
                label: l10n.voiceStop,
                onPressed: onStop,
                type: DrButtonType.secondary,
                size: DrButtonSize.md,
              )
            else
              DrButton(
                label: showProblem ? l10n.voiceRetry : l10n.voiceSpeak,
                onPressed: phase == VoicePhase.thinking ? null : onListen,
                type: DrButtonType.primary,
                size: DrButtonSize.md,
              ),
            DrButton(
              label: l10n.voiceTurnOff,
              onPressed: onDisable,
              type: DrButtonType.tertiary,
              size: DrButtonSize.md,
            ),
            DrButton(
              label: l10n.voiceCheckLink,
              onPressed: onOpenCheck,
              type: DrButtonType.tertiary,
              size: DrButtonSize.md,
            ),
          ],
        ),
        if (showProblem) ...<Widget>[
          const SizedBox(height: DrSpace.s4),
          Text(
            l10n.voiceKeepTyping,
            style: type.caption2.copyWith(color: colors.textTertiary),
          ),
        ],
      ],
    );
  }
}
