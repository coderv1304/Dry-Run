import 'package:api_client/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../design/color_tokens.g.dart';
import '../../design/components/dr_banner.dart';
import '../../design/components/dr_button.dart';
import '../../design/dr_theme.dart';
import '../../design/space_tokens.g.dart';
import '../../design/type_tokens.g.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/shared/dr_page.dart';
import '../../ui/shared/dr_page_header.dart';
import '../../ui/shared/dr_section.dart';
import '../invite/language_name.dart';
import 'voice_readiness_controller.dart';

class VoiceReadinessScreen extends ConsumerWidget {
  const VoiceReadinessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final VoiceReadinessState state = ref.watch(voiceReadinessProvider);
    final VoiceReadinessController controller =
        ref.read(voiceReadinessProvider.notifier);
    return DrPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          DrPageHeader(
            title: l10n.voiceCheckTitle,
            subtitle: l10n.voiceCheckIntro,
            backLabel: l10n.voiceCheckBack,
            onBack: () => context.go('/drill'),
          ),
          const SizedBox(height: DrSpace.s24),
          DrBanner(
            message: state.allPassed
                ? l10n.voiceCheckPass
                : state.hasFailure
                    ? l10n.voiceCheckFail
                    : l10n.voiceCheckPending,
            badgeLabel: state.allPassed
                ? l10n.voiceCheckPassShort
                : state.hasFailure
                    ? l10n.voiceCheckFailShort
                    : l10n.voiceCheckBadge,
            variant: state.hasFailure
                ? DrBannerVariant.warning
                : DrBannerVariant.info,
          ),
          const SizedBox(height: DrSpace.s20),
          DrSection(
            title: l10n.voiceCheckMicrophone,
            child: _CheckRow(
              l10n: l10n,
              status: state.microphone,
              detail: switch (state.microphone) {
                VoiceCheckStatus.pass => l10n.voiceCheckMicrophoneOn,
                VoiceCheckStatus.fail => l10n.voiceCheckMicrophoneOff,
                _ => l10n.voiceCheckPending,
              },
              actionLabel: l10n.voiceCheckStart,
              onAction: controller.start,
            ),
          ),
          const SizedBox(height: DrSpace.s20),
          DrSection(
            title: l10n.voiceCheckRecognition,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _CheckRow(
                  l10n: l10n,
                  status: state.recognitionEnglish,
                  detail: _recognitionDetail(
                    l10n,
                    state.recognitionEnglish,
                    state.heardEnglish,
                  ),
                  actionLabel: l10n.voiceCheckLanguageTest(
                    languageName(l10n, AppLanguage.en),
                  ),
                  onAction: () =>
                      controller.testRecognition(AppLanguage.en),
                ),
                const SizedBox(height: DrSpace.s16),
                _CheckRow(
                  l10n: l10n,
                  status: state.recognitionHindi,
                  detail: _recognitionDetail(
                    l10n,
                    state.recognitionHindi,
                    state.heardHindi,
                  ),
                  actionLabel: l10n.voiceCheckLanguageTest(
                    languageName(l10n, AppLanguage.hi),
                  ),
                  onAction: () => controller.testRecognition(AppLanguage.hi),
                ),
              ],
            ),
          ),
          const SizedBox(height: DrSpace.s20),
          DrSection(
            title: l10n.voiceCheckTts,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _CheckRow(
                  l10n: l10n,
                  status: state.ttsEnglish,
                  detail: _ttsDetail(
                    l10n,
                    state.ttsEnglish,
                    AppLanguage.en,
                  ),
                  actionLabel: l10n.voiceCheckTtsTest(
                    languageName(l10n, AppLanguage.en),
                  ),
                  onAction: () => controller.testTts(AppLanguage.en),
                ),
                const SizedBox(height: DrSpace.s16),
                _CheckRow(
                  l10n: l10n,
                  status: state.ttsHindi,
                  detail: _ttsDetail(l10n, state.ttsHindi, AppLanguage.hi),
                  actionLabel: l10n.voiceCheckTtsTest(
                    languageName(l10n, AppLanguage.hi),
                  ),
                  onAction: () => controller.testTts(AppLanguage.hi),
                ),
              ],
            ),
          ),
          const SizedBox(height: DrSpace.s20),
          DrSection(
            title: l10n.voiceCheckRoundTrip,
            child: _CheckRow(
              l10n: l10n,
              status: state.roundTrip,
              detail: _roundTripDetail(l10n, state),
              actionLabel: l10n.voiceCheckRoundTripTest,
              onAction: () => controller.runRoundTrip(AppLanguage.en),
            ),
          ),
          const SizedBox(height: DrSpace.s20),
          Text(
            l10n.voiceCheckNote,
            style: context.drType.caption2
                .copyWith(color: context.drColors.textTertiary),
          ),
        ],
      ),
    );
  }

  String _recognitionDetail(
    AppLocalizations l10n,
    VoiceCheckStatus status,
    String? heard,
  ) {
    if (status == VoiceCheckStatus.testing) {
      return l10n.voiceCheckTesting;
    }
    if (status == VoiceCheckStatus.pass && heard != null) {
      return l10n.voiceCheckHeard(heard);
    }
    if (status == VoiceCheckStatus.fail) {
      return l10n.voiceCheckNothingHeard;
    }
    return l10n.voiceCheckPending;
  }

  String _ttsDetail(
    AppLocalizations l10n,
    VoiceCheckStatus status,
    AppLanguage language,
  ) {
    final String name = languageName(l10n, language);
    if (status == VoiceCheckStatus.pass) {
      return l10n.voiceCheckTtsOn(name);
    }
    if (status == VoiceCheckStatus.fail) {
      return l10n.voiceCheckTtsOff(name);
    }
    if (status == VoiceCheckStatus.testing) {
      return l10n.voiceCheckTesting;
    }
    return l10n.voiceCheckPending;
  }

  String _roundTripDetail(
    AppLocalizations l10n,
    VoiceReadinessState state,
  ) {
    if (state.roundTrip == VoiceCheckStatus.testing) {
      return l10n.voiceCheckTesting;
    }
    final Duration? latency = state.latency;
    if (latency == null) {
      return l10n.voiceCheckPending;
    }
    return state.roundTrip == VoiceCheckStatus.pass
        ? l10n.voiceCheckRoundTripResult(latency.inMilliseconds)
        : l10n.voiceCheckRoundTripSlow(latency.inMilliseconds);
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({
    required this.l10n,
    required this.status,
    required this.detail,
    required this.actionLabel,
    required this.onAction,
  });

  final AppLocalizations l10n;
  final VoiceCheckStatus status;
  final String detail;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final DrColors colors = context.drColors;
    final DrTypeTheme type = context.drType;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Text(
                status == VoiceCheckStatus.testing
                    ? l10n.voiceCheckTesting
                    : detail,
                style: type.body5.copyWith(color: colors.textSecondary),
              ),
            ),
            const SizedBox(width: DrSpace.s8),
            _StatusBadge(l10n: l10n, status: status),
          ],
        ),
        const SizedBox(height: DrSpace.s8),
        Align(
          alignment: Alignment.centerLeft,
          child: DrButton(
            label: actionLabel,
            onPressed: status == VoiceCheckStatus.testing ? null : onAction,
            type: DrButtonType.tertiary,
            size: DrButtonSize.sm,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.l10n, required this.status});

  final AppLocalizations l10n;
  final VoiceCheckStatus status;

  @override
  Widget build(BuildContext context) {
    final DrColors colors = context.drColors;
    final (Color fill, Color text) = switch (status) {
      VoiceCheckStatus.pass => (colors.surfaceSuccessSubtle, colors.textSuccess),
      VoiceCheckStatus.fail => (colors.surfaceErrorSubtle, colors.textError),
      VoiceCheckStatus.testing => (colors.surfaceInfoSubtle, colors.textInfo),
      VoiceCheckStatus.untested => (
          colors.surfaceSecondary,
          colors.textTertiary,
        ),
    };
    final String label = switch (status) {
      VoiceCheckStatus.pass => l10n.voiceCheckPassShort,
      VoiceCheckStatus.fail => l10n.voiceCheckFailShort,
      VoiceCheckStatus.testing => l10n.voiceCheckTesting,
      VoiceCheckStatus.untested => l10n.voiceCheckPending,
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DrSpace.s8,
        vertical: DrSpace.s4,
      ),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(DrRadius.r8),
      ),
      child: Text(
        label,
        style: context.drType.caption3.copyWith(color: text),
      ),
    );
  }
}
