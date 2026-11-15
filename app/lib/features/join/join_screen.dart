import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/failure_copy.dart';
import '../../design/components/dr_button.dart';
import '../../design/components/dr_data_views.dart';
import '../../design/components/dr_text_field.dart';
import '../../design/space_tokens.g.dart';
import '../../l10n/app_localizations.dart';
import '../../state/token_store.dart';
import '../../ui/shared/dr_page.dart';
import '../../ui/shared/dr_page_header.dart';
import 'join_controller.dart';

class JoinScreen extends ConsumerStatefulWidget {
  const JoinScreen({super.key});

  @override
  ConsumerState<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends ConsumerState<JoinScreen> {
  final TextEditingController _token = TextEditingController();

  @override
  void initState() {
    super.initState();
    final String? existing = ref.read(tokenStoreProvider).inviteToken;
    if (existing != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _validate(existing));
    }
  }

  @override
  void dispose() {
    _token.dispose();
    super.dispose();
  }

  Future<void> _validate(String raw) async {
    final bool ok =
        await ref.read(joinControllerProvider.notifier).validate(raw);
    if (!mounted) {
      return;
    }
    if (ok) {
      context.go('/consent');
      return;
    }
    final JoinState state = ref.read(joinControllerProvider);
    if (state.invalidLink) {
      ref.read(tokenStoreProvider.notifier).clearInvite();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final JoinState state = ref.watch(joinControllerProvider);
    return DrPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          DrPageHeader(
            title: l10n.joinTitle,
            subtitle: l10n.joinTokenHint,
            backLabel: l10n.a11yBack,
            onBack: () => context.go('/'),
          ),
          const SizedBox(height: DrSpace.s32),
          if (state.validating) ...<Widget>[
            Text(
              l10n.joinValidating,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: DrSpace.s16),
            const DrSkeleton(lines: 2),
          ] else ...<Widget>[
            DrTextField(
              label: l10n.joinTokenLabel,
              hint: l10n.joinTokenHint,
              controller: _token,
              errorText: state.invalidLink
                  ? l10n.joinInvalid
                  : state.error != null
                      ? failureMessage(l10n, state.error)
                      : null,
              onChanged: (_) => ref.read(joinControllerProvider.notifier).reset(),
            ),
            const SizedBox(height: DrSpace.s16),
            DrButton(
              label: l10n.joinContinueButton,
              onPressed: () => _validate(_token.text),
              type: DrButtonType.primary,
              size: DrButtonSize.lg,
              elder: true,
              expand: true,
            ),
            const SizedBox(height: DrSpace.s24),
            DrButton(
              label: l10n.tryItYourself,
              onPressed: () => context.go('/try'),
              type: DrButtonType.tertiary,
              size: DrButtonSize.md,
            ),
          ],
        ],
      ),
    );
  }
}
