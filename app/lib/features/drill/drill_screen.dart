import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_config.dart';
import '../../core/failure_copy.dart';
import '../../design/components/dr_banner.dart';
import '../../design/components/dr_button.dart';
import '../../design/components/dr_data_views.dart';
import '../../design/space_tokens.g.dart';
import '../../l10n/app_localizations.dart';
import '../../state/providers.dart';
import '../../ui/shared/dr_page.dart';
import '../../ui/shared/dr_page_header.dart';
import '../../ui/shared/dr_confirm_dialog.dart';
import '../debrief/debrief_controller.dart';
import '../session/drill_models.dart';
import '../session/session_controller.dart';
import '../voice/voice_bar.dart';
import '../voice/voice_controller.dart';
import '../voice/voice_disclosure.dart';
import 'drill_composer.dart';
import 'drill_widgets.dart';

class DrillScreen extends ConsumerStatefulWidget {
  const DrillScreen({super.key});

  @override
  ConsumerState<DrillScreen> createState() => _DrillScreenState();
}

class _DrillScreenState extends ConsumerState<DrillScreen> {
  final TextEditingController _composer = TextEditingController();
  final ScrollController _scroll = ScrollController();

  @override
  void deactivate() {
    // Leaving the drill stops any microphone or speech. The state reset is
    // deferred by one microtask because deactivate runs during a build, and
    // Riverpod cannot notify listeners mid build. End drill calls halt
    // synchronously before it navigates, so that path is never delayed.
    final VoiceController voice =
        ref.read(voiceControllerProvider.notifier);
    scheduleMicrotask(voice.halt);
    super.deactivate();
  }

