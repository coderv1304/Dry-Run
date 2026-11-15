import 'package:api_client/api_client.dart';
import 'package:flutter/material.dart';

import '../../design/color_tokens.g.dart';
import '../../design/components/dr_banner.dart';
import '../../design/components/dr_icon.dart';
import '../../design/components/dr_node_line_diagram.dart';
import '../../design/components/dr_timeline_row.dart';
import '../../design/icons.g.dart';
import '../../design/dr_theme.dart';
import '../../design/space_tokens.g.dart';
import '../../design/type_tokens.g.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/shared/dr_section.dart';
import 'debrief_copy.dart';

class DebriefBody extends StatelessWidget {
  const DebriefBody({
    super.key,
    required this.l10n,
    required this.content,
  });

  final AppLocalizations l10n;
  final DebriefContent content;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (content.lowConfidence) ...<Widget>[
          DrBanner(
            message: l10n.debriefLowConfidence,
            badgeLabel: l10n.debriefQualityQuick,
            variant: DrBannerVariant.info,
          ),
          const SizedBox(height: DrSpace.s16),
        ],
        if (content.statePath.isNotEmpty) ...<Widget>[
          DrSection(
            title: l10n.debriefStatePathTitle,
            child: DrNodeLineDiagram(
              elder: true,
              nodes: <DrDiagramNode>[
                for (int index = 0; index < content.statePath.length; index++)
                  DrDiagramNode(
                    label: stageName(l10n, content.statePath[index].stageId),
                    detail: l10n.debriefTurnLabel(content.statePath[index].turnIndex),
                    status: index == content.statePath.length - 1
                        ? DrDiagramStatus.active
                        : DrDiagramStatus.done,
                  ),
              ],
            ),
          ),
          const SizedBox(height: DrSpace.s20),
        ],
        DrSection(
          title: l10n.debriefTimelineTitle,
          child: DebriefTimeline(l10n: l10n, content: content),
        ),
        const SizedBox(height: DrSpace.s20),
        DrSection(
          title: l10n.debriefDidWellTitle,
          child: _DidWell(l10n: l10n, ids: content.didWellIds),
        ),
        const SizedBox(height: DrSpace.s20),
        DrSection(
          title: l10n.debriefHabitTitle,
          child: _Habit(l10n: l10n, habit: content.habitId),
        ),
      ],
    );
  }
}

class DebriefTimeline extends StatelessWidget {
  const DebriefTimeline({super.key, required this.l10n, required this.content});

  final AppLocalizations l10n;
  final DebriefContent content;

  bool _isFirstCompliance(DebriefEvent event) {
    final FirstCompliance? first = content.firstCompliance;
    return first != null &&
        first.turnIndex == event.turnIndex &&
        first.label == event.label;
  }

  @override
  Widget build(BuildContext context) {
    if (content.events.isEmpty) {
      return Text(
        l10n.debriefNoEvents,
        style: context.drType.body6.copyWith(color: context.drColors.textSecondary),
      );
    }
    final List<DebriefEvent> events = <DebriefEvent>[...content.events]
      ..sort((DebriefEvent a, DebriefEvent b) => a.turnIndex.compareTo(b.turnIndex));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int index = 0; index < events.length; index++) ...<Widget>[
          DrTimelineRow(
            title: labelName(l10n, events[index].label),
            detail: _detail(events[index]),
            trailingLabel:
                _isFirstCompliance(events[index]) ? l10n.debriefFirstComplianceTitle : null,
            status: index == events.length - 1
                ? DrTimelineStatus.current
                : DrTimelineStatus.complete,
            isLast: index == events.length - 1,
            elder: true,
          ),
          if (_isFirstCompliance(events[index]))
            Padding(
              padding: const EdgeInsets.only(
                left: DrSpace.s44,
                top: DrSpace.s4,
                bottom: DrSpace.s8,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  DrIcon(
                    data: DrIcons.checkCircle,
                    size: DrSize.iconMd,
                    color: context.drColors.iconWarning,
                  ),
                  const SizedBox(width: DrSpace.s8),
                  Expanded(
                    child: Text(
                      l10n.debriefFirstComplianceBody,
                      style: context.drType.caption2
                          .copyWith(color: context.drColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }

  String _detail(DebriefEvent event) {
    final String quote = event.quote == null
        ? l10n.debriefQuoteMissing
        : l10n.debriefQuote(event.quote!.text);
    final String confidence =
        l10n.debriefConfidence((event.confidence * 100).round());
    final String turn = l10n.debriefTurnLabel(event.turnIndex);
    return '$quote\n$confidence\n$turn';
  }
}

class _DidWell extends StatelessWidget {
  const _DidWell({required this.l10n, required this.ids});

  final AppLocalizations l10n;
  final List<String> ids;

  @override
  Widget build(BuildContext context) {
    final List<String> shown = ids.isEmpty ? <String>['generic'] : ids;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final String id in shown)
          Padding(
            padding: const EdgeInsets.only(bottom: DrSpace.s8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                DrIcon(
                  data: DrIcons.checkCircle,
                  size: DrSize.iconMd,
                  color: context.drColors.iconSuccess,
                ),
                const SizedBox(width: DrSpace.s8),
                Expanded(
                  child: Text(
                    didWellText(l10n, id),
                    style: context.drType.body3
                        .copyWith(color: context.drColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Habit extends StatelessWidget {
  const _Habit({required this.l10n, required this.habit});

  final AppLocalizations l10n;
  final HabitId habit;

  @override
  Widget build(BuildContext context) {
    final DrColors colors = context.drColors;
    final DrTypeTheme type = context.drType;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          habitTitle(l10n, habit),
          style: type.title3.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: DrSpace.s4),
        Text(
          habitBody(l10n, habit),
          style: type.body3.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }
}
