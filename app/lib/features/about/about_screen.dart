import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../design/space_tokens.g.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/shared/dr_page.dart';
import '../../ui/shared/dr_page_header.dart';
import '../../ui/shared/dr_section.dart';
import 'about_sections.dart';

/// Plain spoken About page. What this is, what it is not, what is stored, how
/// to delete it, and how the drill works. No analytics, no account claims.
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return DrPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          DrPageHeader(
            title: l10n.aboutTitle,
            subtitle: l10n.appTagline,
            backLabel: l10n.aboutBackHome,
            onBack: () => context.go('/'),
          ),
          const SizedBox(height: DrSpace.s24),
          DrSection(title: l10n.aboutWhatTitle, body: l10n.aboutWhatBody, child: const SizedBox.shrink()),
          const SizedBox(height: DrSpace.s16),
          DrSection(title: l10n.aboutNotTitle, body: l10n.aboutNotBody, child: const SizedBox.shrink()),
          const SizedBox(height: DrSpace.s16),
          DrSection(title: l10n.aboutStorageTitle, body: l10n.aboutStorageBody(7), child: const SizedBox.shrink()),
          const SizedBox(height: DrSpace.s16),
          DrSection(title: l10n.aboutDeletionTitle, body: l10n.aboutDeletionBody, child: const SizedBox.shrink()),
          const SizedBox(height: DrSpace.s16),
          DrSection(title: l10n.aboutAnalyticsTitle, body: l10n.aboutAnalyticsBody, child: const SizedBox.shrink()),
          const SizedBox(height: DrSpace.s16),
          DrSection(
            title: l10n.aboutPracticeTitle,
            body: l10n.aboutPracticeBody,
            tone: DrSectionTone.warning,
            child: const SizedBox.shrink(),
          ),
          const SizedBox(height: DrSpace.s16),
          const AboutGraphSection(),
          const SizedBox(height: DrSpace.s16),
          const AboutLimitsSection(),
        ],
      ),
    );
  }
}
