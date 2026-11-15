import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/failure_copy.dart';
import '../../core/share_service.dart';
import '../../design/components/dr_banner.dart';
import '../../design/components/dr_data_views.dart';
import '../../design/space_tokens.g.dart';
import '../../l10n/app_localizations.dart';
import '../../state/providers.dart';
import '../../ui/shared/dr_confirm_dialog.dart';
import '../../ui/shared/dr_page.dart';
import '../../ui/shared/dr_page_header.dart';
import 'debrief_actions.dart';
import 'debrief_body.dart';
import 'debrief_controller.dart';
import 'debrief_copy.dart';
import '../../design/dr_theme.dart';

class DebriefScreen extends ConsumerStatefulWidget {
  const DebriefScreen({super.key});

  @override
  ConsumerState<DebriefScreen> createState() => _DebriefScreenState();
}

class _DebriefScreenState extends ConsumerState<DebriefScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final DebriefState state = ref.read(debriefControllerProvider);
      if (!state.deleted && !state.missing && state.response == null) {
        ref.read(debriefControllerProvider.notifier).load();
      }
    });
  }

  Future<void> _share() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool confirmed = await showDrConfirm(
      context: context,
      title: l10n.debriefShareDialogTitle,
      body: l10n.debriefShareDialogBody,
      confirmLabel: l10n.debriefShareConfirm,
      cancelLabel: l10n.debriefShareCancel,
    );
    if (!confirmed || !mounted) {
      return;
    }
    final String? url = await ref.read(debriefControllerProvider.notifier).share();
    if (url == null || !mounted) {
      return;
    }
    final ShareService share = ref.read(shareServiceProvider);
    try {
      await share.share(
        text: l10n.shareReportMessage(url),
        subject: l10n.reportShareSubject,
      );
    } on Object {
      await share.copy(url);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.shareUnavailable)),
        );
      }
    }
  }

  Future<void> _delete() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool confirmed = await showDrConfirm(
      context: context,
      title: l10n.debriefDeleteDialogTitle,
      body: l10n.debriefDeleteDialogBody,
      confirmLabel: l10n.debriefDeleteConfirm,
      cancelLabel: l10n.debriefDeleteCancel,
      destructive: true,
    );
    if (!confirmed || !mounted) {
      return;
    }
    await ref.read(debriefControllerProvider.notifier).delete();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final DebriefState state = ref.watch(debriefControllerProvider);
    final bool hasContent = state.content != null;
    ref.listen<DebriefState>(debriefControllerProvider,
        (DebriefState? previous, DebriefState next) {
      if (next.content != null && previous?.content == null) {
        unawaited(ref.read(hapticsProvider).success());
      }
    });
    return DrPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          DrPageHeader(
            title: l10n.debriefTitle,
            subtitle: hasContent
                ? qualityName(l10n, state.content!.quality)
                : l10n.debriefPending,
            backLabel: l10n.debriefBackHome,
            onBack: () => context.go('/'),
          ),
          const SizedBox(height: DrSpace.s24),
          if (state.deleted)
            DrEmptyView(
              title: l10n.debriefDeletedTitle,
              message: l10n.debriefDeletedBody,
              actionLabel: l10n.debriefBackHome,
              onAction: () => context.go('/'),
            )
          else if (state.missing)
            DrEmptyView(
              title: l10n.drillSessionGoneTitle,
              message: l10n.drillSessionGoneBody,
              actionLabel: l10n.drillSessionGoneTry,
              onAction: () => context.go('/try'),
            )
          else if (state.loading && !hasContent) ...<Widget>[
            Text(l10n.debriefPending, style: context.drType.body3.copyWith(color: context.drColors.textSecondary)),
            const SizedBox(height: DrSpace.s16),
            const DrSkeleton(lines: 5),
          ] else if (state.error != null && !hasContent)
            DrErrorView(
              title: l10n.errorTitle,
              message: failureMessage(l10n, state.error),
              retryLabel: l10n.debriefRetry,
              onRetry: () => ref.read(debriefControllerProvider.notifier).load(),
            )
          else if (hasContent) ...<Widget>[
            if (state.polling) ...<Widget>[
              DrBanner(
                message: l10n.debriefRefining,
                badgeLabel: l10n.debriefRefiningShort,
                variant: DrBannerVariant.info,
              ),
              const SizedBox(height: DrSpace.s16),
            ],
            DebriefBody(l10n: l10n, content: state.content!),
            const SizedBox(height: DrSpace.s24),
            DebriefActions(
              l10n: l10n,
              sharing: state.sharing,
              deleting: state.deleting,
              onShare: _share,
              onDelete: _delete,
            ),
            if (state.error != null) ...<Widget>[
              const SizedBox(height: DrSpace.s16),
              DrErrorView(
                title: l10n.errorTitle,
                message: failureMessage(l10n, state.error),
                retryLabel: l10n.debriefRetry,
                onRetry: () => ref.read(debriefControllerProvider.notifier).load(),
              ),
            ],
            if (state.shareError != null) ...<Widget>[
              const SizedBox(height: DrSpace.s16),
              DrBanner(
                message: l10n.debriefShareFailed,
                badgeLabel: l10n.errorTitle,
                variant: DrBannerVariant.error,
              ),
            ],
            if (state.deleteError != null) ...<Widget>[
              const SizedBox(height: DrSpace.s16),
              DrBanner(
                message: failureMessage(l10n, state.deleteError),
                badgeLabel: l10n.errorTitle,
                variant: DrBannerVariant.error,
              ),
            ],
          ],
        ],
      ),
    );
  }
}
