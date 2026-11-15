import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../design/color_tokens.g.dart';
import '../../design/components/dr_button.dart';
import '../../design/components/dr_hero_heading.dart';
import '../../design/components/dr_icon.dart';
import '../../design/icons.g.dart';
import '../../design/dr_theme.dart';
import '../../design/space_tokens.g.dart';
import '../../design/type_tokens.g.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/shared/dr_page.dart';
import '../invite/invite_panel.dart';
import '../report/report_link_panel.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return DrPage(
      maxWidth: DrSize.containerMax,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _Wordmark(l10n: l10n),
          const SizedBox(height: DrSpace.s32),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final bool wide = constraints.maxWidth >= 1000;
              final Widget intro = _HomeIntro(l10n: l10n);
              final Widget panels = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const InvitePanel(),
                  const SizedBox(height: DrSpace.s20),
                  const ReportLinkPanel(),
                ],
              );
              if (!wide) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    intro,
                    const SizedBox(height: DrSpace.s32),
                    panels,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(flex: 3, child: intro),
                  const SizedBox(width: DrSpace.s32),
                  Expanded(flex: 2, child: panels),
                ],
              );
            },
          ),
          const SizedBox(height: DrSpace.s32),
          Text(
            l10n.appTagline,
            style: context.drType.caption2.copyWith(color: context.drColors.textTertiary),
          ),
        ],
      ),
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(DrSpace.s8),
          decoration: BoxDecoration(
            color: context.drColors.surfaceTertiary,
            borderRadius: BorderRadius.circular(DrRadius.r8),
            border: Border.all(
              color: context.drColors.borderPrimary,
              width: DrSize.strokeHairline,
            ),
          ),
          child: Text(
            'DR',
            style: context.drType.title3.copyWith(
              color: context.drColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: DrSpace.s12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              l10n.appTitle,
              style: context.drType.title2.copyWith(color: context.drColors.textPrimary),
            ),
            Text(
              l10n.appTagline,
              style: context.drType.caption3.copyWith(color: context.drColors.textTertiary),
            ),
          ],
        ),
      ],
    );
  }
}

class _HomeIntro extends StatelessWidget {
  const _HomeIntro({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final DrColors colors = context.drColors;
    final DrTypeTheme type = context.drType;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        DrHeroHeading(text: l10n.homeTitle),
        const SizedBox(height: DrSpace.s16),
        Text(
          l10n.homeTagline,
          style: type.title4.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: DrSpace.s8),
        Text(
          l10n.homeIntro,
          style: type.body3.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: DrSpace.s24),
        DrButton(
          label: l10n.tryItYourself,
          onPressed: () => context.go('/try'),
          type: DrButtonType.primary,
          size: DrButtonSize.lg,
          elder: true,
          expand: true,
          leadingIcon: DrIcon(
            data: DrIcons.phoneX,
            size: DrSize.iconLg,
            color: colors.textOnAction,
          ),
        ),
        const SizedBox(height: DrSpace.s8),
        Text(
          l10n.tryItYourselfBody,
          style: type.caption2.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: DrSpace.s16),
        Wrap(
          spacing: DrSpace.s8,
          runSpacing: DrSpace.s8,
          children: <Widget>[
            DrButton(
              label: l10n.joinTitle,
              onPressed: () => context.go('/join'),
              type: DrButtonType.tertiary,
              size: DrButtonSize.md,
            ),
            DrButton(
              label: l10n.aboutLink,
              onPressed: () => context.go('/about'),
              type: DrButtonType.tertiary,
              size: DrButtonSize.md,
              leadingIcon: DrIcon(
                data: DrIcons.shieldCheck,
                size: DrSize.iconSm,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
