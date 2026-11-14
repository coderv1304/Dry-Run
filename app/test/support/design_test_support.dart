import 'package:dryrun/design/dr_theme.dart';
import 'package:dryrun/design/space_tokens.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads the bundled typefaces so goldens render real glyphs, not fallback boxes.
Future<void> loadDrFonts() async {
  final FontLoader poppins = FontLoader('Poppins');
  for (final String file in <String>[
    'Poppins-Regular',
    'Poppins-Medium',
    'Poppins-SemiBold',
    'Poppins-Bold',
  ]) {
    poppins.addFont(rootBundle.load('assets/fonts/$file.ttf'));
  }
  await poppins.load();

  final FontLoader devanagari = FontLoader('Noto Sans Devanagari');
  devanagari.addFont(rootBundle.load('assets/fonts/NotoSansDevanagari-Variable.ttf'));
  await devanagari.load();
}

/// Fixed-size themed frame used by every component golden.
Widget designFrame({
  required Brightness brightness,
  required Widget child,
  bool devanagari = false,
}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: drThemeData(brightness: brightness, devanagari: devanagari),
    home: Builder(
      builder: (BuildContext context) => Scaffold(
        backgroundColor: context.drColors.surfacePrimary,
        body: Padding(
          padding: const EdgeInsets.all(DrSpace.s24),
          child: child,
        ),
      ),
    ),
  );
}

Future<void> pumpGolden(
  WidgetTester tester,
  Widget child,
  Brightness brightness,
  Size size, {
  bool devanagari = false,
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    designFrame(brightness: brightness, child: child, devanagari: devanagari),
  );
  await tester.pumpAndSettle();
}
