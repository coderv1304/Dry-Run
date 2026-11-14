import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../color_tokens.g.dart';
import '../space_tokens.g.dart';
import '../type_tokens.g.dart';
import '../dr_theme.dart';

/// Interaction state shared by every control.
enum DrState { rest, hover, pressed, focus, disabled }

enum DrButtonType { primary, secondary, tertiary, error, warning }

enum DrButtonSize { lg, md, sm, xsm }

@immutable
final class DrButtonPalette {
  const DrButtonPalette({
    required this.fill,
    required this.label,
    required this.border,
    required this.focusRing,
  });

  final Color fill;
  final Color label;
  final Color border;
  final Color focusRing;
}

/// Pure token mapping: one palette per type and state. No animation, no
/// shadow, no transform. Hover is an instant static colour swap.
DrButtonPalette drButtonPalette({
  required DrColors colors,
  required DrButtonType type,
  required DrState state,
}) {
  final bool disabled = state == DrState.disabled;
  final bool hover = state == DrState.hover;
  final bool pressed = state == DrState.pressed;

  Color pick(Color rest, Color hoverColor, Color pressedColor, Color disabledColor) {
    if (disabled) {
      return disabledColor;
    }
    if (pressed) {
      return pressedColor;
    }
    if (hover) {
      return hoverColor;
    }
    return rest;
  }

  switch (type) {
    case DrButtonType.primary:
      return DrButtonPalette(
        fill: pick(
          colors.actionPrimary,
          colors.actionPrimaryHover,
          colors.actionPrimaryPressed,
          colors.actionPrimaryDisabled,
        ),
        label: disabled ? colors.textDisabled : colors.textOnAction,
        border: colors.surfaceTransparent,
        focusRing: colors.borderFocus,
      );
    case DrButtonType.secondary:
      return DrButtonPalette(
        fill: pick(
          colors.actionSecondary,
          colors.actionSecondaryHover,
          colors.actionSecondaryPressed,
          colors.actionSecondaryDisabled,
        ),
        label: disabled ? colors.textDisabled : colors.textOnAction,
        border: colors.surfaceTransparent,
        focusRing: colors.borderFocus,
      );
    case DrButtonType.tertiary:
      return DrButtonPalette(
        fill: pick(
          colors.actionTertiary,
          colors.actionTertiaryHover,
          colors.actionTertiaryPressed,
          colors.actionTertiaryDisabled,
        ),
        label: disabled ? colors.textDisabled : colors.textPrimary,
        border: colors.borderPrimary,
        focusRing: colors.borderFocus,
      );
    case DrButtonType.error:
      return DrButtonPalette(
        fill: pick(
          colors.actionError,
          colors.actionErrorHover,
          colors.actionErrorPressed,
          colors.actionErrorDisabled,
        ),
        label: disabled ? colors.textDisabled : colors.textOnAction,
        border: colors.surfaceTransparent,
        focusRing: colors.borderFocus,
      );
    case DrButtonType.warning:
      return DrButtonPalette(
        fill: pick(
          colors.actionWarning,
          colors.actionWarningHover,
          colors.actionWarningPressed,
          colors.actionWarningDisabled,
        ),
        label: disabled ? colors.textDisabled : colors.textOnWarning,
        border: colors.surfaceTransparent,
        focusRing: colors.borderFocus,
      );
  }
}

TextStyle drButtonTextStyle(DrTypeTheme type, DrButtonSize size) {
  switch (size) {
    case DrButtonSize.lg:
      return type.buttonLg;
    case DrButtonSize.md:
      return type.buttonMd;
    case DrButtonSize.sm:
      return type.buttonSm;
    case DrButtonSize.xsm:
      return type.buttonXsm;
  }
}

