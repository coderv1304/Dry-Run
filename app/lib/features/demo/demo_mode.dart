import 'package:api_client/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/providers.dart';
import '../../state/token_store.dart';
import '../debrief/debrief_controller.dart';
import '../session/drill_models.dart';
import '../session/session_controller.dart';
import '../voice/voice_controller.dart';
import '../voice/voice_service.dart';

/// Unique demo values make it possible to prove that a production build does
/// not contain any demo code. See tool/check_demo_strings.py.
const String demoSessionId = 'demo-recorded-walkthrough-7f3c';
const String demoSessionToken = 'demo-token-7f3c';
const String demoReportToken = 'demo-report-7f3c';
const String demoTranscriptMarker =
    'This recorded walkthrough is a fixed practice call.';

const List<String> _officerLines = <String>[
  'This is a recorded walkthrough of a practice call. I am playing a cyber cell officer.',
  'A parcel in your name was stopped at the airport. It contained documents that look illegal.',
  'Stay on this call. Do not tell your family, or this becomes a police matter.',
  'To clear your name, transfer the verification amount to this account now.',
  'This recorded walkthrough ends here. In a real call, hang up and use an official number.',
];

const List<String> _participantLines = <String>[
  'I understand. This is practice.',
  'I did not send any parcel.',
  'I will not keep this secret from my family.',
  'I will not transfer money. I will call the official number.',
];

OfficerLine _line(String text, int index) => OfficerLine(
      display: text,
      speak: text,
      language: AppLanguage.en,
    );

TurnResponse _turn({
  required int turnIndex,
  required StageId stage,
  required int pressure,
  String? officer,
  bool ended = false,
}) {
  return TurnResponse(
    officerLine: officer == null
        ? null
        : _line(
            officer,
            turnIndex,
          ),
    stageId: stage,
    pressure: pressure,
    status: ended ? TurnStatus.ended : TurnStatus.active,
    endReason: ended ? EndReason.participantEnded : null,
    turnIndex: turnIndex,
    fallbackUsed: false,
    piiWarning: false,
  );
}

SessionCreateResponse demoSession() {
  final TurnResponse first = _turn(
    turnIndex: 1,
    stage: StageId.contact,
    pressure: 0,
    officer: _officerLines[0],
  );
  return SessionCreateResponse(
    sessionId: demoSessionId,
    sessionToken: demoSessionToken,
    firstTurn: first,
    limits: const SessionLimits(
      maxTurns: 9,
      maxDurationSeconds: 600,
      idleTimeoutSeconds: 300,
    ),
  );
}

DrillState demoDrillState() {
  final List<ChatMessage> messages = <ChatMessage>[
    ChatMessage(speaker: ChatSpeaker.officer, text: _officerLines[0], turnIndex: 1),
    ChatMessage(
      speaker: ChatSpeaker.participant,
      text: _participantLines[0],
      turnIndex: 2,
    ),
    ChatMessage(speaker: ChatSpeaker.officer, text: _officerLines[1], turnIndex: 3),
    ChatMessage(
      speaker: ChatSpeaker.participant,
      text: _participantLines[1],
      turnIndex: 4,
    ),
    ChatMessage(speaker: ChatSpeaker.officer, text: _officerLines[2], turnIndex: 5),
    ChatMessage(
      speaker: ChatSpeaker.participant,
      text: _participantLines[2],
      turnIndex: 6,
    ),
    ChatMessage(speaker: ChatSpeaker.officer, text: _officerLines[3], turnIndex: 7),
    ChatMessage(
      speaker: ChatSpeaker.participant,
      text: _participantLines[3],
      turnIndex: 8,
    ),
    ChatMessage(speaker: ChatSpeaker.officer, text: _officerLines[4], turnIndex: 9),
  ];
  final TurnResponse last = _turn(
    turnIndex: 9,
    stage: StageId.transfer,
    pressure: 2,
    officer: _officerLines[4],
    ended: true,
  );
  return DrillState(
    session: demoSession(),
    messages: messages,
    expectedTurnIndex: 10,
    lastTurn: last,
    ended: true,
  );
}

DebriefContent demoDebriefContent() {
  return const DebriefContent(
    quality: DebriefQuality.full,
    lowConfidence: false,
    statePath: <StatePathItem>[
      StatePathItem(stageId: StageId.contact, turnIndex: 1),
      StatePathItem(stageId: StageId.accusation, turnIndex: 3),
      StatePathItem(stageId: StageId.isolation, turnIndex: 5),
      StatePathItem(stageId: StageId.urgency, turnIndex: 7),
      StatePathItem(stageId: StageId.transfer, turnIndex: 8),
    ],
    events: <DebriefEvent>[
      DebriefEvent(
        turnIndex: 3,
        label: LabelId.p1,
        confidence: 0.91,
        quote: QuoteReference(
          text: 'A parcel in your name was stopped',
          start: 0,
          end: 32,
        ),
      ),
      DebriefEvent(
        turnIndex: 5,
        label: LabelId.p2,
        confidence: 0.88,
        quote: QuoteReference(
          text: 'Do not tell your family',
          start: 0,
          end: 24,
        ),
      ),
      DebriefEvent(
        turnIndex: 7,
        label: LabelId.p3,
        confidence: 0.9,
        quote: QuoteReference(
          text: 'transfer the verification amount',
          start: 0,
          end: 35,
        ),
      ),
    ],
    didWellIds: <String>['refused_money_transfer', 'told_family'],
    habitId: HabitId.callBackOfficial,
  );
}

DebriefResponse demoDebriefResponse() => DebriefResponse(
      status: DebriefStatus.ready,
      quality: DebriefQuality.full,
      debrief: demoDebriefContent(),
    );

