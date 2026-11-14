import 'package:dryrun/design/components/dr_banner.dart';
import 'package:dryrun/design/components/dr_button.dart';
import 'package:dryrun/design/components/dr_data_views.dart';
import 'package:dryrun/design/components/dr_hero_heading.dart';
import 'package:dryrun/design/components/dr_list_row.dart';
import 'package:dryrun/design/components/dr_node_line_diagram.dart';
import 'package:dryrun/design/components/dr_text_field.dart';
import 'package:dryrun/design/components/dr_timeline_row.dart';
import 'package:dryrun/design/color_tokens.g.dart';
import 'package:dryrun/design/design_gallery.dart';
import 'package:dryrun/design/dr_theme.dart';
import 'package:dryrun/design/space_tokens.g.dart';
import 'package:dryrun/design/type_tokens.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/design_test_support.dart';

void main() {
  setUpAll(loadDrFonts);

  for (final Brightness brightness in Brightness.values) {
    final String mode = brightness.name;

    testWidgets('button matrix $mode', (WidgetTester tester) async {
      await pumpGolden(tester, const _ButtonMatrix(), brightness, const Size(1000, 470));
      await expectLater(find.byType(Scaffold), matchesGoldenFile('goldens/buttons_$mode.png'));
    });

    testWidgets('text input states $mode', (WidgetTester tester) async {
      await pumpGolden(tester, const _FieldStates(), brightness, const Size(760, 500));
      await expectLater(find.byType(Scaffold), matchesGoldenFile('goldens/fields_$mode.png'));
    });

    testWidgets('list rows $mode', (WidgetTester tester) async {
      await pumpGolden(tester, const _ListRows(), brightness, const Size(640, 420));
      await expectLater(find.byType(Scaffold), matchesGoldenFile('goldens/list_rows_$mode.png'));
    });

    testWidgets('timeline $mode', (WidgetTester tester) async {
      await pumpGolden(tester, const _Timeline(), brightness, const Size(640, 240));
      await expectLater(find.byType(Scaffold), matchesGoldenFile('goldens/timeline_$mode.png'));
    });

    testWidgets('node and line diagram $mode', (WidgetTester tester) async {
      await pumpGolden(tester, const _Diagram(), brightness, const Size(640, 280));
      await expectLater(find.byType(Scaffold), matchesGoldenFile('goldens/diagram_$mode.png'));
    });

    testWidgets('drill banner $mode', (WidgetTester tester) async {
      await pumpGolden(tester, const _Banners(), brightness, const Size(820, 170));
      await expectLater(find.byType(Scaffold), matchesGoldenFile('goldens/banner_$mode.png'));
    });

    testWidgets('data views $mode', (WidgetTester tester) async {
      await pumpGolden(tester, const _DataViews(), brightness, const Size(720, 640));
      await expectLater(find.byType(Scaffold), matchesGoldenFile('goldens/data_views_$mode.png'));
    });

    testWidgets('hero heading $mode', (WidgetTester tester) async {
      await pumpGolden(tester, const _Hero(), brightness, const Size(820, 220));
      await expectLater(find.byType(Scaffold), matchesGoldenFile('goldens/hero_$mode.png'));
    });

    testWidgets('design gallery $mode', (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(1120, 5800);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: DesignGallery(initialBrightness: brightness),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(find.byType(DesignGallery), matchesGoldenFile('goldens/gallery_$mode.png'));
    });
  }
}

class _ButtonMatrix extends StatelessWidget {
  const _ButtonMatrix();

