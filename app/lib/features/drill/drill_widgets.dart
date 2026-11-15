import 'package:flutter/material.dart';

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
import '../session/drill_models.dart';

class DrillHeader extends StatelessWidget {
  const DrillHeader({
    super.key,
    required this.l10n,
    required this.turnCount,
    required this.onEnd,
    required this.ending,
  });

  final AppLocalizations l10n;
  final String turnCount;
  final VoidCallback onEnd;
  final bool ending;

  @override
  Widget build(BuildContext context) {
    final DrColors colors = context.drColors;
    final DrTypeTheme type = context.drType;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        DrBanner(
          message: l10n.drillBadgeMessage,
          badgeLabel: l10n.drillBadge,
          variant: DrBannerVariant.warning,
        ),
        const SizedBox(height: DrSpace.s12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    l10n.drillTitle,
                    style: type.title2.copyWith(color: colors.textPrimary),
                  ),
                  const SizedBox(height: DrSpace.s2),
                  Text(
                    turnCount,
                    style: type.caption2.copyWith(color: colors.textTertiary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: DrSpace.s8),
            DrButton(
              label: ending ? l10n.drillSending : l10n.drillEnd,
              onPressed: ending ? null : onEnd,
              type: DrButtonType.tertiary,
              size: DrButtonSize.md,
              leadingIcon: DrIcon(
                data: DrIcons.phoneX,
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

class ChatList extends StatelessWidget {
  const ChatList({
    super.key,
    required this.l10n,
    required this.messages,
    required this.sending,
    required this.controller,
  });

  final AppLocalizations l10n;
  final List<ChatMessage> messages;
  final bool sending;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: controller,
      padding: const EdgeInsets.symmetric(vertical: DrSpace.s16),
      children: <Widget>[
        for (final ChatMessage message in messages)
          Padding(
            padding: const EdgeInsets.only(bottom: DrSpace.s12),
            child: ChatBubble(message: message, l10n: l10n),
          ),
        if (sending) WaitingRow(l10n: l10n),
      ],
    );
  }
}

class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message, required this.l10n});

  final ChatMessage message;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final DrColors colors = context.drColors;
    final DrTypeTheme type = context.drType;
    final bool mine = message.speaker == ChatSpeaker.participant;
    final Color fill = switch (message.speaker) {
      ChatSpeaker.officer => colors.surfaceSecondary,
      ChatSpeaker.participant => colors.surfacePrimarySelected,
      ChatSpeaker.system => colors.surfaceInfoSubtle,
    };
    final String label = switch (message.speaker) {
      ChatSpeaker.officer => l10n.drillOfficer,
      ChatSpeaker.participant => l10n.drillYou,
      ChatSpeaker.system => l10n.drillSystem,
    };
    return Row(
      mainAxisAlignment: mine ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(DrSpace.s12),
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(DrRadius.r12),
              border: Border.all(
                color: colors.borderPrimary,
                width: DrSize.strokeHairline,
              ),
            ),
            child: Column(
              crossAxisAlignment:
                  mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  label,
                  style: type.caption3.copyWith(color: colors.textTertiary),
                ),
                const SizedBox(height: DrSpace.s4),
                Text(
                  message.text,
                  style: type.body3.copyWith(color: colors.textPrimary),
                  textAlign: mine ? TextAlign.right : TextAlign.left,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class WaitingRow extends StatelessWidget {
  const WaitingRow({super.key, required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                l10n.drillWaiting,
                style: context.drType.caption2
                    .copyWith(color: context.drColors.textSecondary),
              ),
              const SizedBox(height: DrSpace.s8),
              const DrSkeleton(lines: 2),
            ],
          ),
        ),
      ],
    );
  }
}

class DrillEndedPanel extends StatelessWidget {
  const DrillEndedPanel({
    super.key,
    required this.l10n,
    required this.onDebrief,
  });

  final AppLocalizations l10n;
  final VoidCallback onDebrief;

  @override
  Widget build(BuildContext context) {
    return DrEmptyView(
      title: l10n.drillEnded,
      message: l10n.debriefPending,
      actionLabel: l10n.drillGoToDebrief,
      onAction: onDebrief,
    );
  }
}
