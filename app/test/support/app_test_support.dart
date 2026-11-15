import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:api_client/api_client.dart';
import 'package:dryrun/core/share_service.dart';
import 'package:dryrun/design/dr_theme.dart';
import 'package:dryrun/l10n/app_localizations.dart';
import 'package:dryrun/routing/app_router.dart';
import 'package:dryrun/state/providers.dart';
import 'package:dryrun/state/token_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Reads a reviewed contract fixture. Tests run with the app directory as the
/// working directory, so the repository fixtures are one level up.
Map<String, dynamic> contractExample(String name) {
  final List<String> candidates = <String>[
    '../contracts/examples/$name.json',
    'contracts/examples/$name.json',
  ];
  for (final String path in candidates) {
    final File file = File(path);
    if (file.existsSync()) {
      return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    }
  }
  throw StateError('Missing contract fixture $name.json');
}

T contractModel<T>(
  String name,
  T Function(Map<String, dynamic>) parse,
) =>
    parse(contractExample(name));

DebriefResponse quickDebrief({bool lowConfidence = false}) {
  final DebriefResponse base = contractModel(
    lowConfidence
        ? 'debrief_response_low_confidence_valid'
        : 'debrief_response_quick_valid',
    DebriefResponse.fromJson,
  );
  return base;
}

DebriefResponse fullDebrief() =>
    contractModel('debrief_response_full_valid', DebriefResponse.fromJson);

class RecordedTurn {
  RecordedTurn({
    required this.turnId,
    required this.expectedTurnIndex,
    required this.text,
  });

  final String? turnId;
  final int expectedTurnIndex;
  final String text;
}

class RecordedSession {
  RecordedSession({
    required this.inviteToken,
    required this.consent,
    required this.statsOptIn,
  });

  final String inviteToken;
  final bool consent;
  final bool statsOptIn;
}

/// Scriptable fake covering every operation the app calls. Tests assign the
/// responses they need and inspect the recorded calls afterwards.
class FakeApi implements DryRunApi {
  FakeApi({
    InviteResponse? invite,
    CurrentInviteResponse? currentInvite,
    SessionCreateResponse? session,
    List<TurnResponse>? turns,
    List<DebriefResponse>? debriefs,
    ShareResponse? share,
    ReportResponse? report,
    ConfigResponse? config,
    ScenarioGraphResponse? graph,
  })  : invite = invite ??
            contractModel('invite_response_valid', InviteResponse.fromJson),
        currentInvite = currentInvite ??
            contractModel(
              'current_invite_response_valid',
              CurrentInviteResponse.fromJson,
            ),
        session = session ??
            contractModel(
              'session_create_response_valid',
              SessionCreateResponse.fromJson,
            ),
        turns = turns ?? <TurnResponse>[],
        debriefs = debriefs ?? <DebriefResponse>[],
        share = share ??
            contractModel('share_response_valid', ShareResponse.fromJson),
        report = report ??
            contractModel('report_response_valid', ReportResponse.fromJson),
        config = config ??
            contractModel('config_response_valid', ConfigResponse.fromJson),
        graph = graph ??
            contractModel(
              'scenario_graph_valid',
              ScenarioGraphResponse.fromJson,
            );

  InviteResponse invite;
  CurrentInviteResponse currentInvite;
  SessionCreateResponse session;
  List<TurnResponse> turns;
  List<DebriefResponse> debriefs;
  ShareResponse share;
  ReportResponse report;
  ConfigResponse config;
  ScenarioGraphResponse graph;

  Object? turnError;
  Object? shareError;
  Object? deleteError;
  Object? debriefError;
  Object? reportError;

  /// Held open to simulate a reply that never arrives. Tests complete it to
  /// release the request.
  Completer<void>? turnGate;

  /// Artificial delay before a turn response resolves.
  Duration? turnDelay;

  final List<RecordedTurn> submittedTurns = <RecordedTurn>[];
  final List<RecordedSession> createdSessions = <RecordedSession>[];
  int debriefCalls = 0;
  int deleteCalls = 0;
  int shareCalls = 0;

  @override
  Future<bool> healthCheck() async => true;

  @override
  Future<ConfigResponse> getConfig() async => config;

  @override
  Future<ScenarioGraphResponse> getScenarioGraph() async => graph;

  @override
  Future<InviteResponse> createInvite({
    required AppLanguage language,
    String? cohort,
  }) async =>
      invite;

  @override
  Future<CurrentInviteResponse> getCurrentInvite(String inviteToken) async =>
      currentInvite;

