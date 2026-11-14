// GENERATED FILE - DO NOT EDIT.
// Source: design/tokens.json
// Regenerate: python tool/gen_tokens.py
// Re-running the generator is byte for byte idempotent.

import 'package:flutter/animation.dart';

/// Spacing scale, 0 to 96.
abstract final class DrSpace {
  static const double s0 = 0.0;
  static const double s2 = 2.0;
  static const double s4 = 4.0;
  static const double s8 = 8.0;
  static const double s12 = 12.0;
  static const double s16 = 16.0;
  static const double s20 = 20.0;
  static const double s24 = 24.0;
  static const double s28 = 28.0;
  static const double s32 = 32.0;
  static const double s36 = 36.0;
  static const double s40 = 40.0;
  static const double s44 = 44.0;
  static const double s48 = 48.0;
  static const double s56 = 56.0;
  static const double s64 = 64.0;
  static const double s72 = 72.0;
  static const double s80 = 80.0;
  static const double s96 = 96.0;

  static const List<double> scale = <double>[0.0, 2.0, 4.0, 8.0, 12.0, 16.0, 20.0, 24.0, 28.0, 32.0, 36.0, 40.0, 44.0, 48.0, 56.0, 64.0, 72.0, 80.0, 96.0];
}

/// Corner radius scale plus the nested radius rule.
abstract final class DrRadius {
  static const double r0 = 0.0;
  static const double r2 = 2.0;
  static const double r4 = 4.0;
  static const double r6 = 6.0;
  static const double r8 = 8.0;
  static const double r12 = 12.0;
  static const double r16 = 16.0;
  static const double r24 = 24.0;
  static const double full = 9999.0;

  static const List<double> scale = <double>[0.0, 2.0, 4.0, 6.0, 8.0, 12.0, 16.0, 24.0];
  static const double _maxGap = 32.0;
  static const double _minInner = 2.0;

  /// inner = outer - gap, snapped down to a radius token; square when the
  /// gap is 32 or wider, or when the result is not above 2.
  static double nested(double outer, double gap) {
    if (gap >= _maxGap) {
      return outer;
    }
    final double inner = outer - gap;
    if (inner <= _minInner) {
      return 0;
    }
    double best = 0;
    for (final double option in scale) {
      if (option <= inner && option > best) {
        best = option;
      }
    }
    return best;
  }
}

/// Fixed component sizes from the token source.
abstract final class DrSize {
  static const double iconSm = 16.0;
  static const double iconMd = 20.0;
  static const double iconLg = 24.0;
  static const double iconXl = 32.0;
  static const double strokeHairline = 1.0;
  static const double strokeDefault = 2.0;
  static const double strokeStrong = 3.0;
  static const double node = 12.0;
  static const double nodeLarge = 32.0;
  static const double contentMax = 680.0;
  static const double containerMax = 1200.0;
  static const double controlSm = 44.0;
  static const double controlMd = 48.0;
  static const double controlLg = 56.0;
}

/// Touch targets. Elder facing screens use [elder].
abstract final class DrTouch {
  static const double minimum = 44.0;
  static const double elder = 56.0;
}

/// Motion. No duration may sit below [minimum].
abstract final class DrMotion {
  static const Cubic curve = Cubic(0.22, 1.0, 0.36, 1.0);
  static const String curveCss = 'cubic-bezier(0.22, 1, 0.36, 1)';
  static const Duration layout = Duration(milliseconds: 500);
  static const Duration color = Duration(milliseconds: 300);
  static const Duration minimum = Duration(milliseconds: 200);
  static const Duration press = Duration(milliseconds: 200);
  static const double pressScale = 0.98;
}
