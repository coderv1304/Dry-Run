// GENERATED FILE - DO NOT EDIT.
// Source: design/tokens.json
// Regenerate: python tool/gen_tokens.py
// Re-running the generator is byte for byte idempotent.

import 'package:flutter/material.dart';

/// The named text styles, in latin and Devanagari leading variants.
final class DrTypeTheme extends ThemeExtension<DrTypeTheme> {
  const DrTypeTheme(this.styles);

  final Map<String, TextStyle> styles;

  static const String fontFamily = 'Poppins';
  static const List<String> fontFamilyFallback = <String>['Noto Sans Devanagari'];

  TextStyle get heading1 => styles['heading-1']!;
  TextStyle get heading2 => styles['heading-2']!;
  TextStyle get heading3 => styles['heading-3']!;
  TextStyle get heading4 => styles['heading-4']!;
  TextStyle get heading5 => styles['heading-5']!;
  TextStyle get heading6 => styles['heading-6']!;
  TextStyle get title1 => styles['title-1']!;
  TextStyle get title2 => styles['title-2']!;
  TextStyle get title3 => styles['title-3']!;
  TextStyle get title4 => styles['title-4']!;
  TextStyle get title5 => styles['title-5']!;
  TextStyle get body1 => styles['body-1']!;
  TextStyle get body2 => styles['body-2']!;
  TextStyle get body3 => styles['body-3']!;
  TextStyle get body4 => styles['body-4']!;
  TextStyle get body5 => styles['body-5']!;
  TextStyle get body6 => styles['body-6']!;
  TextStyle get buttonLg => styles['button-lg']!;
  TextStyle get buttonMd => styles['button-md']!;
  TextStyle get buttonSm => styles['button-sm']!;
  TextStyle get buttonXsm => styles['button-xsm']!;
  TextStyle get caption1 => styles['caption-1']!;
  TextStyle get caption2 => styles['caption-2']!;
  TextStyle get caption3 => styles['caption-3']!;
  TextStyle get caption4 => styles['caption-4']!;
  TextStyle get caption5 => styles['caption-5']!;

