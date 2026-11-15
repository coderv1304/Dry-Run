import 'package:api_client/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/components/dr_data_views.dart';
import '../../design/components/dr_node_line_diagram.dart';
import '../../design/space_tokens.g.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/shared/dr_section.dart';
import '../debrief/debrief_copy.dart';
import 'about_providers.dart';

class AboutLimitsSection extends ConsumerWidget {
  const AboutLimitsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<ConfigResponse> config = ref.watch(serviceConfigProvider);
    return config.when(
      loading: () => DrSection(
        title: l10n.aboutLimitsTitle,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(l10n.aboutLimitsLoading),
            const SizedBox(height: DrSpace.s12),
            const DrSkeleton(lines: 3),
          ],
        ),
      ),
      error: (Object error, StackTrace stack) => DrSection(
        title: l10n.aboutLimitsTitle,
        child: DrErrorView(
          title: l10n.errorTitle,
          message: l10n.aboutLimitsFailed,
          retryLabel: l10n.retry,
          onRetry: () => ref.invalidate(serviceConfigProvider),
        ),
      ),
      data: (ConfigResponse config) {
        final ConfigLimits limits = config.limits;
        return DrSection(
          title: l10n.aboutLimitsTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _Point(text: l10n.aboutMaxTurns(limits.maxTurns)),
              _Point(text: l10n.aboutMaxDuration((limits.maxDurationSeconds / 60).round())),
              _Point(text: l10n.aboutIdleTimeout((limits.idleTimeoutSeconds / 60).round())),
              _Point(text: l10n.aboutRetention(limits.retentionDays)),
              const SizedBox(height: DrSpace.s8),
              Text(
                l10n.aboutChatOnly,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        );
      },
    );
  }
}

class AboutGraphSection extends ConsumerWidget {
  const AboutGraphSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<ScenarioGraphResponse> graph =
        ref.watch(scenarioGraphProvider);
    return DrSection(
      title: l10n.aboutHowItWorksTitle,
      body: l10n.aboutHowItWorksBody,
      child: graph.when(
        loading: () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(l10n.graphLoading),
            const SizedBox(height: DrSpace.s12),
            const DrSkeleton(lines: 4),
          ],
        ),
        error: (Object error, StackTrace stack) => DrErrorView(
          title: l10n.errorTitle,
          message: l10n.graphFailed,
          retryLabel: l10n.retry,
          onRetry: () => ref.invalidate(scenarioGraphProvider),
        ),
        data: (ScenarioGraphResponse response) => DrNodeLineDiagram(
          elder: true,
          nodes: <DrDiagramNode>[
            for (int index = 0; index < response.stageIds.length; index++)
              DrDiagramNode(
                label: l10n.graphStage(
                  index + 1,
                  stageName(l10n, response.stageIds[index]),
                ),
                status: DrDiagramStatus.pending,
              ),
          ],
        ),
      ),
    );
  }
}

class _Point extends StatelessWidget {
  const _Point({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DrSpace.s4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: DrSpace.s8),
            child: Container(
              width: DrSpace.s4,
              height: DrSpace.s4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: DrSpace.s8),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
