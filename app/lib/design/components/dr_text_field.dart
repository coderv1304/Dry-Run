import 'package:flutter/material.dart';

import '../color_tokens.g.dart';
import '../dr_theme.dart';
import '../space_tokens.g.dart';
import '../type_tokens.g.dart';

/// Per field state set, including the filled variant.
enum DrFieldState { rest, filled, focus, error, disabled }

/// Text input with rest, filled, focus, error and disabled states.
class DrTextField extends StatefulWidget {
  const DrTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.helper,
    this.errorText,
    this.enabled = true,
    this.filled = false,
    this.obscure = false,
    this.maxLines = 1,
    this.elder = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.stateOverride,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final String? helper;
  final String? errorText;
  final bool enabled;
  final bool filled;
  final bool obscure;
  final int maxLines;
  final bool elder;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;

  /// Preview hook for the design gallery and goldens.
  final DrFieldState? stateOverride;

  @override
  State<DrTextField> createState() => _DrTextFieldState();
}

class _DrTextFieldState extends State<DrTextField> {
  late final FocusNode _focusNode;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (widget.stateOverride == null && _focused != _focusNode.hasFocus) {
      setState(() => _focused = _focusNode.hasFocus);
    }
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DrColors colors = context.drColors;
    final DrTypeTheme type = context.drType;
    final bool disabled =
        widget.stateOverride == DrFieldState.disabled || !widget.enabled;
    final bool showError =
        widget.errorText != null || widget.stateOverride == DrFieldState.error;
    final bool focused = widget.stateOverride == DrFieldState.focus ||
        (widget.stateOverride == null && _focused);
    final bool filled =
        widget.filled || widget.stateOverride == DrFieldState.filled;

    final Color fill = disabled
        ? colors.surfaceDisabled
        : (filled ? colors.surfaceSecondary : colors.surfacePrimary);
    final Color border = disabled
        ? colors.borderDisabled
        : (showError
            ? colors.borderError
            : (focused ? colors.borderFocus : colors.borderPrimary));
    final Color labelColor = disabled ? colors.textDisabled : colors.textSecondary;
    final Color textColor = disabled ? colors.textDisabled : colors.textPrimary;
    final BorderRadius innerRadius = BorderRadius.circular(
      DrRadius.nested(DrRadius.r12, DrSpace.s2),
    );

    OutlineInputBorder outline(Color color, double width) => OutlineInputBorder(
          borderRadius: innerRadius,
          borderSide: BorderSide(color: color, width: width),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(widget.label, style: type.title4.copyWith(color: labelColor)),
        const SizedBox(height: DrSpace.s8),
        Container(
          padding: const EdgeInsets.all(DrSpace.s2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DrRadius.r12),
            border: Border.all(
              width: DrSize.strokeDefault,
              color: focused && !disabled
                  ? colors.borderFocus
                  : colors.surfaceTransparent,
            ),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: widget.elder ? DrTouch.elder : DrTouch.minimum,
            ),
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              enabled: !disabled,
              obscureText: widget.obscure,
              maxLines: widget.obscure ? 1 : widget.maxLines,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              onChanged: widget.onChanged,
              cursorColor: colors.actionPrimary,
              style: type.body3.copyWith(color: textColor),
              decoration: InputDecoration(
                hintText: widget.hint,
                filled: true,
                fillColor: fill,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: DrSpace.s12,
                  vertical: DrSpace.s12,
                ),
                hintStyle: type.body3.copyWith(color: colors.textTertiary),
                border: outline(border, DrSize.strokeHairline),
                enabledBorder: outline(border, DrSize.strokeHairline),
                focusedBorder: outline(border, DrSize.strokeHairline),
                disabledBorder: outline(colors.borderDisabled, DrSize.strokeHairline),
                errorBorder: outline(colors.borderError, DrSize.strokeHairline),
              ),
            ),
          ),
        ),
        if (showError && widget.errorText != null) ...<Widget>[
          const SizedBox(height: DrSpace.s8),
          Text(
            widget.errorText!,
            style: type.caption2.copyWith(color: colors.textError),
          ),
        ] else if (widget.helper != null) ...<Widget>[
          const SizedBox(height: DrSpace.s8),
          Text(
            widget.helper!,
            style: type.caption2.copyWith(color: colors.textTertiary),
          ),
        ],
      ],
    );
  }
}