  @override
  void dispose() {
    _composer.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    });
  }

  Future<void> _send() async {
    unawaited(ref.read(hapticsProvider).tap());
    final bool ok = await ref
        .read(sessionControllerProvider.notifier)
        .send(_composer.text);
    if (ok && mounted) {
      _composer.clear();
    }
  }

  Future<void> _retrySend() async {
    final bool ok = await ref.read(sessionControllerProvider.notifier).retry();
    if (ok && mounted) {
      _composer.clear();
    }
  }

  Future<void> _end() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool confirmed = await showDrConfirm(
      context: context,
      title: l10n.drillEndConfirmTitle,
      body: l10n.drillEndConfirmBody,
      confirmLabel: l10n.drillEndConfirmButton,
      cancelLabel: l10n.drillEndCancelButton,
    );
    if (!confirmed) {
      return;
    }
    ref.read(voiceControllerProvider.notifier).halt();
    await _finish();
  }

  Future<void> _finish() async {
    ref.read(voiceControllerProvider.notifier).halt();
    final bool ok = await ref.read(sessionControllerProvider.notifier).end();
    if (!mounted) {
      return;
    }
    if (ok) {
      ref.read(debriefControllerProvider.notifier).reset();
      context.go('/debrief');
    }
  }

  Future<void> _openVoice() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final VoiceDisclosureChoice choice = await showVoiceDisclosure(context, l10n);
    if (!mounted || choice == VoiceDisclosureChoice.cancel) {
      return;
    }
    if (choice == VoiceDisclosureChoice.test) {
      ref.read(voiceControllerProvider.notifier).halt();
      context.push('/voice');
      return;
    }
    await ref.read(voiceControllerProvider.notifier).enable(
          ref.read(sessionLanguageProvider),
        );
  }

  Future<void> _voiceTurn() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    await ref.read(voiceControllerProvider.notifier).listenTurn(
          language: ref.read(sessionLanguageProvider),
          fillerLine: l10n.voiceFiller,
        );
  }

  void _openVoiceCheck() {
    ref.read(voiceControllerProvider.notifier).halt();
    context.push('/voice');
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final DrillState state = ref.watch(sessionControllerProvider);
    final VoiceState voice = ref.watch(voiceControllerProvider);
    final AppConfig config = ref.watch(appConfigProvider);
    ref.listen<DrillState>(sessionControllerProvider, (DrillState? previous, DrillState next) {
      if (previous?.messages.length != next.messages.length ||
          previous?.sending != next.sending) {
        _scrollToEnd();
      }
      if (next.messages.length > (previous?.messages.length ?? 0) &&
          next.messages.last.speaker == ChatSpeaker.officer) {
        unawaited(ref.read(hapticsProvider).success());
      }
      if (next.ended && previous?.ended != true) {
        ref.read(voiceControllerProvider.notifier).halt();
        unawaited(ref.read(hapticsProvider).warn());
      }
    });
    if (!state.hasSession || state.unauthorized) {
      return _SessionGone(l10n: l10n, unauthorized: state.unauthorized);
    }
    final bool pending = state.pending != null;
    final int maxTurns = state.session!.limits.maxTurns;
    final int current = state.expectedTurnIndex.clamp(1, maxTurns).toInt();
    final bool largeText = MediaQuery.textScalerOf(context).scale(16) > 20;
    final Widget header = Padding(
      padding: const EdgeInsets.all(DrSpace.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (config.demoMode) ...<Widget>[
            DrBanner(
              message: l10n.demoBanner,
              badgeLabel: l10n.demoBadge,
              variant: DrBannerVariant.info,
            ),
            const SizedBox(height: DrSpace.s12),
          ],
          DrillHeader(
            l10n: l10n,
            turnCount: l10n.drillTurnCount(current, maxTurns),
            callState: callStateFor(
              sending: state.sending || pending,
              messageCount: state.messages.length,
            ),
            onEnd: _end,
            ending: state.ending,
          ),
        ],
      ),
    );
    final Widget chat = Padding(
      padding: const EdgeInsets.symmetric(horizontal: DrSpace.s16),
      child: ChatList(
        l10n: l10n,
        messages: state.messages,
        sending: state.sending,
        controller: _scroll,
        shrink: largeText,
      ),
    );
    final List<Widget> notices = <Widget>[
      if (state.lastTurn?.piiWarning ?? false)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DrSpace.s16),
          child: DrBanner(
            message: l10n.drillPiiWarning,
            badgeLabel: l10n.drillBadge,
            variant: DrBannerVariant.warning,
          ),
        ),
      if (state.error != null)
        Padding(
          padding: const EdgeInsets.all(DrSpace.s16),
          child: DrErrorView(
            title: l10n.errorTitle,
            message: failureMessage(l10n, state.error),
            retryLabel: l10n.retry,
            onRetry: pending ? _retrySend : _finish,
          ),
        ),
    ];
    final Widget composer = Padding(
      padding: const EdgeInsets.all(DrSpace.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (!state.ended && !state.ending) ...<Widget>[
            DrillVoiceBar(
              l10n: l10n,
              state: voice,
              onEnable: _openVoice,
              onListen: _voiceTurn,
              onStop: () =>
                  ref.read(voiceControllerProvider.notifier).stopListening(),
              onDisable: () => ref.read(voiceControllerProvider.notifier).halt(),
              onOpenCheck: _openVoiceCheck,
            ),
            const SizedBox(height: DrSpace.s8),
          ],
          state.ended && !state.ending
              ? DrillEndedPanel(l10n: l10n, onDebrief: _finish)
              : DrillComposer(
                  l10n: l10n,
                  controller: _composer,
                  sending: state.sending,
                  retrying: pending && !state.sending,
                  onSend: _send,
                  onRetry: _retrySend,
                  onChanged: (_) {},
                ),
        ],
      ),
    );
    // At large text scales the header and the composer can be taller than the
    // phone. The page then scrolls as one column instead of clipping, and the
    // practice badge stays at the top of that column.
    final Widget body = largeText
        ? SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[header, chat, ...notices, composer],
            ),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              header,
              Expanded(child: chat),
              ...notices,
              composer,
            ],
          );
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            child: body,
          ),
        ),
      ),
    );

  }
}

class _SessionGone extends StatelessWidget {
  const _SessionGone({required this.l10n, required this.unauthorized});

  final AppLocalizations l10n;
  final bool unauthorized;

  @override
  Widget build(BuildContext context) {
    return DrPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          DrPageHeader(
            title: l10n.drillTitle,
            backLabel: l10n.a11yBack,
            onBack: () => context.go('/'),
          ),
          const SizedBox(height: DrSpace.s24),
          DrEmptyView(
            title: unauthorized ? l10n.errorUnauthorized : l10n.drillSessionGoneTitle,
            message: unauthorized ? l10n.drillSessionGoneBody : l10n.drillSessionGoneBody,
            actionLabel: l10n.drillSessionGoneTry,
            onAction: () => context.go('/try'),
          ),
          const SizedBox(height: DrSpace.s12),
          DrButton(
            label: l10n.joinTitle,
            onPressed: () => context.go('/join'),
            type: DrButtonType.tertiary,
            size: DrButtonSize.md,
            expand: true,
          ),
        ],
      ),
    );
  }
}
