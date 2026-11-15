import 'dart:async';

import 'package:api_client/api_client.dart';
import 'package:dryrun/design/components/dr_button.dart';
import 'package:dryrun/features/debrief/debrief_screen.dart';
import 'package:dryrun/features/report/report_screen.dart';
import 'package:dryrun/features/session/session_controller.dart';
import 'package:dryrun/l10n/app_localizations.dart';
import 'package:dryrun/state/token_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_test_support.dart';

void main() {
  late FakeApi api;
  late ProviderContainer container;

  AppLocalizations copy(WidgetTester tester) => AppLocalizations.of(
        tester.element(find.byType(Scaffold).first),
      );

  Future<void> pumpRoute(
    WidgetTester tester,
    String route, {
    Size size = const Size(1100, 1600),
    Locale locale = const Locale('en'),
    double textScale = 1,
  }) async {
    setTestView(tester, size: size);
    await tester.pumpWidget(
      testRouterApp(
        initialLocation: route,
        container: container,
        locale: locale,
        textScale: textScale,
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() {
    api = FakeApi();
  });

  testWidgets('consent shows plain practice copy, opt-in and a big start',
      (WidgetTester tester) async {
    container = buildContainer(
      appOverrides(
        api: api,
        tokens: const InitialTokens(inviteToken: 'inv_consent'),
      ),
    );

    await pumpRoute(tester, '/consent');

    final AppLocalizations l10n = copy(tester);
    expect(find.text(l10n.consentPracticeLine1), findsOneWidget);
    expect(find.text(l10n.consentPracticeLine2), findsOneWidget);
    expect(find.text(l10n.consentPracticeLine3), findsOneWidget);

    final Checkbox optIn = tester.widget<Checkbox>(find.byType(Checkbox));
    expect(optIn.value, isFalse);

    final Finder start = find.widgetWithText(DrButton, l10n.consentStartButton);
    expect(start, findsOneWidget);
    expect(tester.getSize(start).height, greaterThanOrEqualTo(56));

    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);

    await tester.tap(start);
    await tester.pumpAndSettle();

    expect(api.createdSessions, hasLength(1));
    expect(api.createdSessions.single.consent, isTrue);
    expect(api.createdSessions.single.statsOptIn, isTrue);
    expect(find.text('Identify yourself.'), findsOneWidget);
  });

  testWidgets('consent can be declined without creating a session',
      (WidgetTester tester) async {
    container = buildContainer(
      appOverrides(
        api: api,
        tokens: const InitialTokens(inviteToken: 'inv_consent'),
      ),
    );

    await pumpRoute(tester, '/consent');

    final AppLocalizations l10n = copy(tester);
    await tester.tap(find.widgetWithText(DrButton, l10n.consentDecline));
    await tester.pumpAndSettle();

    expect(api.createdSessions, isEmpty);
    expect(container.read(tokenStoreProvider).inviteToken, isNull);
    expect(find.text(l10n.homeTitle), findsOneWidget);
  });

  testWidgets('drill keeps the badge and End drill visible, waits calmly',
      (WidgetTester tester) async {
    final _BlockingTurnApi blocking = _BlockingTurnApi();
    container = buildContainer(appOverrides(api: blocking));
    final SessionCreateResponse session = contractModel(
      'session_create_response_valid',
      SessionCreateResponse.fromJson,
    );
    container.read(sessionControllerProvider.notifier).adopt(session);

    await pumpRoute(tester, '/drill', size: const Size(900, 1000));

    final AppLocalizations l10n = copy(tester);
    expect(find.text(l10n.drillBadge), findsOneWidget);
    expect(find.text(l10n.drillEnd), findsOneWidget);
    expect(find.text('Identify yourself.'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'I am not sharing that.');
    await tester.tap(find.widgetWithText(DrButton, l10n.drillSend));
    await tester.pump();

    expect(find.text(l10n.drillWaiting), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(blocking.submittedTurns, hasLength(1));

    blocking.gate.complete(
      contractModel('turn_response_valid', TurnResponse.fromJson),
    );
    await tester.pumpAndSettle();
    expect(find.text('Who is speaking?'), findsOneWidget);
  });

  testWidgets('End drill asks first, then opens the debrief',
      (WidgetTester tester) async {
    container = buildContainer(appOverrides(api: api));
    final SessionCreateResponse session = contractModel(
      'session_create_response_valid',
      SessionCreateResponse.fromJson,
    );
    container.read(sessionControllerProvider.notifier).adopt(session);
    api.debriefs = <DebriefResponse>[fullDebrief()];

    await pumpRoute(tester, '/drill', size: const Size(900, 1000));

    final AppLocalizations l10n = copy(tester);
    await tester.tap(find.widgetWithText(DrButton, l10n.drillEnd));
    await tester.pumpAndSettle();

    expect(find.text(l10n.drillEndConfirmTitle), findsOneWidget);
    await tester.tap(
      find.widgetWithText(DrButton, l10n.drillEndConfirmButton),
    );
    await tester.pumpAndSettle();

    expect(find.byType(DebriefScreen), findsOneWidget);
    expect(find.text(l10n.debriefTitle), findsOneWidget);
  });

  testWidgets('debrief renders timeline, first compliance and actions',
      (WidgetTester tester) async {
    container = buildContainer(
      appOverrides(
        api: api,
        tokens: const InitialTokens(inviteToken: 'inv_test'),
      ),
    );
    container.read(tokenStoreProvider.notifier).setSession(
          sessionId: 'ses_test',
          sessionToken: 'tok_test',
        );
    api.debriefs = <DebriefResponse>[fullDebrief()];

    await pumpRoute(tester, '/debrief');

    final AppLocalizations l10n = copy(tester);
    expect(find.text(l10n.debriefTimelineTitle), findsOneWidget);
    expect(find.text(l10n.debriefStatePathTitle), findsOneWidget);
    expect(find.textContaining('my aadhaar number is'), findsOneWidget);
    expect(find.textContaining('Confidence 92 percent'), findsOneWidget);
    expect(find.text(l10n.debriefFirstComplianceTitle), findsOneWidget);
    expect(find.text(l10n.debriefFirstComplianceBody), findsOneWidget);
    expect(find.text(l10n.didWellRefusedMoneyTransfer), findsOneWidget);
    expect(find.text(l10n.habitCallBackTitle), findsOneWidget);
    expect(find.text(l10n.debriefShareButton), findsOneWidget);
    expect(find.text(l10n.debriefDeleteButton), findsOneWidget);
  });

  testWidgets('share needs explicit consent before the OS sheet',
      (WidgetTester tester) async {
    final RecordingShare share = RecordingShare();
    container = buildContainer(
      appOverrides(
        api: api,
        tokens: const InitialTokens(inviteToken: 'inv_test'),
        share: share,
      ),
    );
    container.read(tokenStoreProvider.notifier).setSession(
          sessionId: 'ses_test',
          sessionToken: 'tok_test',
        );
    api.debriefs = <DebriefResponse>[fullDebrief()];

    await pumpRoute(tester, '/debrief');
    final AppLocalizations l10n = copy(tester);

    await tester.ensureVisible(find.text(l10n.debriefShareButton));
    await tester.tap(find.text(l10n.debriefShareButton));
    await tester.pumpAndSettle();

    expect(find.text(l10n.debriefShareDialogTitle), findsOneWidget);
    expect(share.shared, isEmpty);
    expect(api.shareCalls, 0);

    await tester.tap(
      find.widgetWithText(DrButton, l10n.debriefShareConfirm),
    );
    await tester.pumpAndSettle();

    expect(api.shareCalls, 1);
    expect(share.shared, hasLength(1));
    expect(share.shared.single, contains('#report=rep_'));
  });

  testWidgets('delete needs confirmation then removes the session',
      (WidgetTester tester) async {
    container = buildContainer(
      appOverrides(
        api: api,
        tokens: const InitialTokens(inviteToken: 'inv_test'),
      ),
    );
    container.read(tokenStoreProvider.notifier).setSession(
          sessionId: 'ses_test',
          sessionToken: 'tok_test',
        );
    api.debriefs = <DebriefResponse>[fullDebrief()];

    await pumpRoute(tester, '/debrief');
    final AppLocalizations l10n = copy(tester);

    await tester.ensureVisible(find.text(l10n.debriefDeleteButton));
    await tester.tap(find.text(l10n.debriefDeleteButton));
    await tester.pumpAndSettle();

    expect(find.text(l10n.debriefDeleteDialogTitle), findsOneWidget);
    expect(api.deleteCalls, 0);

    await tester.tap(
      find.widgetWithText(DrButton, l10n.debriefDeleteConfirm),
    );
    await tester.pumpAndSettle();

    expect(api.deleteCalls, 1);
    expect(container.read(tokenStoreProvider).hasSession, isFalse);
    expect(find.text(l10n.debriefDeletedTitle), findsOneWidget);
  });

  testWidgets('cancelling the delete dialog keeps the session',
      (WidgetTester tester) async {
    container = buildContainer(
      appOverrides(
        api: api,
        tokens: const InitialTokens(inviteToken: 'inv_test'),
      ),
    );
    container.read(tokenStoreProvider.notifier).setSession(
          sessionId: 'ses_test',
          sessionToken: 'tok_test',
        );
    api.debriefs = <DebriefResponse>[fullDebrief()];

    await pumpRoute(tester, '/debrief');
    final AppLocalizations l10n = copy(tester);

    await tester.ensureVisible(find.text(l10n.debriefDeleteButton));
    await tester.tap(find.text(l10n.debriefDeleteButton));
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(DrButton, l10n.debriefDeleteCancel),
    );
    await tester.pumpAndSettle();

    expect(api.deleteCalls, 0);
    expect(container.read(tokenStoreProvider).hasSession, isTrue);
    expect(find.text(l10n.debriefDeleteDialogTitle), findsNothing);
  });

  testWidgets('a broken report link shows the gone state, never a session id',
      (WidgetTester tester) async {
    api.reportError = ApiException(
      message: 'Invalid report token.',
      statusCode: 401,
      code: ProblemCode.invalidToken,
    );
    container = buildContainer(
      appOverrides(
        api: api,
        tokens: const InitialTokens(reportToken: 'rep_missing'),
      ),
    );

    await pumpRoute(tester, '/report', size: const Size(900, 1200));

    final AppLocalizations l10n = copy(tester);
    expect(find.byType(ReportScreen), findsOneWidget);
    expect(find.text(l10n.reportGoneTitle), findsOneWidget);
    expect(find.textContaining('ses_'), findsNothing);
  });

  testWidgets('a shared report renders read-only content', (WidgetTester tester) async {
    container = buildContainer(
      appOverrides(
        api: api,
        tokens: const InitialTokens(reportToken: 'rep_test'),
      ),
    );

    await pumpRoute(tester, '/report', size: const Size(900, 1400));

    final AppLocalizations l10n = copy(tester);
    expect(find.text(l10n.reportTitle), findsOneWidget);
    expect(find.text(l10n.reportIntro), findsOneWidget);
    expect(find.text(l10n.habitHangUpTitle), findsOneWidget);
    expect(find.text(l10n.debriefShareButton), findsNothing);
    expect(find.text(l10n.debriefDeleteButton), findsNothing);
  });
}

/// Type-agnostic finder: every product control is a [DrButton].
class _BlockingTurnApi extends FakeApi {
  final Completer<TurnResponse> gate = Completer<TurnResponse>();

  @override
  Future<TurnResponse> submitTurn({
    required String sessionId,
    required String sessionToken,
    required String text,
    required int expectedTurnIndex,
    String? turnId,
  }) {
    submittedTurns.add(
      RecordedTurn(
        turnId: turnId,
        expectedTurnIndex: expectedTurnIndex,
        text: text,
      ),
    );
    return gate.future;
  }
}
