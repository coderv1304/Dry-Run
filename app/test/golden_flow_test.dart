import 'package:api_client/api_client.dart';
import 'package:dryrun/state/token_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_test_support.dart';
import 'support/design_test_support.dart';

/// Whole-flow goldens at the three reviewed widths. Hindi runs at 200 percent
/// text scale so a clipped control fails the suite rather than shipping.
void main() {
  setUpAll(loadDrFonts);

  Future<ProviderContainer> pumpFlow(
    WidgetTester tester, {
    required String route,
    required Brightness brightness,
    required Size size,
    Locale locale = const Locale('en'),
    double textScale = 1,
    bool withSession = false,
    String? inviteToken,
  }) async {
    final FakeApi api = FakeApi();
    api.debriefs = <DebriefResponse>[fullDebrief()];
    final ProviderContainer container = buildContainer(
      appOverrides(
        api: api,
        tokens: InitialTokens(inviteToken: inviteToken),
      ),
    );
    if (withSession) {
      container.read(tokenStoreProvider.notifier).setSession(
            sessionId: 'ses_test',
            sessionToken: 'tok_test',
          );
    }
    setTestView(tester, size: size);
    await tester.pumpWidget(
      testRouterApp(
        initialLocation: route,
        container: container,
        brightness: brightness,
        locale: locale,
        textScale: textScale,
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  Future<void> golden(WidgetTester tester, String name) async {
    await expectLater(
      find.byType(Scaffold).first,
      matchesGoldenFile('goldens/flow_$name.png'),
    );
  }

  testWidgets('home at 390 light', (WidgetTester tester) async {
    await pumpFlow(
      tester,
      route: '/',
      brightness: Brightness.light,
      size: const Size(390, 844),
    );
    await golden(tester, 'home_390_light');
  });

  testWidgets('home at 390 dark', (WidgetTester tester) async {
    await pumpFlow(
      tester,
      route: '/',
      brightness: Brightness.dark,
      size: const Size(390, 844),
    );
    await golden(tester, 'home_390_dark');
  });

  testWidgets('home at 768 light', (WidgetTester tester) async {
    await pumpFlow(
      tester,
      route: '/',
      brightness: Brightness.light,
      size: const Size(768, 1024),
    );
    await golden(tester, 'home_768_light');
  });

  testWidgets('home at 1440 dark', (WidgetTester tester) async {
    await pumpFlow(
      tester,
      route: '/',
      brightness: Brightness.dark,
      size: const Size(1440, 1000),
    );
    await golden(tester, 'home_1440_dark');
  });

  testWidgets('debrief at 390 light', (WidgetTester tester) async {
    await pumpFlow(
      tester,
      route: '/debrief',
      brightness: Brightness.light,
      size: const Size(390, 844),
      withSession: true,
      inviteToken: 'inv_test',
    );
    await golden(tester, 'debrief_390_light');
  });

  testWidgets('debrief at 768 dark', (WidgetTester tester) async {
    await pumpFlow(
      tester,
      route: '/debrief',
      brightness: Brightness.dark,
      size: const Size(768, 1024),
      withSession: true,
      inviteToken: 'inv_test',
    );
    await golden(tester, 'debrief_768_dark');
  });

  testWidgets('debrief at 1440 light', (WidgetTester tester) async {
    await pumpFlow(
      tester,
      route: '/debrief',
      brightness: Brightness.light,
      size: const Size(1440, 1000),
      withSession: true,
      inviteToken: 'inv_test',
    );
    await golden(tester, 'debrief_1440_light');
  });

  testWidgets('debrief Hindi at 200 percent', (WidgetTester tester) async {
    await pumpFlow(
      tester,
      route: '/debrief',
      brightness: Brightness.light,
      size: const Size(390, 844),
      locale: const Locale('hi'),
      textScale: 2,
      withSession: true,
      inviteToken: 'inv_test',
    );
    await golden(tester, 'debrief_hi_390_200');
  });

  testWidgets('consent Hindi at 200 percent', (WidgetTester tester) async {
    await pumpFlow(
      tester,
      route: '/consent',
      brightness: Brightness.light,
      size: const Size(390, 844),
      locale: const Locale('hi'),
      textScale: 2,
      inviteToken: 'inv_test',
    );
    await golden(tester, 'consent_hi_390_200');
  });
}
