import 'package:api_client/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/failure_copy.dart';
import '../../core/share_service.dart';
import '../../design/components/dr_button.dart';
import '../../design/components/dr_data_views.dart';
import '../../design/components/dr_text_field.dart';
import '../../design/dr_theme.dart';
import '../../design/space_tokens.g.dart';
import '../../l10n/app_localizations.dart';
import '../../state/providers.dart';
import '../../ui/shared/dr_section.dart';
import 'invite_controller.dart';
import 'invite_result.dart';
import 'language_name.dart';

class InvitePanel extends ConsumerStatefulWidget {
  const InvitePanel({super.key});

  @override
  ConsumerState<InvitePanel> createState() => _InvitePanelState();
}

class _InvitePanelState extends ConsumerState<InvitePanel> {
  final TextEditingController _cohort = TextEditingController();
  String? _cohortError;
  bool _copied = false;

  @override
  void dispose() {
    _cohort.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String cohort = _cohort.text.trim();
    final String? validation = cohort.isEmpty || cohortPattern.hasMatch(cohort)
        ? null
        : l10n.cohortInvalid;
    setState(() => _cohortError = validation);
    if (validation != null) {
      return;
    }
    setState(() => _copied = false);
    await ref
        .read(inviteControllerProvider.notifier)
        .create(cohort: cohort.isEmpty ? null : cohort);
  }

  Future<void> _copy(String url) async {
    final ShareService share = ref.read(shareServiceProvider);
    await share.copy(url);
    if (!mounted) {
      return;
    }
    setState(() => _copied = true);
  }

  Future<void> _share(String url) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ShareService share = ref.read(shareServiceProvider);
    try {
      await share.share(
        text: l10n.inviteShareMessage(url),
        subject: l10n.appTitle,
      );
    } on Object {
      await share.copy(url);
      if (!mounted) {
        return;
      }
      setState(() => _copied = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.shareUnavailable)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final InviteState state = ref.watch(inviteControllerProvider);
    final InviteController controller = ref.read(inviteControllerProvider.notifier);
    final String? url = state.inviteUrl;
    return DrSection(
      title: l10n.organizerSectionTitle,
      body: l10n.organizerSectionBody,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            l10n.languageLabel,
            style: context.drType.caption1.copyWith(color: context.drColors.textSecondary),
          ),
          const SizedBox(height: DrSpace.s8),
          Wrap(
            spacing: DrSpace.s8,
            runSpacing: DrSpace.s8,
            children: <Widget>[
              for (final AppLanguage language in AppLanguage.values)
                DrButton(
                  label: languageName(l10n, language),
                  onPressed: () => controller.setLanguage(language),
                  type: state.language == language
                      ? DrButtonType.primary
                      : DrButtonType.tertiary,
                  size: DrButtonSize.sm,
                ),
            ],
          ),
          const SizedBox(height: DrSpace.s16),
          DrTextField(
            label: l10n.cohortLabel,
            hint: l10n.cohortHint,
            helper: l10n.cohortHelper,
            errorText: _cohortError,
            controller: _cohort,
            onChanged: (_) {
              if (_cohortError != null) {
                setState(() => _cohortError = null);
              }
            },
          ),
          const SizedBox(height: DrSpace.s16),
          DrButton(
            label: state.creating ? l10n.creatingInvite : l10n.createInviteButton,
            onPressed: state.creating ? null : _create,
            type: DrButtonType.primary,
            size: DrButtonSize.lg,
            elder: true,
            expand: true,
          ),
          if (state.error != null) ...<Widget>[
            const SizedBox(height: DrSpace.s16),
            DrErrorView(
              title: l10n.errorTitle,
              message: failureMessage(l10n, state.error),
              retryLabel: l10n.retry,
              onRetry: _create,
            ),
          ],
          if (url != null) ...<Widget>[
            const SizedBox(height: DrSpace.s20),
            InviteResult(
              url: url,
              expiresAt: state.expiresAt,
              copiedLabel: _copied ? l10n.linkCopied : null,
              onCopy: () => _copy(url),
              onShare: () => _share(url),
            ),
          ],
        ],
      ),
    );
  }
}
