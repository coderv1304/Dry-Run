import 'package:flutter/material.dart';

import '../color_tokens.g.dart';
import '../dr_theme.dart';
import '../icons.g.dart';
import '../space_tokens.g.dart';
import '../type_tokens.g.dart';
import 'dr_button.dart';
import 'dr_icon.dart';

/// A tappable row. Hover is an instant static surface swap; nothing animates.
class DrListRow extends StatefulWidget {
  const DrListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.leading,
    this.onTap,
    this.elder = false,
    this.stateOverride,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? leading;
  final VoidCallback? onTap;
  final bool elder;
  final DrState? stateOverride;

  @override
  State<DrListRow> createState() => _DrListRowState();
}

class _DrListRowState extends State<DrListRow> {
  bool _hovered = false;
  bool _focused = false;

  void _setHover(bool value) {
    if (widget.stateOverride == null && _hovered != value) {
      setState(() => _hovered = value);
    }
  }

  void _setFocus(bool value) {
    if (widget.stateOverride == null && _focused != value) {
      setState(() => _focused = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final DrColors colors = context.drColors;
    final DrTypeTheme type = context.drType;
    final DrState state = widget.stateOverride ??
        (widget.onTap == null
            ? DrState.rest
            : (_focused
                ? DrState.focus
                : (_hovered ? DrState.hover : DrState.rest)));

    final Color fill = switch (state) {
      DrState.hover => colors.surfacePrimaryHover,
      DrState.pressed => colors.surfacePrimarySelected,
      DrState.disabled => colors.surfaceDisabled,
      _ => colors.surfacePrimary,
    };
    final Color titleColor =
        state == DrState.disabled ? colors.textDisabled : colors.textPrimary;
    final Color subtitleColor =
        state == DrState.disabled ? colors.textDisabled : colors.textSecondary;

    return Semantics(
      button: widget.onTap != null,
      child: FocusableActionDetector(
        enabled: widget.onTap != null,
        onShowHoverHighlight: _setHover,
        onShowFocusHighlight: _setFocus,
        mouseCursor:
            widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: Container(
            constraints: BoxConstraints(
              minHeight: widget.elder ? DrTouch.elder : DrTouch.minimum,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: DrSpace.s16,
              vertical: DrSpace.s12,
            ),
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(DrRadius.r8),
              border: Border.all(
                width: DrSize.strokeDefault,
                color: state == DrState.focus ? colors.borderFocus : colors.surfaceTransparent,
              ),
            ),
            child: Row(
              children: <Widget>[
                if (widget.leading != null) ...<Widget>[
                  widget.leading!,
                  const SizedBox(width: DrSpace.s12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(widget.title, style: type.title3.copyWith(color: titleColor)),
                      if (widget.subtitle != null) ...<Widget>[
                        const SizedBox(height: DrSpace.s2),
                        Text(
                          widget.subtitle!,
                          style: type.body6.copyWith(color: subtitleColor),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: DrSpace.s12),
                widget.trailing ??
                    DrIcon(
                      data: DrIcons.arrowRight,
                      size: DrSize.iconMd,
                      color: state == DrState.disabled ? colors.iconDisabled : colors.iconSubtle,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
