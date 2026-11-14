import 'package:flutter/material.dart';

import '../color_tokens.g.dart';
import '../icons.g.dart';
import '../dr_theme.dart';
import '../space_tokens.g.dart';
import '../type_tokens.g.dart';
import 'dr_icon.dart';

enum DrTimelineStatus { complete, current, upcoming }

/// One step in the drill timeline: a node, a connector and the step copy.
class DrTimelineRow extends StatelessWidget {
  const DrTimelineRow({
    super.key,
    required this.title,
    this.detail,
    this.trailingLabel,
    this.status = DrTimelineStatus.upcoming,
    this.isLast = false,
    this.elder = false,
  });

  final String title;
  final String? detail;
  final String? trailingLabel;
  final DrTimelineStatus status;
  final bool isLast;
  final bool elder;

  @override
  Widget build(BuildContext context) {
    final DrColors colors = context.drColors;
    final DrTypeTheme type = context.drType;

    final Color nodeFill = switch (status) {
      DrTimelineStatus.complete => colors.actionPrimary,
      DrTimelineStatus.current => colors.actionPrimary,
      DrTimelineStatus.upcoming => colors.surfacePrimary,
    };
    final Color nodeBorder = switch (status) {
      DrTimelineStatus.complete => colors.actionPrimary,
      DrTimelineStatus.current => colors.borderAction,
      DrTimelineStatus.upcoming => colors.borderPrimary,
    };
    final Color titleColor = switch (status) {
      DrTimelineStatus.upcoming => colors.textSecondary,
      _ => colors.textPrimary,
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: DrSize.nodeLarge,
          child: Column(
            children: <Widget>[
              Container(
                width: status == DrTimelineStatus.current ? DrSize.nodeLarge : DrSize.node,
                height: status == DrTimelineStatus.current ? DrSize.nodeLarge : DrSize.node,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: nodeFill,
                  shape: BoxShape.circle,
                  border: Border.all(color: nodeBorder, width: DrSize.strokeDefault),
                ),
                child: status == DrTimelineStatus.complete
                    ? DrIcon(
                        data: DrIcons.checkCircle,
                        size: DrSize.iconSm,
                        color: colors.iconOnAction,
                      )
                    : null,
              ),
              if (!isLast)
                Container(
                  width: DrSize.strokeDefault,
                  height: DrSpace.s24,
                  color: colors.borderPrimary,
                ),
            ],
          ),
        ),
        const SizedBox(width: DrSpace.s12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              top: status == DrTimelineStatus.current ? DrSpace.s4 : DrSpace.s0,
              bottom: isLast ? DrSpace.s0 : DrSpace.s24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(title, style: type.title3.copyWith(color: titleColor)),
                    ),
                    if (trailingLabel != null)
                      Text(
                        trailingLabel!,
                        style: type.caption3.copyWith(color: colors.textTertiary),
                      ),
                  ],
                ),
                if (detail != null) ...<Widget>[
                  const SizedBox(height: DrSpace.s2),
                  Text(detail!, style: type.body6.copyWith(color: colors.textSecondary)),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
