import 'package:api_client/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/providers.dart';
import 'drill_models.dart';

final StateNotifierProvider<SessionController, DrillState> sessionControllerProvider =
    StateNotifierProvider<SessionController, DrillState>(
  (Ref ref) => SessionController(ref),
);

/// Owns the live drill conversation. Widgets call this controller and render
/// its state. No request or retry logic lives in a widget.
class SessionController extends StateNotifier<DrillState> {
  SessionController(this._ref) : super(const DrillState());

  final Ref _ref;

  void adopt(SessionCreateResponse response) {
    final TurnResponse first = response.firstTurn;
    final List<ChatMessage> messages = <ChatMessage>[
      if (first.officerLine != null)
        ChatMessage(
          speaker: ChatSpeaker.officer,
          text: first.officerLine!.display,
          turnIndex: first.turnIndex,
        ),
    ];
    state = DrillState(
      session: response,
      messages: messages,
      expectedTurnIndex: first.turnIndex + 1,
      lastTurn: first,
      ended: first.status == TurnStatus.ended,
    );
  }

  Future<bool> send(String raw) async {
    final String text = raw.trim();
    if (text.isEmpty ||
        state.sending ||
        state.ending ||
        state.ended ||
        state.session == null) {
      return false;
    }
    if (state.pending != null) {
      return false;
    }
    final PendingTurn pending = PendingTurn(
      turnId: _ref.read(turnIdProvider)(),
      text: text,
      expectedTurnIndex: state.expectedTurnIndex,
    );
    state = state.copyWith(
      pending: pending,
      sending: true,
      error: null,
      messages: <ChatMessage>[
        ...state.messages,
        ChatMessage(
          speaker: ChatSpeaker.participant,
          text: text,
          turnIndex: pending.expectedTurnIndex,
        ),
      ],
    );
    return _submit(pending);
  }

  Future<bool> retry() async {
    final PendingTurn? pending = state.pending;
    if (pending == null || state.sending || state.session == null) {
      return false;
    }
    state = state.copyWith(sending: true, error: null);
    return _submit(pending);
  }

  Future<bool> _submit(PendingTurn pending) async {
    final SessionCreateResponse session = state.session!;
    try {
      final TurnResponse response = await _ref.read(apiProvider).submitTurn(
            sessionId: session.sessionId,
            sessionToken: session.sessionToken,
            text: pending.text,
            expectedTurnIndex: pending.expectedTurnIndex,
            turnId: pending.turnId,
          );
      _apply(response);
      return true;
    } on Object catch (error) {
      state = state.copyWith(sending: false, error: error);
      return false;
    }
  }

  void _apply(TurnResponse response) {
    state = state.copyWith(
      messages: <ChatMessage>[
        ...state.messages,
        if (response.officerLine != null)
          ChatMessage(
            speaker: ChatSpeaker.officer,
            text: response.officerLine!.display,
            turnIndex: response.turnIndex,
          ),
      ],
      expectedTurnIndex: response.turnIndex + 1,
      lastTurn: response,
      pending: null,
      sending: false,
      ended: response.status == TurnStatus.ended,
      error: null,
    );
  }

  Future<bool> end() async {
    final SessionCreateResponse? session = state.session;
    if (session == null || state.ending || state.ended) {
      return false;
    }
    state = state.copyWith(ending: true, error: null);
    try {
      await _ref.read(apiProvider).endSession(
            sessionId: session.sessionId,
            sessionToken: session.sessionToken,
          );
      state = state.copyWith(ending: false, ended: true, error: null);
      return true;
    } on Object catch (error) {
      state = state.copyWith(ending: false, error: error);
      return false;
    }
  }

  void reset() {
    state = const DrillState();
  }
}
