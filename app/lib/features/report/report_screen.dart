import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/failure_copy.dart';
import '../../design/components/dr_data_views.dart';
import '../../design/dr_theme.dart';
import '../../design/space_tokens.g.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/shared/dr_page.dart';
import '../../ui/shared/dr_page_header.dart';
import '../debrief/debrief_body.dart';
import 'report_controller.dart';

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ReportState state = ref.read(reportControllerProvider);
      if (state.report == null && !state.loading && !state.missing && !state.gone) {
        ref.read(reportControllerProvider.notifier).load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ReportState state = ref.watch(reportControllerProvider);
    return DrPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          DrPageHeader(
            title: l10n.reportTitle,
            subtitle: l10n.reportIntro,
            backLabel: l10n.reportBackHome,
            onBack: () => context.go('/'),
          ),
          const SizedBox(height: DrSpace.s24),
          if (state.missing || state.gone)
            DrEmptyView(
              title: l10n.reportGoneTitle,
              message: l10n.reportGoneBody,
              actionLabel: l10n.reportBackHome,
              onAction: () => context.go('/'),
            )
          else if (state.loading && state.report == null) ...<Widget>[
            Text(l10n.reportLoading, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: DrSpace.s16),
            const DrSkeleton(lines: 5),
          ] else if (state.error != null && state.report == null)
            DrErrorView(
              title: l10n.errorTitle,
              message: failureMessage(l10n, state.error),
              retryLabel: l10n.retry,
              onRetry: () => ref.read(reportControllerProvider.notifier).load(),
            )
          else if (state.report != null) ...<Widget>[
            Text(
              l10n.reportSharedAt(_formatDate(l10n, state.report!.sharedAt)),
              style: context.drType.caption2
                  .copyWith(color: context.drColors.textTertiary),
            ),
            const SizedBox(height: DrSpace.s16),
            DebriefBody(l10n: l10n, content: state.report!.debrief),
          ],
        ],
      ),
    );
  }

  String _formatDate(AppLocalizations l10n, String raw) {
    final DateTime? parsed = DateTime.tryParse(raw);
    if (parsed == null) {
      return raw;
    }
    return DateFormat.yMMMd(l10n.localeName).format(parsed.toLocal());
  }
}
