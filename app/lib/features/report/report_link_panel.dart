import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../design/components/dr_button.dart';
import '../../design/components/dr_text_field.dart';
import '../../design/space_tokens.g.dart';
import '../../l10n/app_localizations.dart';
import '../../state/providers.dart';
import '../../state/token_store.dart';
import '../../ui/shared/dr_section.dart';
import '../report/report_controller.dart';

class ReportLinkPanel extends ConsumerStatefulWidget {
  const ReportLinkPanel({super.key});

  @override
  ConsumerState<ReportLinkPanel> createState() => _ReportLinkPanelState();
}

class _ReportLinkPanelState extends ConsumerState<ReportLinkPanel> {
  final TextEditingController _link = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _link.dispose();
    super.dispose();
  }

  void _open() {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String? token =
        ref.read(linkBuilderProvider).reportTokenFrom(_link.text);
    if (token == null) {
      setState(() => _error = l10n.reportLinkInvalid);
      return;
    }
    setState(() => _error = null);
    ref.read(tokenStoreProvider.notifier).setReport(token);
    ref.read(reportControllerProvider.notifier).reset();
    context.go('/report');
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return DrSection(
      title: l10n.openReportSectionTitle,
      body: l10n.openReportSectionBody,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          DrTextField(
            label: l10n.reportLinkLabel,
            hint: l10n.reportLinkHint,
            errorText: _error,
            controller: _link,
            onChanged: (_) {
              if (_error != null) {
                setState(() => _error = null);
              }
            },
          ),
          const SizedBox(height: DrSpace.s16),
          DrButton(
            label: l10n.openReportButton,
            onPressed: _open,
            type: DrButtonType.tertiary,
            size: DrButtonSize.lg,
            elder: true,
            expand: true,
          ),
        ],
      ),
    );
  }
}