EdgeInsetsGeometry drButtonPadding(DrButtonSize size) {
  switch (size) {
    case DrButtonSize.lg:
      return const EdgeInsets.symmetric(
        horizontal: DrSpace.s16,
        vertical: DrSpace.s12,
      );
    case DrButtonSize.md:
      return const EdgeInsets.symmetric(
        horizontal: DrSpace.s12,
        vertical: DrSpace.s8,
      );
    case DrButtonSize.sm:
      return const EdgeInsets.symmetric(
        horizontal: DrSpace.s12,
        vertical: DrSpace.s8,
      );
    case DrButtonSize.xsm:
      return const EdgeInsets.symmetric(
        horizontal: DrSpace.s8,
        vertical: DrSpace.s4,
      );
  }
}

class DrButton extends StatefulWidget {
  const DrButton({
    super.key,
    required this.label,
    this.onPressed,
    this.type = DrButtonType.primary,
    this.size = DrButtonSize.md,
    this.elder = false,
    this.expand = false,
    this.leadingIcon,
    this.stateOverride,
  });

  final String label;
  final VoidCallback? onPressed;
  final DrButtonType type;
  final DrButtonSize size;
  final bool elder;
  final bool expand;
  final Widget? leadingIcon;

  /// Preview hook for the design gallery and goldens. Real screens leave it null.
  final DrState? stateOverride;

  @override
  State<DrButton> createState() => _DrButtonState();
}

class _DrButtonState extends State<DrButton> {
  bool _hovered = false;
  bool _focused = false;
  bool _pressed = false;

  DrState get _state {
    if (widget.stateOverride != null) {
      return widget.stateOverride!;
    }
    if (widget.onPressed == null) {
      return DrState.disabled;
    }
    if (_pressed) {
      return DrState.pressed;
    }
    if (_focused) {
      return DrState.focus;
    }
    if (_hovered) {
      return DrState.hover;
    }
    return DrState.rest;
  }

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

  void _setPressed(bool value) {
    if (widget.stateOverride == null && _pressed != value) {
      setState(() => _pressed = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final DrColors colors = context.drColors;
    final DrTypeTheme type = context.drType;
    final DrState state = _state;
    final bool enabled = state != DrState.disabled;
    final DrButtonPalette palette = drButtonPalette(
      colors: colors,
      type: widget.type,
      state: state,
    );
    final TextStyle labelStyle = drButtonTextStyle(type, widget.size).copyWith(
      color: palette.label,
    );

    final Widget body = Container(
      padding: const EdgeInsets.all(DrSpace.s2),
      decoration: BoxDecoration(
        color: colors.surfaceTransparent,
        borderRadius: BorderRadius.circular(DrRadius.r12),
        border: Border.all(
          width: DrSize.strokeDefault,
          color: state == DrState.focus ? palette.focusRing : colors.surfaceTransparent,
        ),
      ),
      child: Container(
        constraints: BoxConstraints(
          minHeight: widget.elder ? DrTouch.elder : DrTouch.minimum,
        ),
        padding: drButtonPadding(widget.size),
        decoration: BoxDecoration(
          color: palette.fill,
          borderRadius: BorderRadius.circular(DrRadius.nested(DrRadius.r12, DrSpace.s2)),
          border: Border.all(color: palette.border, width: DrSize.strokeHairline),
        ),
        child: Row(
          mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (widget.leadingIcon != null) ...<Widget>[
              widget.leadingIcon!,
              const SizedBox(width: DrSpace.s8),
            ],
            Flexible(
              child: Text(
                widget.label,
                style: labelStyle,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: FocusableActionDetector(
        enabled: enabled,
        onShowHoverHighlight: _setHover,
        onShowFocusHighlight: _setFocus,
        mouseCursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (ActivateIntent intent) {
              widget.onPressed?.call();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: enabled ? (TapDownDetails details) => _setPressed(true) : null,
          onTapUp: enabled ? (TapUpDetails details) => _setPressed(false) : null,
          onTapCancel: enabled ? () => _setPressed(false) : null,
          onTap: enabled ? widget.onPressed : null,
          child: AnimatedScale(
            scale: state == DrState.pressed ? DrMotion.pressScale : 1,
            duration: DrMotion.press,
            curve: DrMotion.curve,
            child: widget.expand ? SizedBox(width: double.infinity, child: body) : body,
          ),
        ),
      ),
    );
  }
}
