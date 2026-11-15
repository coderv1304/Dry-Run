import 'package:api_client/api_client.dart';
import 'package:flutter/foundation.dart';

enum ChatSpeaker { officer, participant, system }

@immutable
class ChatMessage {
  const ChatMessage({
    required this.speaker,
    required this.text,
    required this.turnIndex,
  });

  final ChatSpeaker speaker;
  final String text;
  final int turnIndex;
}

/// One logical turn. The id is created once and reused for every retry so a
/// lost response cannot create a duplicate turn.
@immutable
class PendingTurn {
  const PendingTurn({
    required this.turnId,
    required this.text,
    required this.expectedTurnIndex,
  });

  final String turnId;
  final String text;
  final int expectedTurnIndex;
}

const Object _keep = Object();

@immutable
class DrillState {
  const DrillState({
    this.session,
    this.messages = const <ChatMessage>[],
    this.expectedTurnIndex = 0,
    this.lastTurn,
    this.pending,
    this.sending = false,
    this.ending = false,
    this.ended = false,
    this.error,
  });

  final SessionCreateResponse? session;
  final List<ChatMessage> messages;
  final int expectedTurnIndex;
  final TurnResponse? lastTurn;
  final PendingTurn? pending;
  final bool sending;
  final bool ending;
  final bool ended;
  final Object? error;

  bool get hasSession => session != null;

  bool get unauthorized {
    final Object? failure = error;
    return failure is ApiException &&
        (failure.isUnauthorized ||
            failure.code == ProblemCode.tokenExpired);
  }

  DrillState copyWith({
    SessionCreateResponse? session,
    List<ChatMessage>? messages,
    int? expectedTurnIndex,
    TurnResponse? lastTurn,
    Object? pending = _keep,
    bool? sending,
    bool? ending,
    bool? ended,
    Object? error = _keep,
  }) {
    return DrillState(
      session: session ?? this.session,
      messages: messages ?? this.messages,
      expectedTurnIndex: expectedTurnIndex ?? this.expectedTurnIndex,
      lastTurn: lastTurn ?? this.lastTurn,
      pending: identical(pending, _keep) ? this.pending : pending as PendingTurn?,
      sending: sending ?? this.sending,
      ending: ending ?? this.ending,
      ended: ended ?? this.ended,
      error: identical(error, _keep) ? this.error : error,
    );
  }
}
