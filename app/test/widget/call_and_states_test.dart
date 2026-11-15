import 'package:api_client/api_client.dart';
import 'package:dryrun/core/haptics.dart';
import 'package:dryrun/design/components/dr_call_status.dart';
import 'package:dryrun/design/components/dr_reveal.dart';
import 'package:dryrun/design/dr_theme.dart';
import 'package:dryrun/features/drill/drill_widgets.dart';
import 'package:dryrun/features/session/session_controller.dart';
import 'package:dryrun/l10n/app_localizations.dart';
import 'package:dryrun/state/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_test_support.dart';

class _RecordingHaptics implements DrHaptics {
  final List<String> calls = <String>[];

  @override
  Future<void> tap() async => calls.add('tap');

  @override
  Future<void> success() async => calls.add('success');

  @override
  Future<void> warn() async => calls.add('warn');
}

void main() {
  test('call state follows the drill, not a timer', () {
    expect(callStateFor(sending: true, messageCount: 0), DrCallState.ringing);
    expect(callStateFor(sending: true, messageCount: 3), DrCallState.answering);
    expect(callStateFor(sending: false, messageCount: 0), DrCallState.live);
    expect(callStateFor(sending: false, messageCount: 3), DrCallState.live);
  });

  testWidgets('the call strip keeps the badge in all three states', (
    WidgetTester tester,
  ) async {
    for (final DrCallState state in DrCallState.values) {
      await tester.pumpWidget(
        MaterialApp(
          theme: drThemeData(brightness: Brightness.light),
          home: Builder(
            builder: (BuildContext context) => Scaffold(
              backgroundColor: context.drColors.surfacePrimary,
              body: DrCallStatus(
                state: state,
                badgeLabel: 'DRILL',
                stateLabel: state.name,
              ),
            ),
          ),
        ),
      );
      expect(find.text('DRILL'), findsOneWidget);
      expect(find.text(state.name), findsOneWidget);
    }
  });

  testWidgets('reduced motion shows every revealed row at once', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: drThemeData(brightness: Brightness.light),
        builder: (BuildContext context, Widget? child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child ?? const SizedBox.shrink(),
        ),
        home: Scaffold(
          body: DrRevealGroup(
            itemCount: 3,
            builder: (BuildContext context, int index) => Text('row $index'),
          ),
        ),
      ),
    );
    await tester.pump();
    final FadeTransition fade = tester
        .widgetList<FadeTransition>(find.byType(FadeTransition))
        .first;
    expect(fade.opacity.value, 1);
    expect(find.text('row 2'), findsOneWidget);
  });

  testWidgets('the drill strip and badge survive Hindi at 200 percent', (
    WidgetTester tester,
  ) async {
    final FakeApi api = FakeApi();
    final ProviderContainer container = buildContainer(appOverrides(api: api));
    container
        .read(sessionControllerProvider.notifier)
        .adopt(
          contractModel(
            'session_create_response_valid',
            SessionCreateResponse.fromJson,
          ),
        );
    setTestView(tester, size: const Size(390, 844));
    await tester.pumpWidget(
      testRouterApp(
        initialLocation: '/drill',
        container: container,
        locale: const Locale('hi'),
        textScale: 2,
      ),
    );
    await tester.pumpAndSettle();

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(Scaffold).first),
    );
    expect(tester.takeException(), isNull);
    expect(find.text(l10n.drillBadge), findsOneWidget);
    expect(find.text(l10n.drillCallLive), findsOneWidget);
  });

  testWidgets('haptics fire on send and on the officer reply', (
    WidgetTester tester,
  ) async {
    final FakeApi api = FakeApi();
    api.turns = <TurnResponse>[
      contractModel('turn_response_valid', TurnResponse.fromJson),
    ];
    final _RecordingHaptics haptics = _RecordingHaptics();
    final ProviderContainer container = buildContainer(<Override>[
      ...appOverrides(api: api),
      hapticsProvider.overrideWithValue(haptics),
    ]);
    container
        .read(sessionControllerProvider.notifier)
        .adopt(
          contractModel(
            'session_create_response_valid',
            SessionCreateResponse.fromJson,
          ),
        );
    setTestView(tester, size: const Size(390, 844));
    await tester.pumpWidget(
      testRouterApp(initialLocation: '/drill', container: container),
    );
    await tester.pumpAndSettle();

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(Scaffold).first),
    );
    await tester.enterText(find.byType(TextField), 'I will call my bank.');
    await tester.tap(find.text(l10n.drillSend));
    await tester.pumpAndSettle();

    expect(haptics.calls, contains('tap'));
    expect(haptics.calls, contains('success'));
  });
}