ReportResponse demoReportResponse() => ReportResponse(
      reportToken: demoReportToken,
      sharedAt: '2026-01-01T00:00:00Z',
      debrief: demoDebriefContent(),
    );

/// Offline implementation of every API call. It never opens a socket.
class DemoApi implements DryRunApi {
  @override
  Future<bool> healthCheck() async => true;

  @override
  Future<ConfigResponse> getConfig() async => const ConfigResponse(
        flags: ConfigFlags(llmEnabled: false, voiceEnabled: false),
        languages: <String>['en', 'hi', 'hinglish'],
        limits: ConfigLimits(
          maxTurns: 9,
          maxDurationSeconds: 600,
          idleTimeoutSeconds: 300,
          maxRequestBodyBytes: 4096,
          retentionDays: 7,
        ),
      );

  @override
  Future<ScenarioGraphResponse> getScenarioGraph() async => const ScenarioGraphResponse(
        stageIds: <StageId>[
          StageId.contact,
          StageId.accusation,
          StageId.isolation,
          StageId.urgency,
          StageId.transfer,
        ],
        labels: <LabelId>[
          LabelId.p1,
          LabelId.p2,
          LabelId.p3,
          LabelId.p4,
          LabelId.c1,
          LabelId.c2,
          LabelId.c3,
          LabelId.c4,
        ],
      );

  @override
  Future<InviteResponse> createInvite({
    required AppLanguage language,
    String? cohort,
  }) async =>
      const InviteResponse(
        inviteToken: 'demo-invite-7f3c',
        expiresAt: '2026-01-01T00:00:00Z',
      );

  @override
  Future<CurrentInviteResponse> getCurrentInvite(String inviteToken) async =>
      const CurrentInviteResponse(
        language: AppLanguage.en,
        createdAt: '2026-01-01T00:00:00Z',
        expiresAt: '2026-01-01T00:00:00Z',
      );

  @override
  Future<SessionCreateResponse> createSession({
    required String inviteToken,
    required bool consent,
    required bool statsOptIn,
    SessionMode mode = SessionMode.chat,
  }) async =>
      demoSession();

  @override
  Future<TurnResponse> submitTurn({
    required String sessionId,
    required String sessionToken,
    required String text,
    required int expectedTurnIndex,
    String? turnId,
  }) async =>
      _turn(
        turnIndex: expectedTurnIndex,
        stage: StageId.transfer,
        pressure: 2,
        ended: true,
      );

  @override
  Future<EndResponse> endSession({
    required String sessionId,
    required String sessionToken,
    EndReason reason = EndReason.participantEnded,
  }) async =>
      const EndResponse(status: EndedStatus.ended, reason: 'participant_ended');

  @override
  Future<DebriefResponse> getDebrief({
    required String sessionId,
    required String sessionToken,
  }) async =>
      demoDebriefResponse();

  @override
  Future<ShareResponse> shareSession({
    required String sessionId,
    required String sessionToken,
    required bool consent,
  }) async =>
      const ShareResponse(
        reportToken: demoReportToken,
        expiresAt: '2026-01-01T00:00:00Z',
      );

  @override
  Future<void> deleteSession({
    required String sessionId,
    required String sessionToken,
  }) async {}

  @override
  Future<ReportResponse> getReport(String reportToken) async =>
      demoReportResponse();
}

/// Shows the fixed transcript immediately and never calls the network.
class DemoSessionController extends SessionController {
  DemoSessionController(super.ref) {
    state = demoDrillState();
  }

  @override
  void adopt(SessionCreateResponse response) {
    state = demoDrillState();
  }

  @override
  Future<bool> send(String raw) async => false;

  @override
  Future<bool> retry() async => false;

  @override
  Future<bool> end() async {
    state = state.copyWith(ended: true);
    return true;
  }
}

class DemoDebriefController extends DebriefController {
  // The extra field is needed because the base class keeps its Ref private.
  // ignore: use_super_parameters
  DemoDebriefController(Ref ref)
      : _demoRef = ref,
        super(ref) {
    state = DebriefState(response: demoDebriefResponse());
  }

  final Ref _demoRef;

  @override
  Future<void> load() async {}

  @override
  void reset() {
    state = DebriefState(response: demoDebriefResponse());
  }

  @override
  Future<String?> share() async {
    _demoRef.read(tokenStoreProvider.notifier).setReport(demoReportToken);
    final String url =
        _demoRef.read(linkBuilderProvider).report(demoReportToken).toString();
    state = state.copyWith(sharing: false, sharedUrl: url);
    return url;
  }

  @override
  Future<bool> delete() async {
    state = const DebriefState(deleted: true);
    return true;
  }
}

/// Nothing is recorded and no system speech permission is touched in demo.
class DemoVoiceService implements VoiceService {
  @override
  Future<bool> hasMicrophonePermission() async => false;

  @override
  Future<bool> requestMicrophonePermission() async => false;

  @override
  Future<bool> recognitionAvailable() async => false;

  @override
  Future<bool> supportsRecognition(String localeId) async => false;

  @override
  Future<bool> supportsTts(String localeId) async => false;

  @override
  Future<String?> recognizeOnce({
    required String localeId,
    required Duration timeout,
  }) async =>
      null;

  @override
  Future<void> speak({required String text, required String localeId}) async {}

  @override
  Future<void> stopListening() async {}

  @override
  Future<void> stopSpeaking() async {}
}

List<Override> demoOverrides() => <Override>[
      apiProvider.overrideWithValue(DemoApi()),
      sessionControllerProvider.overrideWith(
        (Ref ref) => DemoSessionController(ref),
      ),
      debriefControllerProvider.overrideWith(
        (Ref ref) => DemoDebriefController(ref),
      ),
      voiceServiceProvider.overrideWithValue(DemoVoiceService()),
    ];
