import 'package:api_client/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/failure_copy.dart';
import '../../design/color_tokens.g.dart';
import '../../design/components/dr_banner.dart';
import '../../design/components/dr_button.dart';
import '../../design/components/dr_data_views.dart';
import '../../design/components/dr_icon.dart';
import '../../design/icons.g.dart';
import '../../design/dr_theme.dart';
import '../../design/space_tokens.g.dart';
import '../../design/type_tokens.g.dart';
import '../../l10n/app_localizations.dart';
import '../../state/token_store.dart';
import '../../ui/shared/dr_page.dart';
import '../../ui/shared/dr_page_header.dart';
import '../../ui/shared/dr_section.dart';
import '../invite/language_name.dart';
import 'consent_controller.dart';

class ConsentScreen extends ConsumerStatefulWidget {
  const ConsentScreen({super.key});

  @override
  ConsumerState<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends ConsumerState<ConsentScreen> {
  bool _statsOptIn = false;

  @override
  void initState() {
    super.initState();
    final String? token = ref.read(tokenStoreProvider).inviteToken;
    if (token != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => ref.read(consentControllerProvider.notifier).load(token),
      );
    }
  }

  Future<void> _start() async {
    final String? token = ref.read(tokenStoreProvider).inviteToken;
    if (token == null) {
      return;
    }
    final bool ok = await ref.read(consentControllerProvider.notifier).start(
          statsOptIn: _statsOptIn,
          token: token,
        );
    if (ok && mounted) {
      context.go('/drill');
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String? token = ref.watch(tokenStoreProvider).inviteToken;
    final ConsentState state = ref.watch(consentControllerProvider);
    return DrPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          DrPageHeader(
            title: l10n.consentTitle,
            backLabel: l10n.a11yBack,
            onBack: () => context.go('/'),
          ),
          const SizedBox(height: DrSpace.s24),
          if (token == null)
            DrEmptyView(
              title: l10n.drillSessionGoneTitle,
              message: l10n.drillSessionGoneBody,
              actionLabel: l10n.drillSessionGoneTry,
              onAction: () => context.go('/try'),
            )
          else if (state.loading) ...<Widget>[
            Text(l10n.joinValidating, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: DrSpace.s16),
            const DrSkeleton(lines: 3),
          ] else if (state.loadError != null)
            DrErrorView(
              title: l10n.errorTitle,
              message: failureMessage(l10n, state.loadError),
              retryLabel: l10n.retry,
              onRetry: () =>
                  ref.read(consentControllerProvider.notifier).load(token),
            )
          else
            _ConsentBody(
              l10n: l10n,
              language: state.language,
              statsOptIn: _statsOptIn,
              starting: state.starting,
              error: state.startError,
              onStatsChanged: (bool value) => setState(() => _statsOptIn = value),
              onStart: _start,
              onDecline: () {
                ref.read(consentControllerProvider.notifier).decline();
                context.go('/');
              },
            ),
        ],
      ),
    );
  }
}

class _ConsentBody extends StatelessWidget {
  const _ConsentBody({
    required this.l10n,
    required this.language,
    required this.statsOptIn,
    required this.starting,
    required this.error,
    required this.onStatsChanged,
    required this.onStart,
    required this.onDecline,
  });

  final AppLocalizations l10n;
  final AppLanguage? language;
  final bool statsOptIn;
  final bool starting;
  final Object? error;
  final ValueChanged<bool> onStatsChanged;
  final VoidCallback onStart;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final DrColors colors = context.drColors;
    final DrTypeTheme type = context.drType;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        DrSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _PracticeLine(text: l10n.consentPracticeLine1),
              const SizedBox(height: DrSpace.s12),
              _PracticeLine(text: l10n.consentPracticeLine2),
              const SizedBox(height: DrSpace.s12),
              _PracticeLine(text: l10n.consentPracticeLine3),
            ],
          ),
        ),
        if (language != null) ...<Widget>[
          const SizedBox(height: DrSpace.s12),
          Text(
            l10n.consentInviteMeta(languageName(l10n, language!)),
            style: type.caption2.copyWith(color: colors.textTertiary),
          ),
        ],
        const SizedBox(height: DrSpace.s20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Checkbox(
              value: statsOptIn,
              onChanged: (bool? value) => onStatsChanged(value ?? false),
            ),
            const SizedBox(width: DrSpace.s8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    l10n.consentStatsOptInLabel,
                    style: type.title4.copyWith(color: colors.textPrimary),
                  ),
                  const SizedBox(height: DrSpace.s2),
                  Text(
                    l10n.consentStatsOptInHelp,
                    style: type.caption2.copyWith(color: colors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (error != null) ...<Widget>[
          const SizedBox(height: DrSpace.s16),
          DrBanner(
            message: failureMessage(l10n, error),
            badgeLabel: l10n.errorTitle,
            variant: DrBannerVariant.error,
          ),
        ],
        const SizedBox(height: DrSpace.s24),
        DrButton(
          label: starting ? l10n.consentStarting : l10n.consentStartButton,
          onPressed: starting ? null : onStart,
          type: DrButtonType.primary,
          size: DrButtonSize.lg,
          elder: true,
          expand: true,
        ),
        const SizedBox(height: DrSpace.s8),
        DrButton(
          label: l10n.consentDecline,
          onPressed: starting ? null : onDecline,
          type: DrButtonType.tertiary,
          size: DrButtonSize.md,
          expand: true,
        ),
        const SizedBox(height: DrSpace.s12),
        Text(
          l10n.consentPrivacyNote,
          style: type.caption2.copyWith(color: colors.textTertiary),
        ),
      ],
    );
  }

}

class _PracticeLine extends StatelessWidget {
  const _PracticeLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final DrColors colors = context.drColors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        DrIcon(
          data: DrIcons.checkCircle,
          size: DrSize.iconMd,
          color: colors.iconSuccess,
        ),
        const SizedBox(width: DrSpace.s8),
        Expanded(
          child: Text(
            text,
            style: context.drType.body3.copyWith(color: colors.textPrimary),
          ),
        ),
      ],
    );
  }
}
