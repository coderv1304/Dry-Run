import 'package:flutter/material.dart';

import '../icons.g.dart';
import '../dr_theme.dart';
import '../space_tokens.g.dart';

/// Paints a vendored Phosphor glyph. No icon font, no network fetch.
class DrIcon extends StatelessWidget {
  const DrIcon({
    super.key,
    required this.data,
    this.size = DrSize.iconMd,
    this.color,
    this.semanticLabel,
  });

  final DrIconData data;
  final double size;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final Color resolved = color ?? context.drColors.iconDefault;
    return Semantics(
      label: semanticLabel,
      image: semanticLabel != null,
      child: CustomPaint(
        size: Size.square(size),
        painter: _DrIconPainter(path: data.toPath(size), color: resolved),
      ),
    );
  }
}

class _DrIconPainter extends CustomPainter {
  const _DrIconPainter({required this.path, required this.color});

  final Path path;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(path, Paint()..color = color..isAntiAlias = true);
  }

  @override
  bool shouldRepaint(_DrIconPainter oldDelegate) =>
      oldDelegate.path != path || oldDelegate.color != color;
}