  @override
  Future<SessionCreateResponse> createSession({
    required String inviteToken,
    required bool consent,
    required bool statsOptIn,
    SessionMode mode = SessionMode.chat,
  }) async {
    createdSessions.add(
      RecordedSession(
        inviteToken: inviteToken,
        consent: consent,
        statsOptIn: statsOptIn,
      ),
    );
    return session;
  }

  @override
  Future<TurnResponse> submitTurn({
    required String sessionId,
    required String sessionToken,
    required String text,
    required int expectedTurnIndex,
    String? turnId,
  }) async {
    submittedTurns.add(
      RecordedTurn(
        turnId: turnId,
        expectedTurnIndex: expectedTurnIndex,
        text: text,
      ),
    );
    final Completer<void>? gate = turnGate;
    if (gate != null) {
      await gate.future;
    }
    final Duration? delay = turnDelay;
    if (delay != null) {
      await Future<void>.delayed(delay);
    }
    final Object? failure = turnError;
    if (failure != null) {
      turnError = null;
      throw failure;
    }
    if (turns.isEmpty) {
      throw ApiException(message: 'No scripted turn left.');
    }
    return turns.removeAt(0);
  }

  @override
  Future<EndResponse> endSession({
    required String sessionId,
    required String sessionToken,
    EndReason reason = EndReason.participantEnded,
  }) async =>
      EndResponse(status: EndedStatus.ended, reason: 'participant_ended');

  @override
  Future<DebriefResponse> getDebrief({
    required String sessionId,
    required String sessionToken,
  }) async {
    debriefCalls += 1;
    final Object? failure = debriefError;
    if (failure != null) {
      debriefError = null;
      throw failure;
    }
    if (debriefs.isEmpty) {
      return quickDebrief();
    }
    if (debriefs.length == 1) {
      return debriefs.first;
    }
    return debriefs.removeAt(0);
  }

  @override
  Future<ShareResponse> shareSession({
    required String sessionId,
    required String sessionToken,
    required bool consent,
  }) async {
    shareCalls += 1;
    final Object? failure = shareError;
    if (failure != null) {
      throw failure;
    }
    return share;
  }

  @override
  Future<void> deleteSession({
    required String sessionId,
    required String sessionToken,
  }) async {
    deleteCalls += 1;
    final Object? failure = deleteError;
    if (failure != null) {
      throw failure;
    }
  }

  @override
  Future<ReportResponse> getReport(String reportToken) async {
    final Object? failure = reportError;
    if (failure != null) {
      throw failure;
    }
    return report;
  }
}

class RecordingShare implements ShareService {
  final List<String> shared = <String>[];
  final List<String> copied = <String>[];
  bool failShare = false;

  @override
  Future<void> share({required String text, required String subject}) async {
    if (failShare) {
      throw StateError('No share sheet on this platform.');
    }
    shared.add(text);
  }

  @override
  Future<void> copy(String text) async {
    copied.add(text);
  }
}

/// Provider overrides every widget test shares.
List<Override> appOverrides({
  required FakeApi api,
  InitialTokens tokens = InitialTokens.none,
  RecordingShare? share,
}) {
  return <Override>[
    apiProvider.overrideWithValue(api),
    initialTokensProvider.overrideWithValue(tokens),
    shareServiceProvider.overrideWithValue(share ?? RecordingShare()),
    pollDelayProvider.overrideWithValue((Duration duration) async {}),
    turnIdProvider.overrideWithValue(() => 'turn-fixed-id'),
  ];
}

/// Router based harness so screens can navigate for real during a test.
Widget testRouterApp({
  required String initialLocation,
  required ProviderContainer container,
  Brightness brightness = Brightness.light,
  Locale locale = const Locale('en'),
  double textScale = 1,
}) {
  final GoRouter router = createAppRouter(initialLocation: initialLocation);
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: drThemeData(
        brightness: brightness,
        devanagari: locale.languageCode == 'hi',
      ),
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    ),
  );
}

/// Builds the container before pumping so a test can adopt a session first.
ProviderContainer buildContainer(List<Override> overrides) {
  final ProviderContainer container = ProviderContainer(overrides: overrides);
  addTearDown(container.dispose);
  return container;
}

/// Sets a fixed physical size for a widget or golden test.
void setTestView(
  WidgetTester tester, {
  required Size size,
  double pixelRatio = 1,
}) {
  tester.view.devicePixelRatio = pixelRatio;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
