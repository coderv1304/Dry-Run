import 'package:flutter/material.dart';

import '../color_tokens.g.dart';
import '../icons.g.dart';
import '../dr_theme.dart';
import '../space_tokens.g.dart';
import '../type_tokens.g.dart';
import 'dr_icon.dart';
import 'dr_reveal.dart';

enum DrDiagramStatus { done, active, pending }

@immutable
final class DrDiagramNode {
  const DrDiagramNode({
    required this.label,
    this.detail,
    this.status = DrDiagramStatus.pending,
  });

  final String label;
  final String? detail;
  final DrDiagramStatus status;
}

/// A vertical node and line diagram. Solid tokens only, no glow, no gradient.
class DrNodeLineDiagram extends StatelessWidget {
  const DrNodeLineDiagram({
    super.key,
    required this.nodes,
    this.elder = false,
    this.reveal = false,
  });

  final List<DrDiagramNode> nodes;
  final bool elder;

  /// Reveals the nodes in order on the base curve. Transforms never move
  /// layout, so the connector lines stay exactly where they were.
  final bool reveal;

  @override
  Widget build(BuildContext context) {
    final DrColors colors = context.drColors;
    final DrTypeTheme type = context.drType;

    Widget row(BuildContext context, int index) => _DiagramRow(
          node: nodes[index],
          index: index,
          isLast: index == nodes.length - 1,
          colors: colors,
          type: type,
          elder: elder,
        );
    if (reveal) {
      return DrRevealGroup(itemCount: nodes.length, builder: row);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int index = 0; index < nodes.length; index++) row(context, index),
      ],
    );
  }
}

class _DiagramRow extends StatelessWidget {
  const _DiagramRow({
    required this.node,
    required this.index,
    required this.isLast,
    required this.colors,
    required this.type,
    required this.elder,
  });

  final DrDiagramNode node;
  final int index;
  final bool isLast;
  final DrColors colors;
  final DrTypeTheme type;
  final bool elder;

  @override
  Widget build(BuildContext context) {
    final bool active = node.status == DrDiagramStatus.active;
    final bool done = node.status == DrDiagramStatus.done;
    final Color fill = done || active ? colors.actionPrimary : colors.surfaceSecondary;
    final Color border = done || active ? colors.actionPrimary : colors.borderPrimary;
    final Color labelColor = active || done ? colors.textPrimary : colors.textSecondary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: DrSize.nodeLarge,
          child: Column(
            children: <Widget>[
              Container(
                width: DrSize.nodeLarge,
                height: DrSize.nodeLarge,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: fill,
                  shape: BoxShape.circle,
                  border: Border.all(color: border, width: DrSize.strokeDefault),
                ),
                child: done
                    ? DrIcon(
                        data: DrIcons.checkCircle,
                        size: DrSize.iconSm,
                        color: colors.iconOnAction,
                      )
                    : Text(
                        '${index + 1}',
                        style: type.caption3.copyWith(
                          color: active ? colors.textOnAction : colors.textSecondary,
                        ),
                      ),
              ),
              if (!isLast)
                Container(
                  width: DrSize.strokeDefault,
                  height: DrSpace.s32,
                  color: colors.borderPrimary,
                ),
            ],
          ),
        ),
        const SizedBox(width: DrSpace.s12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: DrSpace.s4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(node.label, style: type.title4.copyWith(color: labelColor)),
                if (node.detail != null) ...<Widget>[
                  const SizedBox(height: DrSpace.s2),
                  Text(node.detail!, style: type.body6.copyWith(color: colors.textSecondary)),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
