import 'dart:convert';

/// Officer dialogue line
class OfficerLine {
  final String display;
  final String speak;
  final String language;

  const OfficerLine({
    required this.display,
    required this.speak,
    required this.language,
  });

  factory OfficerLine.fromJson(Map<String, dynamic> json) {
    return OfficerLine(
      display: json['display'] as String,
      speak: json['speak'] as String,
      language: json['language'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'display': display,
        'speak': speak,
        'language': language,
      };
}

/// Turn response from the engine
class TurnResponse {
  final OfficerLine? officerLine;
  final String stageId;
  final int pressure;
  final String status;
  final String? endReason;
  final int turnIndex;
  final bool fallbackUsed;
  final bool piiWarning;

  const TurnResponse({
    this.officerLine,
    required this.stageId,
    required this.pressure,
    required this.status,
    this.endReason,
    required this.turnIndex,
    required this.fallbackUsed,
    required this.piiWarning,
  });

  factory TurnResponse.fromJson(Map<String, dynamic> json) {
    return TurnResponse(
      officerLine: json['officer_line'] != null
          ? OfficerLine.fromJson(json['officer_line'] as Map<String, dynamic>)
          : null,
      stageId: json['stage_id'] as String,
      pressure: json['pressure'] as int,
      status: json['status'] as String,
      endReason: json['end_reason'] as String?,
      turnIndex: json['turn_index'] as int,
      fallbackUsed: json['fallback_used'] as bool,
      piiWarning: json['pii_warning'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
        'officer_line': officerLine?.toJson(),
        'stage_id': stageId,
        'pressure': pressure,
        'status': status,
        if (endReason != null) 'end_reason': endReason,
        'turn_index': turnIndex,
        'fallback_used': fallbackUsed,
        'pii_warning': piiWarning,
      };
}

/// Quote substring reference
class QuoteReference {
  final String text;
  final int start;
  final int end;

  const QuoteReference({
    required this.text,
    required this.start,
    required this.end,
  });

  factory QuoteReference.fromJson(Map<String, dynamic> json) {
    return QuoteReference(
      text: json['text'] as String,
      start: json['start'] as int,
      end: json['end'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'text': text,
        'start': start,
        'end': end,
      };
}

/// Debrief event item
class DebriefEvent {
  final int turnIndex;
  final String label;
  final double confidence;
  final QuoteReference? quote;

  const DebriefEvent({
    required this.turnIndex,
    required this.label,
    required this.confidence,
    this.quote,
  });

  factory DebriefEvent.fromJson(Map<String, dynamic> json) {
    return DebriefEvent(
      turnIndex: json['turn_index'] as int,
      label: json['label'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      quote: json['quote'] != null
          ? QuoteReference.fromJson(json['quote'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'turn_index': turnIndex,
        'label': label,
        'confidence': confidence,
        'quote': quote?.toJson(),
      };
}

/// State transition step
class StatePathStep {
  final String stageId;
  final int turnIndex;

  const StatePathStep({
    required this.stageId,
    required this.turnIndex,
  });

  factory StatePathStep.fromJson(Map<String, dynamic> json) {
    return StatePathStep(
      stageId: json['stage_id'] as String,
      turnIndex: json['turn_index'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'stage_id': stageId,
        'turn_index': turnIndex,
      };
}

/// First compliance marker
class FirstCompliance {
  final int turnIndex;
  final String stageId;
  final String label;

  const FirstCompliance({
    required this.turnIndex,
    required this.stageId,
    required this.label,
  });

  factory FirstCompliance.fromJson(Map<String, dynamic> json) {
    return FirstCompliance(
      turnIndex: json['turn_index'] as int,
      stageId: json['stage_id'] as String,
      label: json['label'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'turn_index': turnIndex,
        'stage_id': stageId,
        'label': label,
      };
}

/// Complete debrief model
class Debrief {
  final String quality; // "quick" | "full"
  final bool lowConfidence;
  final List<StatePathStep> statePath;
  final List<DebriefEvent> events;
  final FirstCompliance? firstCompliance;
  final List<String> didWellIds;
  final String habitId;

  const Debrief({
    required this.quality,
    required this.lowConfidence,
    required this.statePath,
    required this.events,
    this.firstCompliance,
    required this.didWellIds,
    required this.habitId,
  });

  factory Debrief.fromJson(Map<String, dynamic> json) {
    return Debrief(
      quality: json['quality'] as String,
      lowConfidence: json['low_confidence'] as bool,
      statePath: (json['state_path'] as List<dynamic>)
          .map((e) => StatePathStep.fromJson(e as Map<String, dynamic>))
          .toList(),
      events: (json['events'] as List<dynamic>)
          .map((e) => DebriefEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      firstCompliance: json['first_compliance'] != null
          ? FirstCompliance.fromJson(
              json['first_compliance'] as Map<String, dynamic>)
          : null,
      didWellIds: (json['did_well_ids'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      habitId: json['habit_id'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'quality': quality,
        'low_confidence': lowConfidence,
        'state_path': statePath.map((e) => e.toJson()).toList(),
        'events': events.map((e) => e.toJson()).toList(),
        'first_compliance': firstCompliance?.toJson(),
        'did_well_ids': didWellIds,
        'habit_id': habitId,
      };
}

/// Problem+JSON error response model
class ProblemDetail {
  final String type;
  final String title;
  final int status;
  final String detail;
  final String code;

  const ProblemDetail({
    required this.type,
    required this.title,
    required this.status,
    required this.detail,
    required this.code,
  });

  factory ProblemDetail.fromJson(Map<String, dynamic> json) {
    return ProblemDetail(
      type: json['type'] as String? ?? 'about:blank',
      title: json['title'] as String,
      status: json['status'] as int,
      detail: json['detail'] as String,
      code: json['code'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'title': title,
        'status': status,
        'detail': detail,
        'code': code,
      };
}