  static const DrTypeTheme latin = DrTypeTheme(<String, TextStyle>{
    'heading-1': TextStyle(fontFamily: DrTypeTheme.fontFamily, fontFamilyFallback: DrTypeTheme.fontFamilyFallback, fontSize: 60.0, height: 1, fontWeight: FontWeight.w600, letterSpacing: 0.0),
    'heading-2': TextStyle(fontFamily: DrTypeTheme.fontFamily, fontFamilyFallback: DrTypeTheme.fontFamilyFallback, fontSize: 48.0, height: 1, fontWeight: FontWeight.w600, letterSpacing: 0.0),
    'heading-3': TextStyle(fontFamily: DrTypeTheme.fontFamily, fontFamilyFallback: DrTypeTheme.fontFamilyFallback, fontSize: 36.0, height: 1.1111, fontWeight: FontWeight.w600, letterSpacing: 0.0),
    'heading-4': TextStyle(fontFamily: DrTypeTheme.fontFamily, fontFamilyFallback: DrTypeTheme.fontFamilyFallback, fontSize: 30.0, height: 1.2, fontWeight: FontWeight.w600, letterSpacing: 0.0),
    'heading-5': TextStyle(fontFamily: DrTypeTheme.fontFamily, fontFamilyFallback: DrTypeTheme.fontFamilyFallback, fontSize: 24.0, height: 1.3333, fontWeight: FontWeight.w600, letterSpacing: 0.0),
    'heading-6': TextStyle(fontFamily: DrTypeTheme.fontFamily, fontFamilyFallback: DrTypeTheme.fontFamilyFallback, fontSize: 20.0, height: 1.4, fontWeight: FontWeight.w600, letterSpacing: 0.0),
    'title-1': TextStyle(fontFamily: DrTypeTheme.fontFamily, fontFamilyFallback: DrTypeTheme.fontFamilyFallback, fontSize: 20.0, height: 1.4, fontWeight: FontWeight.w500, letterSpacing: 0.0),
    'title-2': TextStyle(fontFamily: DrTypeTheme.fontFamily, fontFamilyFallback: DrTypeTheme.fontFamilyFallback, fontSize: 18.0, height: 1.5556, fontWeight: FontWeight.w500, letterSpacing: 0.0),
    'title-3': TextStyle(fontFamily: DrTypeTheme.fontFamily, fontFamilyFallback: DrTypeTheme.fontFamilyFallback, fontSize: 16.0, height: 1.5, fontWeight: FontWeight.w500, letterSpacing: 0.0),
    'title-4': TextStyle(fontFamily: DrTypeTheme.fontFamily, fontFamilyFallback: DrTypeTheme.fontFamilyFallback, fontSize: 14.0, height: 1.4286, fontWeight: FontWeight.w500, letterSpacing: 0.0),
    'title-5': TextStyle(fontFamily: DrTypeTheme.fontFamily, fontFamilyFallback: DrTypeTheme.fontFamilyFallback, fontSize: 12.0, height: 1.3333, fontWeight: FontWeight.w500, letterSpacing: 0.0),
    'body-1': TextStyle(fontFamily: DrTypeTheme.fontFamily, fontFamilyFallback: DrTypeTheme.fontFamilyFallback, fontSize: 16.0, height: 1.5, fontWeight: FontWeight.w600, letterSpacing: 0.0),
    'body-2': TextStyle(fontFamily: DrTypeTheme.fontFamily, fontFamilyFallback: DrTypeTheme.fontFamilyFallback, fontSize: 16.0, height: 1.5, fontWeight: FontWeight.w500, letterSpacing: 0.0),
    'body-3': TextStyle(fontFamily: DrTypeTheme.fontFamily, fontFamilyFallback: DrTypeTheme.fontFamilyFallback, fontSize: 16.0, height: 1.5, fontWeight: FontWeight.w400, letterSpacing: 0.0),
    'body-4': TextStyle(fontFamily: DrTypeTheme.fontFamily, fontFamilyFallback: DrTypeTheme.fontFamilyFallback, fontSize: 14.0, height: 1.4286, fontWeight: FontWeight.w600, letterSpacing: 0.0),
    'body-5': TextStyle(fontFamily: DrTypeTheme.fontFamily, fontFamilyFallback: DrTypeTheme.fontFamilyFallback, fontSize: 14.0, height: 1.4286, fontWeight: FontWeight.w500, letterSpacing: 0.0),
    'body-6': TextStyle(fontFamily: DrTypeTheme.fontFamily, fontFamilyFallback: DrTypeTheme.fontFamilyFallback, fontSize: 14.0, height: 1.4286, fontWeight: FontWeight.w400, letterSpacing: 0.0),
    'button-lg': TextStyle(fontFamily: DrTypeTheme.fontFamily, fontFamilyFallback: DrTypeTheme.fontFamilyFallback, fontSize: 18.0, height: 1.5556, fontWeight: FontWeight.w600, letterSpacing: 0.0),
    'button-md': TextStyle(fontFamily: DrTypeTheme.fontFamily, fontFamilyFallback: DrTypeTheme.fontFamilyFallback, fontSize: 16.0, height: 1.5, fontWeight: FontWeight.w600, letterSpacing: 0.0),
    'button-sm': TextStyle(fontFamily: DrTypeTheme.fontFamily, fontFamilyFallback: DrTypeTheme.fontFamilyFallback, fontSize: 14.0, height: 1.4286, fontWeight: FontWeight.w600, letterSpacing: 0.0),
    'button-xsm': TextStyle(fontFamily: DrTypeTheme.fontFamily, fontFamilyFallback: DrTypeTheme.fontFamilyFallback, fontSize: 12.0, height: 1.3333, fontWeight: FontWeight.w600, letterSpacing: 0.0),
    'caption-1': TextStyle(fontFamily: DrTypeTheme.fontFamily, fontFamilyFallback: DrTypeTheme.fontFamilyFallback, fontSize: 14.0, height: 1.4286, fontWeight: FontWeight.w500, letterSpacing: 0.0),
    'caption-2': TextStyle(fontFamily: DrTypeTheme.fontFamily, fontFamilyFallback: DrTypeTheme.fontFamilyFallback, fontSize: 14.0, height: 1.4286, fontWeight: FontWeight.w400, letterSpacing: 0.0),
    'caption-3': TextStyle(fontFamily: DrTypeTheme.fontFamily, fontFamilyFallback: DrTypeTheme.fontFamilyFallback, fontSize: 12.0, height: 1.3333, fontWeight: FontWeight.w600, letterSpacing: 0.0),
    'caption-4': TextStyle(fontFamily: DrTypeTheme.fontFamily, fontFamilyFallback: DrTypeTheme.fontFamilyFallback, fontSize: 12.0, height: 1.3333, fontWeight: FontWeight.w500, letterSpacing: 0.0),
    'caption-5': TextStyle(fontFamily: DrTypeTheme.fontFamily, fontFamilyFallback: DrTypeTheme.fontFamilyFallback, fontSize: 12.0, height: 1.3333, fontWeight: FontWeight.w400, letterSpacing: 0.0),
  });

