import 'dart:async';

import 'package:api_client/api_client.dart';
import 'package:dryrun/core/app_config.dart';
import 'package:dryrun/design/components/dr_button.dart';
import 'package:dryrun/features/debrief/debrief_screen.dart';
import 'package:dryrun/features/demo/demo_mode.dart';
import 'package:dryrun/features/session/session_controller.dart';
import 'package:dryrun/features/voice/voice_controller.dart';
import 'package:dryrun/l10n/app_localizations.dart';
import 'package:dryrun/state/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_test_support.dart';
import '../support/voice_test_support.dart';

final AppConfig _demoConfig = AppConfig(
  apiBaseUrl: Uri(scheme: 'http', host: '127.0.0.1', port: 8000),
  publicWebUrl: Uri(scheme: 'http', host: '127.0.0.1', port: 8080),
  demoMode: true,
);

void main() {
  late FakeApi api;
  late FakeVoiceService voice;
  late ProviderContainer container;

  AppLocalizations copy(WidgetTester tester) => AppLocalizations.of(
        tester.element(find.byType(Scaffold).first),
      );

  Future<void> pumpRoute(
    WidgetTester tester,
    String route, {
    Size size = const Size(900, 1600),
  }) async {
    setTestView(tester, size: size);
    await tester.pumpWidget(
      testRouterApp(initialLocation: route, container: container),
    );
    await tester.pumpAndSettle();
  }

  void adoptSession() {
    final SessionCreateResponse session = contractModel(
      'session_create_response_valid',
      SessionCreateResponse.fromJson,
    );
    container.read(sessionControllerProvider.notifier).adopt(session);
  }

  List<Override> overrides({
    VoicePolicy policy = const VoicePolicy(
      listenTimeout: Duration(milliseconds: 200),
      replyTimeout: Duration(seconds: 1),
      fillerDelay: Duration.zero,
    ),
  }) {
    return <Override>[
      ...appOverrides(api: api),
      voiceServiceProvider.overrideWithValue(voice),
      voicePolicyProvider.overrideWithValue(policy),
    ];
  }

  Future<void> openDrill(WidgetTester tester) async {
    container = buildContainer(overrides());
    adoptSession();
    await pumpRoute(tester, '/drill', size: const Size(900, 1000));
  }

  Future<void> enableVoice(WidgetTester tester) async {
    final AppLocalizations l10n = copy(tester);
    await tester.tap(find.widgetWithText(DrButton, l10n.voiceUse));
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(DrButton, l10n.voiceDisclosureConfirm),
    );
    await tester.pumpAndSettle();
  }

  setUp(() {
    api = FakeApi();
    voice = FakeVoiceService();
  });

  testWidgets('disclosure comes before any microphone request',
      (WidgetTester tester) async {
    await openDrill(tester);
    final AppLocalizations l10n = copy(tester);

    expect(voice.permissionChecks, 0);
    expect(voice.permissionRequests, 0);

    await tester.tap(find.widgetWithText(DrButton, l10n.voiceUse));
    await tester.pumpAndSettle();

    expect(find.text(l10n.voiceDisclosureTitle), findsOneWidget);
    expect(find.text(l10n.voiceDisclosureBody), findsOneWidget);
    expect(voice.permissionChecks, 0);
    expect(voice.permissionRequests, 0);

    await tester.tap(
      find.widgetWithText(DrButton, l10n.voiceDisclosureCancel),
    );
    await tester.pumpAndSettle();

    expect(find.text(l10n.voiceDisclosureTitle), findsNothing);
    expect(voice.permissionChecks, 0);
    expect(voice.permissionRequests, 0);

    await enableVoice(tester);

    expect(voice.permissionRequests, 1);
    expect(find.text(l10n.voiceReady), findsOneWidget);
  });

  testWidgets('denied microphone stays in chat with calm copy',
      (WidgetTester tester) async {
    voice.grantOnRequest = false;
    await openDrill(tester);
    final AppLocalizations l10n = copy(tester);

    await enableVoice(tester);

    expect(voice.permissionRequests, 1);
    expect(find.text(l10n.voiceProblemPermission), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.widgetWithText(DrButton, l10n.drillEnd), findsOneWidget);
    expect(find.widgetWithText(DrButton, l10n.voiceUse), findsOneWidget);
  });

  testWidgets('missing recognizer keeps chat usable',
      (WidgetTester tester) async {
    voice.recognizerAvailable = false;
    await openDrill(tester);
    final AppLocalizations l10n = copy(tester);

    await enableVoice(tester);

    expect(find.text(l10n.voiceProblemRecognizer), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.widgetWithText(DrButton, l10n.drillEnd), findsOneWidget);
  });

  testWidgets('missing Hindi recognizer uses the Hindi copy',
      (WidgetTester tester) async {
    voice.recognitionLocales = <String>{'en-IN'};
    container = buildContainer(overrides());
    container.read(sessionLanguageProvider.notifier).state = AppLanguage.hi;
    adoptSession();
    await pumpRoute(tester, '/drill', size: const Size(900, 1000));
    final AppLocalizations l10n = copy(tester);

    await enableVoice(tester);

    expect(find.text(l10n.voiceProblemLanguage), findsOneWidget);
    expect(voice.listenLocales, isEmpty);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('an empty recognition result asks the participant to type',
      (WidgetTester tester) async {
    await openDrill(tester);
    final AppLocalizations l10n = copy(tester);
    await enableVoice(tester);

    voice.transcripts = <String?>[null];
    await tester.tap(find.widgetWithText(DrButton, l10n.voiceSpeak));
    await tester.pumpAndSettle();

    expect(find.text(l10n.voiceProblemListen), findsOneWidget);
    expect(find.text(l10n.voiceKeepTyping), findsOneWidget);
    expect(api.submittedTurns, isEmpty);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('a slow reply falls back to chat and never blocks End drill',
      (WidgetTester tester) async {
    final Completer<void> gate = Completer<void>();
    api.turnGate = gate;
    api.turns = <TurnResponse>[
      contractModel('turn_response_valid', TurnResponse.fromJson),
    ];
    container = buildContainer(
      overrides(
        policy: const VoicePolicy(
          listenTimeout: Duration(milliseconds: 100),
          replyTimeout: Duration(milliseconds: 40),
          fillerDelay: Duration.zero,
        ),
      ),
    );
    adoptSession();
    await pumpRoute(tester, '/drill', size: const Size(900, 1000));
    final AppLocalizations l10n = copy(tester);
    await enableVoice(tester);

    voice.transcripts = <String?>['I will not pay anything.'];
    await tester.tap(find.widgetWithText(DrButton, l10n.voiceSpeak));
    await tester.pump(const Duration(milliseconds: 80));
    await tester.pumpAndSettle();

    expect(find.text(l10n.voiceProblemTimeout), findsOneWidget);
    expect(api.submittedTurns, hasLength(1));

    // Release the pending request so the test leaves no work running.
    gate.complete();
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(DrButton, l10n.drillEnd));
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(DrButton, l10n.drillEndConfirmButton),
    );
    await tester.pumpAndSettle();
    expect(find.byType(DebriefScreen), findsOneWidget);
  });

  testWidgets('End drill stops listening immediately',
      (WidgetTester tester) async {
    api.debriefs = <DebriefResponse>[fullDebrief()];
    final Completer<String?> listen = Completer<String?>();
    voice.listenGate = listen;
    await openDrill(tester);
    final AppLocalizations l10n = copy(tester);
    await enableVoice(tester);

    await tester.tap(find.widgetWithText(DrButton, l10n.voiceSpeak));
    await tester.pump();
    expect(find.text(l10n.voiceListening), findsOneWidget);

    await tester.tap(find.widgetWithText(DrButton, l10n.drillEnd));
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(DrButton, l10n.drillEndConfirmButton),
    );
    await tester.pumpAndSettle();

    expect(find.byType(DebriefScreen), findsOneWidget);
    expect(voice.stopListeningCalls, greaterThanOrEqualTo(1));
  });

  testWidgets('a phone voice failure drops to chat without hiding it',
      (WidgetTester tester) async {
    api.turns = <TurnResponse>[
      contractModel('turn_response_valid', TurnResponse.fromJson),
    ];
    voice.speakError = StateError('no voice engine');
    await openDrill(tester);
    final AppLocalizations l10n = copy(tester);
    await enableVoice(tester);

    voice.transcripts = <String?>['I am not alone. I will call my son.'];
    await tester.tap(find.widgetWithText(DrButton, l10n.voiceSpeak));
    await tester.pumpAndSettle();

    expect(find.text(l10n.voiceProblemSpeech), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.widgetWithText(DrButton, l10n.voiceUse), findsOneWidget);
  });

  testWidgets('voice check reports a clear pass', (WidgetTester tester) async {
    container = buildContainer(overrides());
    await pumpRoute(tester, '/voice', size: const Size(900, 1600));
    final AppLocalizations l10n = copy(tester);

    expect(find.text(l10n.voiceCheckTitle), findsOneWidget);
    expect(find.text(l10n.voiceCheckPending), findsWidgets);
    expect(find.text(l10n.voiceCheckPass), findsNothing);
    expect(voice.permissionRequests, 0);

    await tester.tap(
      find.widgetWithText(DrButton, l10n.voiceCheckStart).first,
    );
    await tester.pumpAndSettle();
    expect(find.text(l10n.voiceCheckMicrophoneOn), findsOneWidget);

    voice.transcripts = <String?>['hello there', 'नमस्ते'];
    await tester.tap(
      find.widgetWithText(
        DrButton,
        l10n.voiceCheckLanguageTest(l10n.languageEnglish),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(
        DrButton,
        l10n.voiceCheckLanguageTest(l10n.languageHindi),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(l10n.voiceCheckHeard('hello there')), findsOneWidget);

    await tester.tap(
      find.widgetWithText(
        DrButton,
        l10n.voiceCheckTtsTest(l10n.languageEnglish),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(
        DrButton,
        l10n.voiceCheckTtsTest(l10n.languageHindi),
      ),
    );
    await tester.pumpAndSettle();

    voice.transcripts = <String?>['ready'];
    await tester.tap(
      find.widgetWithText(DrButton, l10n.voiceCheckRoundTripTest),
    );
    await tester.pumpAndSettle();

    expect(find.text(l10n.voiceCheckPass), findsOneWidget);
    expect(find.text(l10n.voiceCheckFail), findsNothing);
  });

  testWidgets('voice check reports a clear fail when the microphone is off',
      (WidgetTester tester) async {
    voice.grantOnRequest = false;
    container = buildContainer(overrides());
    await pumpRoute(tester, '/voice', size: const Size(900, 1600));
    final AppLocalizations l10n = copy(tester);

    await tester.tap(
      find.widgetWithText(DrButton, l10n.voiceCheckStart).first,
    );
    await tester.pumpAndSettle();

    expect(find.text(l10n.voiceCheckFail), findsOneWidget);
    expect(find.text(l10n.voiceCheckMicrophoneOff), findsOneWidget);
    expect(find.text(l10n.voiceCheckPass), findsNothing);
  });

  testWidgets('demo mode shows the fixed transcript and canned debrief offline',
      (WidgetTester tester) async {
    container = buildContainer(<Override>[
      ...appOverrides(api: api),
      ...demoOverrides(),
      appConfigProvider.overrideWithValue(_demoConfig),
    ]);
    await pumpRoute(tester, '/drill', size: const Size(900, 1000));
    final AppLocalizations l10n = copy(tester);

    expect(find.text(l10n.demoBadge), findsOneWidget);
    expect(find.text(l10n.demoBanner), findsOneWidget);
    expect(
      find.textContaining('This is a recorded walkthrough'),
      findsOneWidget,
    );
    expect(find.text('I did not send any parcel.'), findsOneWidget);
    expect(find.text(l10n.drillEnded), findsOneWidget);

    expect(api.createdSessions, isEmpty);
    expect(api.submittedTurns, isEmpty);
    expect(api.debriefCalls, 0);

    await tester.tap(find.widgetWithText(DrButton, l10n.drillGoToDebrief));
    await tester.pumpAndSettle();

    expect(find.text(l10n.debriefTitle), findsOneWidget);
    expect(find.text(l10n.didWellRefusedMoneyTransfer), findsOneWidget);
    expect(api.debriefCalls, 0);
  });
}
