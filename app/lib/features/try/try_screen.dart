import 'package:api_client/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/failure_copy.dart';
import '../../design/components/dr_banner.dart';
import '../../design/components/dr_button.dart';
import '../../design/dr_theme.dart';
import '../../design/space_tokens.g.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/shared/dr_page.dart';
import '../../ui/shared/dr_page_header.dart';
import '../../ui/shared/dr_section.dart';
import '../invite/language_name.dart';
import 'try_controller.dart';

class TryScreen extends ConsumerWidget {
  const TryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final TryState state = ref.watch(tryControllerProvider);
    final TryController controller = ref.read(tryControllerProvider.notifier);
    return DrPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          DrPageHeader(
            title: l10n.tryTitle,
            subtitle: l10n.tryBody,
            backLabel: l10n.a11yBack,
            onBack: () => context.go('/'),
          ),
          const SizedBox(height: DrSpace.s24),
          DrSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  l10n.languageLabel,
                  style: context.drType.caption1
                      .copyWith(color: context.drColors.textSecondary),
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
                        size: DrButtonSize.md,
                      ),
                  ],
                ),
                if (state.error != null) ...<Widget>[
                  const SizedBox(height: DrSpace.s16),
                  DrBanner(
                    message: failureMessage(l10n, state.error),
                    badgeLabel: l10n.errorTitle,
                    variant: DrBannerVariant.error,
                  ),
                ],
                const SizedBox(height: DrSpace.s24),
                DrButton(
                  label: state.starting ? l10n.tryStarting : l10n.tryStartButton,
                  onPressed: state.starting
                      ? null
                      : () async {
                          final bool ok = await controller.start();
                          if (ok && context.mounted) {
                            context.go('/consent');
                          }
                        },
                  type: DrButtonType.primary,
                  size: DrButtonSize.lg,
                  elder: true,
                  expand: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: DrSpace.s16),
          Text(
            l10n.consentPrivacyNote,
            style: context.drType.caption2
                .copyWith(color: context.drColors.textTertiary),
          ),
        ],
      ),
    );
  }
}
