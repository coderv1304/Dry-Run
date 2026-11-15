import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/failure_copy.dart';
import '../../design/components/dr_banner.dart';
import '../../design/components/dr_button.dart';
import '../../design/components/dr_data_views.dart';
import '../../design/space_tokens.g.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/shared/dr_page.dart';
import '../../ui/shared/dr_page_header.dart';
import '../../ui/shared/dr_confirm_dialog.dart';
import '../debrief/debrief_controller.dart';
import '../session/drill_models.dart';
import '../session/session_controller.dart';
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
    await _finish();
  }

  Future<void> _finish() async {
    final bool ok = await ref.read(sessionControllerProvider.notifier).end();
    if (!mounted) {
      return;
    }
    if (ok) {
      ref.read(debriefControllerProvider.notifier).reset();
      context.go('/debrief');
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final DrillState state = ref.watch(sessionControllerProvider);
    ref.listen<DrillState>(sessionControllerProvider, (DrillState? previous, DrillState next) {
      if (previous?.messages.length != next.messages.length ||
          previous?.sending != next.sending) {
        _scrollToEnd();
      }
    });
    if (!state.hasSession || state.unauthorized) {
      return _SessionGone(l10n: l10n, unauthorized: state.unauthorized);
    }
    final bool pending = state.pending != null;
    final int maxTurns = state.session!.limits.maxTurns;
    final int current = state.expectedTurnIndex.clamp(1, maxTurns).toInt();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(DrSpace.s16),
                  child: DrillHeader(
                    l10n: l10n,
                    turnCount: l10n.drillTurnCount(current, maxTurns),
                    onEnd: _end,
                    ending: state.ending,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: DrSpace.s16),
                    child: ChatList(
                      l10n: l10n,
                      messages: state.messages,
                      sending: state.sending,
                      controller: _scroll,
                    ),
                  ),
                ),
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
                Padding(
                  padding: const EdgeInsets.all(DrSpace.s16),
                  child: state.ended && !state.ending
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
                ),
              ],
            ),
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
