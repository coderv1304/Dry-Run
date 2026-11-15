import 'package:flutter/material.dart';

import '../../design/color_tokens.g.dart';
import '../../design/components/dr_button.dart';
import '../../design/dr_theme.dart';
import '../../design/space_tokens.g.dart';
import '../../design/type_tokens.g.dart';

Future<bool> showDrConfirm({
  required BuildContext context,
  required String title,
  required String body,
  required String confirmLabel,
  required String cancelLabel,
  bool destructive = false,
  bool busy = false,
}) async {
  final bool? result = await showDialog<bool>(
    context: context,
    barrierDismissible: !busy,
    builder: (BuildContext context) {
      final DrColors colors = context.drColors;
      final DrTypeTheme type = context.drType;
      return AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(body, style: type.body3.copyWith(color: colors.textSecondary)),
            const SizedBox(height: DrSpace.s24),
            DrButton(
              label: confirmLabel,
              onPressed: busy ? null : () => Navigator.of(context).pop(true),
              type: destructive ? DrButtonType.error : DrButtonType.primary,
              size: DrButtonSize.lg,
              elder: true,
              expand: true,
            ),
            const SizedBox(height: DrSpace.s8),
            DrButton(
              label: cancelLabel,
              onPressed: busy ? null : () => Navigator.of(context).pop(false),
              type: DrButtonType.tertiary,
              size: DrButtonSize.lg,
              elder: true,
              expand: true,
            ),
          ],
        ),
      );
    },
  );
  return result ?? false;
}