  @override
  Widget build(BuildContext context) {
    final DrColors colors = context.drColors;
    final DrTypeTheme type = context.drType;
    const double column = 168;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            const SizedBox(width: DrSpace.s80),
            for (final DrState state in DrState.values)
              SizedBox(
                width: column,
                child: Text(
                  state.name,
                  style: type.caption5.copyWith(color: colors.textTertiary),
                ),
              ),
          ],
        ),
        for (final DrButtonType buttonType in DrButtonType.values)
          Padding(
            padding: const EdgeInsets.only(bottom: DrSpace.s8),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: DrSpace.s80,
                  child: Text(
                    buttonType.name,
                    style: type.caption4.copyWith(color: colors.textSecondary),
                  ),
                ),
                for (final DrState state in DrState.values)
                  SizedBox(
                    width: column,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: DrButton(
                        label: 'Take drill',
                        type: buttonType,
                        size: DrButtonSize.sm,
                        stateOverride: state,
                        onPressed: state == DrState.disabled ? null : () {},
                      ),
                    ),
                  ),
              ],
            ),
          ),
        const SizedBox(height: DrSpace.s8),
        Row(
          children: <Widget>[
            for (final DrButtonSize size in DrButtonSize.values)
              Padding(
                padding: const EdgeInsets.only(right: DrSpace.s8),
                child: DrButton(label: size.name, size: size, onPressed: () {}),
              ),
            DrButton(
              label: 'Elder target',
              type: DrButtonType.tertiary,
              elder: true,
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }
}

class _FieldStates extends StatelessWidget {
  const _FieldStates();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: DrSpace.s24,
      runSpacing: DrSpace.s24,
      children: <Widget>[
        SizedBox(
          width: DrSpace.s96 + DrSpace.s96 + DrSpace.s96 + DrSpace.s32,
          child: DrTextField(label: 'Rest', hint: 'As on the call'),
        ),
        SizedBox(
          width: DrSpace.s96 + DrSpace.s96 + DrSpace.s96 + DrSpace.s32,
          child: DrTextField(label: 'Filled', hint: 'Bank branch', filled: true),
        ),
        SizedBox(
          width: DrSpace.s96 + DrSpace.s96 + DrSpace.s96 + DrSpace.s32,
          child: DrTextField(label: 'Focus', hint: 'Mumbai', stateOverride: DrFieldState.focus),
        ),
        SizedBox(
          width: DrSpace.s96 + DrSpace.s96 + DrSpace.s96 + DrSpace.s32,
          child: DrTextField(
            label: 'Error',
            hint: 'Account number',
            errorText: 'Use the 11 digit account number',
          ),
        ),
        SizedBox(
          width: DrSpace.s96 + DrSpace.s96 + DrSpace.s96 + DrSpace.s32,
          child: DrTextField(label: 'Disabled', hint: 'Session closed', enabled: false),
        ),
      ],
    );
  }
}

class _ListRows extends StatelessWidget {
  const _ListRows();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        DrListRow(
          title: 'Drill with Amma',
          subtitle: 'Invite sent 12 minutes ago',
          onTap: () {},
        ),
        DrListRow(
          title: 'Hover',
          subtitle: 'Instant static surface swap',
          stateOverride: DrState.hover,
          onTap: () {},
        ),
        DrListRow(
          title: 'Focus',
          subtitle: 'Two pixel ring, no animation',
          stateOverride: DrState.focus,
          onTap: () {},
        ),
        DrListRow(
          title: 'Disabled',
          subtitle: 'Session expired',
          stateOverride: DrState.disabled,
          onTap: () {},
        ),
      ],
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        DrTimelineRow(
          title: 'Invite sent',
          detail: 'A private link went out',
          trailingLabel: 'done',
          status: DrTimelineStatus.complete,
        ),
        DrTimelineRow(
          title: 'Drill call',
          detail: 'Officer line 3 of 8',
          trailingLabel: 'now',
          status: DrTimelineStatus.current,
        ),
        DrTimelineRow(
          title: 'Kind debrief',
          detail: 'Labels come from the engine',
          isLast: true,
        ),
      ],
    );
  }
}

class _Diagram extends StatelessWidget {
  const _Diagram();

  @override
  Widget build(BuildContext context) {
    return const DrNodeLineDiagram(
      nodes: <DrDiagramNode>[
        DrDiagramNode(
          label: 'Warning call',
          detail: 'Fictional officer',
          status: DrDiagramStatus.done,
        ),
        DrDiagramNode(
          label: 'Pressure turn',
          detail: 'Demand for secrecy',
          status: DrDiagramStatus.active,
        ),
        DrDiagramNode(label: 'Debrief'),
      ],
    );
  }
}

class _Banners extends StatelessWidget {
  const _Banners();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        DrBanner(
          badgeLabel: 'DRILL',
          message: 'This call is practice. The officer and the agency are fictional.',
        ),
        SizedBox(height: DrSpace.s12),
        DrBanner(
          badgeLabel: 'DRILL',
          message: 'Nothing is recorded beyond the session you delete.',
          variant: DrBannerVariant.info,
        ),
      ],
    );
  }
}

class _DataViews extends StatelessWidget {
  const _DataViews();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const DrSkeleton(lines: 3),
        const SizedBox(height: DrSpace.s24),
        DrEmptyView(
          title: 'No drill yet',
          message: 'Create a private link and the timeline starts here.',
          actionLabel: 'Create link',
          onAction: () {},
        ),
        const SizedBox(height: DrSpace.s24),
        DrErrorView(
          title: 'Session could not load',
          message: 'The invite expired. Ask for a new link.',
          retryLabel: 'Try again',
          onRetry: () {},
        ),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return const DrHeroHeading(text: 'Practice the call\nbefore it happens');
  }
}