  static const DrTypeTheme devanagari = DrTypeTheme(<String, TextStyle>{
    'heading-1': TextStyle(fontFamily: DrTypeTheme.fontFamily, fontFamilyFallback: DrTypeTheme.fontFamilyFallback, fontSize: 60.0, height: 1.2, fontWeight: FontWeight.w600, letterSpacing: 0.0),
    'heading-2': TextStyle(fontFamily: DrTypeTheme.fontFamily, fontFamilyFallback: DrTypeTheme.fontFamilyFallback, fontSize: 48.0, height: 1.1667, fontWeight: FontWeight.w600, letterSpacing: 0.0),
    'heading-3': TextStyle(fontFamily: DrTypeTheme.fontFamily, fontFamilyFallback: DrTypeTheme.fontFamilyFallback, fontSize: 36.0, height: 1.3333, fontWeight: FontWeight.w600, letterSpacing: 0.0),
    'heading-4': TextStyle(fontFamily: DrTypeTheme.fontFamily, fontFamilyFallback: DrTypeTheme.fontFamilyFallback, fontSize: 30.0, height: 1.4667, fontWeight: FontWeight.w600, letterSpacing: 0.0),
    'heading-5': TextStyle(fontFamily: DrTypeTheme.fontFamily, fontFamilyFallback: DrTypeTheme.fontFamilyFallback, fontSize: 24.0, height: 1.6667, fontWeight: FontWeight.w600, letterSpacing: 0.0),
    'heading-6': TextStyle(fontFamily: DrTypeTheme.fontFamily, fontFamilyFallback: DrTypeTheme.fontFamilyFallback, fontSize: 20.0, height: 1.8, fontWeight: FontWeight.w600, letterSpacing: 0.0),
    'title-1': TextStyle(fontFamily: DrTypeTheme.fontFamily, fontFamilyFallback: DrTypeTheme.fontFamilyFallback, fontSize: 20.0, height: 1.8, fontWeight: FontWeight.w500, letterSpacing: 0.0),
    'title-2': TextStyle(fontFamily: DrTypeTheme.fontFamily, fontFamilyFallback: DrTypeTheme.fontFamilyFallback, fontSize: 18.0, height: 2, fontWeight: FontWeight.w500, letterSpacing: 0.0),
    'title-3': TextStyle(fontFamily: DrTypeTheme.fontFamily, fontFamilyFallback: DrTypeTheme.fontFamilyFallback, fontSize: 16.0, height: 1.75, fontWeight: FontWeight.w500, letterSpacing: 0.0),
    'title-4': TextStyle(fontFamily: DrTypeTheme.fontFamily, fontFamilyFallback: DrTypeTheme.fontFamilyFallback, fontSize: 14.0, height: 1.7143, fontWeight: FontWeight.w500, letterSpacing: 0.0),
    'title-5': TextStyle(fontFamily: DrTypeTheme.fontFamily, fontFamilyFallback: DrTypeTheme.fontFamilyFallback, fontSize: 12.0, height: 1.6667, fontWeight: FontWeight.w500, letterSpacing: 0.0),
    'body-1': TextStyle(fontFamily: DrTypeTheme.fontFamily, fontFamilyFallback: DrTypeTheme.fontFamilyFallback, fontSize: 16.0, height: 1.75, fontWeight: FontWeight.w600, letterSpacing: 0.0),
    'body-2': TextStyle(fontFamily: DrTypeTheme.fontFamily, fontFamilyFallback: DrTypeTheme.fontFamilyFallback, fontSize: 16.0, height: 1.75, fontWeight: FontWeight.w500, letterSpacing: 0.0),
    'body-3': TextStyle(fontFamily: DrTypeTheme.fontFamily, fontFamilyFallback: DrTypeTheme.fontFamilyFallback, fontSize: 16.0, height: 1.75, fontWeight: FontWeight.w400, letterSpacing: 0.0),
    'body-4': TextStyle(fontFamily: DrTypeTheme.fontFamily, fontFamilyFallback: DrTypeTheme.fontFamilyFallback, fontSize: 14.0, height: 1.7143, fontWeight: FontWeight.w600, letterSpacing: 0.0),
    'body-5': TextStyle(fontFamily: DrTypeTheme.fontFamily, fontFamilyFallback: DrTypeTheme.fontFamilyFallback, fontSize: 14.0, height: 1.7143, fontWeight: FontWeight.w500, letterSpacing: 0.0),
    'body-6': TextStyle(fontFamily: DrTypeTheme.fontFamily, fontFamilyFallback: DrTypeTheme.fontFamilyFallback, fontSize: 14.0, height: 1.7143, fontWeight: FontWeight.w400, letterSpacing: 0.0),
    'button-lg': TextStyle(fontFamily: DrTypeTheme.fontFamily, fontFamilyFallback: DrTypeTheme.fontFamilyFallback, fontSize: 18.0, height: 2, fontWeight: FontWeight.w600, letterSpacing: 0.0),
    'button-md': TextStyle(fontFamily: DrTypeTheme.fontFamily, fontFamilyFallback: DrTypeTheme.fontFamilyFallback, fontSize: 16.0, height: 1.75, fontWeight: FontWeight.w600, letterSpacing: 0.0),
    'button-sm': TextStyle(fontFamily: DrTypeTheme.fontFamily, fontFamilyFallback: DrTypeTheme.fontFamilyFallback, fontSize: 14.0, height: 1.7143, fontWeight: FontWeight.w600, letterSpacing: 0.0),
    'button-xsm': TextStyle(fontFamily: DrTypeTheme.fontFamily, fontFamilyFallback: DrTypeTheme.fontFamilyFallback, fontSize: 12.0, height: 1.6667, fontWeight: FontWeight.w600, letterSpacing: 0.0),
    'caption-1': TextStyle(fontFamily: DrTypeTheme.fontFamily, fontFamilyFallback: DrTypeTheme.fontFamilyFallback, fontSize: 14.0, height: 1.7143, fontWeight: FontWeight.w500, letterSpacing: 0.0),
    'caption-2': TextStyle(fontFamily: DrTypeTheme.fontFamily, fontFamilyFallback: DrTypeTheme.fontFamilyFallback, fontSize: 14.0, height: 1.7143, fontWeight: FontWeight.w400, letterSpacing: 0.0),
    'caption-3': TextStyle(fontFamily: DrTypeTheme.fontFamily, fontFamilyFallback: DrTypeTheme.fontFamilyFallback, fontSize: 12.0, height: 1.6667, fontWeight: FontWeight.w600, letterSpacing: 0.0),
    'caption-4': TextStyle(fontFamily: DrTypeTheme.fontFamily, fontFamilyFallback: DrTypeTheme.fontFamilyFallback, fontSize: 12.0, height: 1.6667, fontWeight: FontWeight.w500, letterSpacing: 0.0),
    'caption-5': TextStyle(fontFamily: DrTypeTheme.fontFamily, fontFamilyFallback: DrTypeTheme.fontFamilyFallback, fontSize: 12.0, height: 1.6667, fontWeight: FontWeight.w400, letterSpacing: 0.0),
  });

  @override
  DrTypeTheme copyWith({Map<String, TextStyle>? styles}) => DrTypeTheme(styles ?? this.styles);

  @override
  DrTypeTheme lerp(ThemeExtension<DrTypeTheme>? other, double t) {
    if (other is! DrTypeTheme) {
      return this;
    }
    return DrTypeTheme(<String, TextStyle>{
      for (final String key in styles.keys)
        key: TextStyle.lerp(styles[key], other.styles[key], t) ?? styles[key]!,
    });
  }
}
