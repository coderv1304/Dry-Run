import 'package:dryrun/design/color_tokens.g.dart';
import 'package:dryrun/design/components/dr_button.dart';
import 'package:dryrun/design/components/dr_data_views.dart';
import 'package:dryrun/design/design_gallery.dart';
import 'package:dryrun/design/dr_theme.dart';
import 'package:dryrun/design/space_tokens.g.dart';
import 'package:dryrun/design/type_tokens.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/design_test_support.dart';

void main() {
  setUpAll(loadDrFonts);

  group('typography', () {
    test('Poppins overrides the framework default in every component theme', () {
      for (final Brightness brightness in Brightness.values) {
        final ThemeData theme = drThemeData(brightness: brightness);
        final List<TextStyle?> styles = <TextStyle?>[
          theme.textTheme.displayLarge,
          theme.textTheme.headlineLarge,
          theme.textTheme.titleMedium,
          theme.textTheme.bodyLarge,
          theme.textTheme.bodyMedium,
          theme.textTheme.labelLarge,
          theme.appBarTheme.titleTextStyle,
          theme.dialogTheme.titleTextStyle,
          theme.dialogTheme.contentTextStyle,
          theme.snackBarTheme.contentTextStyle,
          theme.listTileTheme.titleTextStyle,
          theme.listTileTheme.subtitleTextStyle,
          theme.chipTheme.labelStyle,
          theme.inputDecorationTheme.hintStyle,
          theme.inputDecorationTheme.errorStyle,
          theme.tooltipTheme.textStyle,
          theme.tabBarTheme.labelStyle,
          theme.bottomNavigationBarTheme.selectedLabelStyle,
        ];
        for (final TextStyle? style in styles) {
          expect(style?.fontFamily, 'Poppins');
          expect(style?.fontFamilyFallback, <String>['Noto Sans Devanagari']);
        }
        expect(
          theme.navigationBarTheme.labelTextStyle!.resolve(<WidgetState>{}),
          isNotNull,
        );
      }
    });

    test('every text style stays on the Tailwind scale, upright and at or below bold', () {
      const List<double> scale = <double>[12, 14, 16, 18, 20, 24, 30, 36, 48, 60, 72, 96, 128];
      for (final DrTypeTheme variant in <DrTypeTheme>[
        DrTypeTheme.latin,
        DrTypeTheme.devanagari,
      ]) {
        for (final TextStyle style in variant.styles.values) {
          expect(scale, contains(style.fontSize));
          expect(style.fontStyle, isNot(FontStyle.italic));
          expect(style.fontWeight!.value <= 700, isTrue);
        }
      }
    });

    test('headings are semibold and Devanagari leading is looser everywhere', () {
      for (final MapEntry<String, TextStyle> entry in DrTypeTheme.latin.styles.entries) {
        if (entry.key.startsWith('heading')) {
          expect(entry.value.fontWeight, FontWeight.w600);
        }
        final TextStyle hindi = DrTypeTheme.devanagari.styles[entry.key]!;
        expect(hindi.fontSize, entry.value.fontSize);
        expect(hindi.height! > entry.value.height!, isTrue);
      }
    });
  });

  group('motion', () {
    test('every built in button theme declares zero animation duration', () {
      final ThemeData theme = drThemeData(brightness: Brightness.light);
      expect(theme.elevatedButtonTheme.style!.animationDuration, Duration.zero);
      expect(theme.filledButtonTheme.style!.animationDuration, Duration.zero);
      expect(theme.outlinedButtonTheme.style!.animationDuration, Duration.zero);
      expect(theme.textButtonTheme.style!.animationDuration, Duration.zero);
      expect(theme.iconButtonTheme.style!.animationDuration, Duration.zero);
    });

    test('no motion token is shorter than 200 ms and the curve is fixed', () {
      expect(DrMotion.curveCss, 'cubic-bezier(0.22, 1, 0.36, 1)');
      expect(DrMotion.layout.inMilliseconds, 500);
      expect(DrMotion.color.inMilliseconds, 300);
      expect(DrMotion.minimum.inMilliseconds >= 200, isTrue);
      expect(DrMotion.press.inMilliseconds, 200);
      expect(DrMotion.pressScale, 0.98);
    });
  });

  group('buttons', () {
    test('hover is a static colour swap, focus keeps the fill and adds a ring', () {
      const DrColors colors = DrColors.light;
      final DrButtonPalette rest = drButtonPalette(
        colors: colors,
        type: DrButtonType.primary,
        state: DrState.rest,
      );
      final DrButtonPalette hover = drButtonPalette(
        colors: colors,
        type: DrButtonType.primary,
        state: DrState.hover,
      );
      final DrButtonPalette focus = drButtonPalette(
        colors: colors,
        type: DrButtonType.primary,
        state: DrState.focus,
      );
      final DrButtonPalette disabled = drButtonPalette(
        colors: colors,
        type: DrButtonType.primary,
        state: DrState.disabled,
      );
      expect(rest.fill, colors.actionPrimary);
      expect(hover.fill, colors.actionPrimaryHover);
      expect(hover.fill, isNot(rest.fill));
      expect(focus.fill, rest.fill);
      expect(focus.focusRing, colors.borderFocus);
      expect(disabled.fill, colors.actionPrimaryDisabled);
      expect(disabled.label, colors.textDisabled);
      expect(rest.label, colors.textOnAction);
    });

    test('all five types resolve in all five states', () {
      for (final DrButtonType type in DrButtonType.values) {
        for (final DrState state in DrState.values) {
          final DrButtonPalette palette = drButtonPalette(
            colors: DrColors.dark,
            type: type,
            state: state,
          );
          expect(palette.fill.a, greaterThan(0));
        }
      }
    });

    testWidgets('renders without any animated colour widgets', (WidgetTester tester) async {
      await tester.pumpWidget(
        designFrame(
          brightness: Brightness.light,
          child: DrButton(label: 'Take drill', onPressed: () {}),
        ),
      );
      final Finder inside = find.descendant(
        of: find.byType(DrButton),
        matching: find.byType(AnimatedContainer),
      );
      expect(inside, findsNothing);
      expect(
        find.descendant(of: find.byType(DrButton), matching: find.byType(AnimatedOpacity)),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byType(DrButton),
          matching: find.byType(DecoratedBoxTransition),
        ),
        findsNothing,
      );
      final AnimatedScale scale = tester.widget(find.byType(AnimatedScale));
      expect(scale.duration, DrMotion.press);
      expect(scale.curve, DrMotion.curve);
      expect(scale.scale, 1.0);
    });

    testWidgets('pressed state applies the 0.98 scale feedback', (WidgetTester tester) async {
      await tester.pumpWidget(
        designFrame(
          brightness: Brightness.dark,
          child: const DrButton(
            label: 'Take drill',
            stateOverride: DrState.pressed,
            onPressed: _noop,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final AnimatedScale scale = tester.widget(find.byType(AnimatedScale));
      expect(scale.scale, DrMotion.pressScale);
    });
  });

  group('tokens', () {
    test('spacing runs 0 to 96 and radius follows the nested rule', () {
      expect(DrSpace.scale.first, 0);
      expect(DrSpace.scale.last, 96);
      expect(DrRadius.nested(DrRadius.r16, DrSpace.s8), DrRadius.r8);
      expect(DrRadius.nested(DrRadius.r16, DrSpace.s32), DrRadius.r16);
      expect(DrRadius.nested(DrRadius.r12, DrSpace.s2), DrRadius.r8);
      expect(DrRadius.nested(DrRadius.r4, DrSpace.s4), 0);
    });

    test('touch targets meet the minimum and elder sizes', () {
      expect(DrTouch.minimum, 44);
      expect(DrTouch.elder, 56);
      expect(DrTouch.elder > DrTouch.minimum, isTrue);
    });

    test('light and dark expose the same semantic tokens', () {
      expect(
        DrColors.lightByName.keys.toSet(),
        DrColors.darkByName.keys.toSet(),
      );
      expect(DrColors.lightByName.length >= 60, isTrue);
    });

    test('core palettes carry at least ten shades each', () {
      for (final Map<String, Color> palette in DrCore.palettes.values) {
        expect(palette.length >= 10, isTrue);
      }
    });
  });

  testWidgets('gallery renders every section in both modes', (WidgetTester tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1120, 6100);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final Brightness brightness in Brightness.values) {
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: DesignGallery(initialBrightness: brightness),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Dry Run design system'), findsOneWidget);
      expect(find.text('Buttons'), findsOneWidget);
      expect(
        find.text(
          brightness == Brightness.light
              ? 'Every token and every component state, light mode'
              : 'Every token and every component state, dark mode',
        ),
        findsOneWidget,
      );
    }
  });

  testWidgets('data views carry their copy and an action', (WidgetTester tester) async {
    await tester.pumpWidget(
      designFrame(
        brightness: Brightness.light,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const DrSkeleton(lines: 2),
            DrEmptyView(
              title: 'No drill yet',
              message: 'Create a private link to start.',
              actionLabel: 'Create link',
              onAction: _noop,
            ),
          ],
        ),
      ),
    );
    expect(find.text('No drill yet'), findsOneWidget);
    expect(find.text('Create link'), findsOneWidget);
    expect(find.text('Rest'), findsNothing);
  });
}

void _noop() {}
