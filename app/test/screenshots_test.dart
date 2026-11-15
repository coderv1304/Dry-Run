import 'package:api_client/api_client.dart';
import 'package:dryrun/features/session/session_controller.dart';
import 'package:dryrun/state/token_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_test_support.dart';
import 'support/design_test_support.dart';

/// The evidence set for the product review: six key screens at 390 wide in both
/// modes. These files are the reviewed screenshots in `docs/screenshots`, so the
/// test writes them once and then guards them against drift.
void main() {
  setUpAll(loadDrFonts);

  Future<void> capture(
    WidgetTester tester, {
    required String route,
    required String screen,
    required Brightness brightness,
    bool withSession = false,
    bool withTurn = false,
    String? inviteToken,
    String? reportToken,
  }) async {
    final FakeApi api = FakeApi();
    api.debriefs = <DebriefResponse>[fullDebrief()];
    api.turns = <TurnResponse>[
      contractModel('turn_response_valid', TurnResponse.fromJson),
    ];
    final ProviderContainer container = buildContainer(
      appOverrides(
        api: api,
        tokens: InitialTokens(
          inviteToken: inviteToken,
          reportToken: reportToken,
        ),
      ),
    );
    if (withSession) {
      container
          .read(tokenStoreProvider.notifier)
          .setSession(sessionId: 'ses_test', sessionToken: 'tok_test');
      container
          .read(sessionControllerProvider.notifier)
          .adopt(
            contractModel(
              'session_create_response_valid',
              SessionCreateResponse.fromJson,
            ),
          );
    }
    setTestView(tester, size: const Size(390, 844));
    await tester.pumpWidget(
      testRouterApp(
        initialLocation: route,
        container: container,
        brightness: brightness,
      ),
    );
    await tester.pumpAndSettle();
    if (withTurn) {
      await container
          .read(sessionControllerProvider.notifier)
          .send('I will check this with my family before I do anything.');
      await tester.pumpAndSettle();
    }
    final String mode = brightness == Brightness.light ? 'light' : 'dark';
    await expectLater(
      find.byType(Scaffold).first,
      matchesGoldenFile('../../docs/screenshots/$screen-$mode.png'),
    );
  }

  for (final Brightness brightness in Brightness.values) {
    testWidgets('home evidence', (WidgetTester tester) async {
      await capture(tester, route: '/', screen: 'home', brightness: brightness);
    });

    testWidgets('consent evidence', (WidgetTester tester) async {
      await capture(
        tester,
        route: '/consent',
        screen: 'consent',
        brightness: brightness,
        inviteToken: 'inv_test',
      );
    });

    testWidgets('drill evidence', (WidgetTester tester) async {
      await capture(
        tester,
        route: '/drill',
        screen: 'drill',
        brightness: brightness,
        withSession: true,
        withTurn: true,
      );
    });

    testWidgets('debrief evidence', (WidgetTester tester) async {
      await capture(
        tester,
        route: '/debrief',
        screen: 'debrief',
        brightness: brightness,
        withSession: true,
        inviteToken: 'inv_test',
      );
    });

    testWidgets('about evidence', (WidgetTester tester) async {
      await capture(
        tester,
        route: '/about',
        screen: 'about',
        brightness: brightness,
      );
    });

    testWidgets('report evidence', (WidgetTester tester) async {
      await capture(
        tester,
        route: '/report',
        screen: 'report',
        brightness: brightness,
        reportToken: 'rep_test',
      );
    });
  }
}
