import 'package:flutter/material.dart';

import '../color_tokens.g.dart';
import '../dr_theme.dart';
import '../space_tokens.g.dart';

/// The one gradient exception in the system: hero heading text, left to right.
/// Stops come from the generated gradient tokens, so both modes stay in sync.
class DrHeroHeading extends StatelessWidget {
  const DrHeroHeading({
    super.key,
    required this.text,
    this.textAlign = TextAlign.left,
  });

  final String text;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final List<Color> stops = dark ? DrGradients.heroDark : DrGradients.heroLight;
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (Rect bounds) => LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: stops,
      ).createShader(bounds),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: DrSize.contentMax),
        child: Text(
          text,
          style: context.drType.heading1,
          textAlign: textAlign,
        ),
      ),
    );
  }
}
