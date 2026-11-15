// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProblemDetailImpl _$$ProblemDetailImplFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    allowedKeys: const ['type', 'title', 'status', 'detail', 'code'],
  );
  return _$ProblemDetailImpl(
    type: json['type'] as String,
    title: json['title'] as String,
    status: (json['status'] as num).toInt(),
    detail: json['detail'] as String,
    code: $enumDecode(_$ProblemCodeEnumMap, json['code']),
  );
}

Map<String, dynamic> _$$ProblemDetailImplToJson(_$ProblemDetailImpl instance) =>
    <String, dynamic>{
      'type': instance.type,
      'title': instance.title,
      'status': instance.status,
      'detail': instance.detail,
      'code': _$ProblemCodeEnumMap[instance.code]!,
    };

const _$ProblemCodeEnumMap = {
  ProblemCode.invalidToken: 'invalid_token',
  ProblemCode.tokenExpired: 'token_expired',
  ProblemCode.sessionLimitReached: 'session_limit_reached',
  ProblemCode.turnIndexMismatch: 'turn_index_mismatch',
  ProblemCode.rateLimited: 'rate_limited',
  ProblemCode.payloadTooLarge: 'payload_too_large',
  ProblemCode.consentRequired: 'consent_required',
  ProblemCode.sessionEnded: 'session_ended',
  ProblemCode.validationError: 'validation_error',
  ProblemCode.internal: 'internal',
};

_$ConfigFlagsImpl _$$ConfigFlagsImplFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    allowedKeys: const ['llm_enabled', 'voice_enabled'],
  );
  return _$ConfigFlagsImpl(
    llmEnabled: json['llm_enabled'] as bool,
    voiceEnabled: json['voice_enabled'] as bool,
  );
}

Map<String, dynamic> _$$ConfigFlagsImplToJson(_$ConfigFlagsImpl instance) =>
    <String, dynamic>{
      'llm_enabled': instance.llmEnabled,
      'voice_enabled': instance.voiceEnabled,
    };

_$ConfigLimitsImpl _$$ConfigLimitsImplFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    allowedKeys: const [
      'max_turns',
      'max_duration_seconds',
      'idle_timeout_seconds',
      'max_request_body_bytes',
      'retention_days'
    ],
  );
  return _$ConfigLimitsImpl(
    maxTurns: (json['max_turns'] as num).toInt(),
    maxDurationSeconds: (json['max_duration_seconds'] as num).toInt(),
    idleTimeoutSeconds: (json['idle_timeout_seconds'] as num).toInt(),
    maxRequestBodyBytes: (json['max_request_body_bytes'] as num).toInt(),
    retentionDays: (json['retention_days'] as num).toInt(),
  );
}

Map<String, dynamic> _$$ConfigLimitsImplToJson(_$ConfigLimitsImpl instance) =>
    <String, dynamic>{
      'max_turns': instance.maxTurns,
      'max_duration_seconds': instance.maxDurationSeconds,
      'idle_timeout_seconds': instance.idleTimeoutSeconds,
      'max_request_body_bytes': instance.maxRequestBodyBytes,
      'retention_days': instance.retentionDays,
    };

_$ConfigResponseImpl _$$ConfigResponseImplFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    allowedKeys: const ['flags', 'languages', 'limits'],
  );
  return _$ConfigResponseImpl(
    flags: ConfigFlags.fromJson(json['flags'] as Map<String, dynamic>),
    languages:
        (json['languages'] as List<dynamic>).map((e) => e as String).toList(),
    limits: ConfigLimits.fromJson(json['limits'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$$ConfigResponseImplToJson(
        _$ConfigResponseImpl instance) =>
    <String, dynamic>{
      'flags': instance.flags.toJson(),
      'languages': instance.languages,
      'limits': instance.limits.toJson(),
    };

_$ScenarioGraphResponseImpl _$$ScenarioGraphResponseImplFromJson(
    Map<String, dynamic> json) {
  $checkKeys(
    json,
    allowedKeys: const ['stage_ids', 'labels'],
  );
  return _$ScenarioGraphResponseImpl(
    stageIds: (json['stage_ids'] as List<dynamic>)
        .map((e) => $enumDecode(_$StageIdEnumMap, e))
        .toList(),
    labels: (json['labels'] as List<dynamic>)
        .map((e) => $enumDecode(_$LabelIdEnumMap, e))
        .toList(),
  );
}

Map<String, dynamic> _$$ScenarioGraphResponseImplToJson(
        _$ScenarioGraphResponseImpl instance) =>
    <String, dynamic>{
      'stage_ids': instance.stageIds.map((e) => _$StageIdEnumMap[e]!).toList(),
      'labels': instance.labels.map((e) => _$LabelIdEnumMap[e]!).toList(),
    };

const _$StageIdEnumMap = {
  StageId.contact: 'contact',
  StageId.accusation: 'accusation',
  StageId.isolation: 'isolation',
  StageId.urgency: 'urgency',
  StageId.transfer: 'transfer',
};

const _$LabelIdEnumMap = {
  LabelId.p1: 'P1',
  LabelId.p2: 'P2',
  LabelId.p3: 'P3',
  LabelId.p4: 'P4',
  LabelId.c1: 'C1',
  LabelId.c2: 'C2',
  LabelId.c3: 'C3',
  LabelId.c4: 'C4',
};

_$InviteCreateRequestImpl _$$InviteCreateRequestImplFromJson(
    Map<String, dynamic> json) {
  $checkKeys(
    json,
    allowedKeys: const ['language', 'cohort'],
  );
  return _$InviteCreateRequestImpl(
    language: $enumDecode(_$AppLanguageEnumMap, json['language']),
    cohort: json['cohort'] as String?,
  );
}

Map<String, dynamic> _$$InviteCreateRequestImplToJson(
        _$InviteCreateRequestImpl instance) =>
    <String, dynamic>{
      'language': _$AppLanguageEnumMap[instance.language]!,
      'cohort': instance.cohort,
    };

const _$AppLanguageEnumMap = {
  AppLanguage.en: 'en',
  AppLanguage.hi: 'hi',
  AppLanguage.hinglish: 'hinglish',
};

_$InviteResponseImpl _$$InviteResponseImplFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    allowedKeys: const ['invite_token', 'expires_at'],
  );
  return _$InviteResponseImpl(
    inviteToken: json['invite_token'] as String,
    expiresAt: json['expires_at'] as String,
  );
}

Map<String, dynamic> _$$InviteResponseImplToJson(
        _$InviteResponseImpl instance) =>
    <String, dynamic>{
      'invite_token': instance.inviteToken,
      'expires_at': instance.expiresAt,
    };

_$CurrentInviteResponseImpl _$$CurrentInviteResponseImplFromJson(
    Map<String, dynamic> json) {
  $checkKeys(
    json,
    allowedKeys: const ['cohort', 'language', 'created_at', 'expires_at'],
  );
  return _$CurrentInviteResponseImpl(
    cohort: json['cohort'] as String?,
    language: $enumDecode(_$AppLanguageEnumMap, json['language']),
    createdAt: json['created_at'] as String,
    expiresAt: json['expires_at'] as String,
  );
}

Map<String, dynamic> _$$CurrentInviteResponseImplToJson(
        _$CurrentInviteResponseImpl instance) =>
    <String, dynamic>{
      'cohort': instance.cohort,
      'language': _$AppLanguageEnumMap[instance.language]!,
      'created_at': instance.createdAt,
      'expires_at': instance.expiresAt,
    };

_$SessionCreateRequestImpl _$$SessionCreateRequestImplFromJson(
    Map<String, dynamic> json) {
  $checkKeys(
    json,
    allowedKeys: const ['consent', 'stats_opt_in', 'mode'],
  );
  return _$SessionCreateRequestImpl(
    consent: json['consent'] as bool,
    statsOptIn: json['stats_opt_in'] as bool? ?? false,
    mode: $enumDecode(_$SessionModeEnumMap, json['mode']),
  );
}

Map<String, dynamic> _$$SessionCreateRequestImplToJson(
        _$SessionCreateRequestImpl instance) =>
    <String, dynamic>{
      'consent': instance.consent,
      'stats_opt_in': instance.statsOptIn,
      'mode': _$SessionModeEnumMap[instance.mode]!,
    };

const _$SessionModeEnumMap = {
  SessionMode.chat: 'chat',
  SessionMode.voice: 'voice',
};

_$OfficerLineImpl _$$OfficerLineImplFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    allowedKeys: const ['display', 'speak', 'language'],
  );
  return _$OfficerLineImpl(
    display: json['display'] as String,
    speak: json['speak'] as String,
    language: $enumDecode(_$AppLanguageEnumMap, json['language']),
  );
}

Map<String, dynamic> _$$OfficerLineImplToJson(_$OfficerLineImpl instance) =>
    <String, dynamic>{
      'display': instance.display,
      'speak': instance.speak,
      'language': _$AppLanguageEnumMap[instance.language]!,
    };

_$TurnResponseImpl _$$TurnResponseImplFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    allowedKeys: const [
      'officer_line',
      'stage_id',
      'pressure',
      'status',
      'end_reason',
      'turn_index',
      'fallback_used',
      'pii_warning'
    ],
  );
  return _$TurnResponseImpl(
    officerLine: json['officer_line'] == null
        ? null
        : OfficerLine.fromJson(json['officer_line'] as Map<String, dynamic>),
    stageId: $enumDecode(_$StageIdEnumMap, json['stage_id']),
    pressure: (json['pressure'] as num).toInt(),
    status: $enumDecode(_$TurnStatusEnumMap, json['status']),
    endReason: $enumDecodeNullable(_$EndReasonEnumMap, json['end_reason']),
    turnIndex: (json['turn_index'] as num).toInt(),
    fallbackUsed: json['fallback_used'] as bool,
    piiWarning: json['pii_warning'] as bool,
  );
}

Map<String, dynamic> _$$TurnResponseImplToJson(_$TurnResponseImpl instance) =>
    <String, dynamic>{
      'officer_line': instance.officerLine?.toJson(),
      'stage_id': _$StageIdEnumMap[instance.stageId]!,
      'pressure': instance.pressure,
      'status': _$TurnStatusEnumMap[instance.status]!,
      'end_reason': _$EndReasonEnumMap[instance.endReason],
      'turn_index': instance.turnIndex,
      'fallback_used': instance.fallbackUsed,
      'pii_warning': instance.piiWarning,
    };

const _$TurnStatusEnumMap = {
  TurnStatus.active: 'active',
  TurnStatus.ended: 'ended',
};

const _$EndReasonEnumMap = {
  EndReason.hungUp: 'hung_up',
  EndReason.verifiedCallback: 'verified_callback',
  EndReason.compliedTransfer: 'complied_transfer',
  EndReason.turnCap: 'turn_cap',
  EndReason.timeout: 'timeout',
  EndReason.participantEnded: 'participant_ended',
};

_$SessionLimitsImpl _$$SessionLimitsImplFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    allowedKeys: const [
      'max_turns',
      'max_duration_seconds',
      'idle_timeout_seconds'
    ],
  );
  return _$SessionLimitsImpl(
    maxTurns: (json['max_turns'] as num).toInt(),
    maxDurationSeconds: (json['max_duration_seconds'] as num).toInt(),
    idleTimeoutSeconds: (json['idle_timeout_seconds'] as num).toInt(),
  );
}

Map<String, dynamic> _$$SessionLimitsImplToJson(_$SessionLimitsImpl instance) =>
    <String, dynamic>{
      'max_turns': instance.maxTurns,
      'max_duration_seconds': instance.maxDurationSeconds,
      'idle_timeout_seconds': instance.idleTimeoutSeconds,
    };

_$SessionCreateResponseImpl _$$SessionCreateResponseImplFromJson(
    Map<String, dynamic> json) {
  $checkKeys(
    json,
    allowedKeys: const ['session_id', 'session_token', 'first_turn', 'limits'],
  );
  return _$SessionCreateResponseImpl(
    sessionId: json['session_id'] as String,
    sessionToken: json['session_token'] as String,
    firstTurn:
        TurnResponse.fromJson(json['first_turn'] as Map<String, dynamic>),
    limits: SessionLimits.fromJson(json['limits'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$$SessionCreateResponseImplToJson(
        _$SessionCreateResponseImpl instance) =>
    <String, dynamic>{
      'session_id': instance.sessionId,
      'session_token': instance.sessionToken,
      'first_turn': instance.firstTurn.toJson(),
      'limits': instance.limits.toJson(),
    };

_$TurnRequestImpl _$$TurnRequestImplFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    allowedKeys: const ['turn_id', 'expected_turn_index', 'text'],
  );
  return _$TurnRequestImpl(
    turnId: json['turn_id'] as String,
    expectedTurnIndex: (json['expected_turn_index'] as num).toInt(),
    text: json['text'] as String,
  );
}

Map<String, dynamic> _$$TurnRequestImplToJson(_$TurnRequestImpl instance) =>
    <String, dynamic>{
      'turn_id': instance.turnId,
      'expected_turn_index': instance.expectedTurnIndex,
      'text': instance.text,
    };

_$SessionEndRequestImpl _$$SessionEndRequestImplFromJson(
    Map<String, dynamic> json) {
  $checkKeys(
    json,
    allowedKeys: const ['reason'],
  );
  return _$SessionEndRequestImpl(
    reason: $enumDecode(_$EndReasonEnumMap, json['reason']),
  );
}

Map<String, dynamic> _$$SessionEndRequestImplToJson(
        _$SessionEndRequestImpl instance) =>
    <String, dynamic>{
      'reason': _$EndReasonEnumMap[instance.reason]!,
    };

_$EndResponseImpl _$$EndResponseImplFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    allowedKeys: const ['status', 'reason'],
  );
  return _$EndResponseImpl(
    status: $enumDecode(_$EndedStatusEnumMap, json['status']),
    reason: json['reason'] as String,
  );
}

Map<String, dynamic> _$$EndResponseImplToJson(_$EndResponseImpl instance) =>
    <String, dynamic>{
      'status': _$EndedStatusEnumMap[instance.status]!,
      'reason': instance.reason,
    };

const _$EndedStatusEnumMap = {
  EndedStatus.ended: 'ended',
};

_$QuoteReferenceImpl _$$QuoteReferenceImplFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    allowedKeys: const ['text', 'start', 'end'],
  );
  return _$QuoteReferenceImpl(
    text: json['text'] as String,
    start: (json['start'] as num).toInt(),
    end: (json['end'] as num).toInt(),
  );
}

Map<String, dynamic> _$$QuoteReferenceImplToJson(
        _$QuoteReferenceImpl instance) =>
    <String, dynamic>{
      'text': instance.text,
      'start': instance.start,
      'end': instance.end,
    };

_$DebriefEventImpl _$$DebriefEventImplFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    allowedKeys: const ['turn_index', 'label', 'confidence', 'quote'],
  );
  return _$DebriefEventImpl(
    turnIndex: (json['turn_index'] as num).toInt(),
    label: $enumDecode(_$LabelIdEnumMap, json['label']),
    confidence: (json['confidence'] as num).toDouble(),
    quote: json['quote'] == null
        ? null
        : QuoteReference.fromJson(json['quote'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$$DebriefEventImplToJson(_$DebriefEventImpl instance) =>
    <String, dynamic>{
      'turn_index': instance.turnIndex,
      'label': _$LabelIdEnumMap[instance.label]!,
      'confidence': instance.confidence,
      'quote': instance.quote?.toJson(),
    };

_$StatePathItemImpl _$$StatePathItemImplFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    allowedKeys: const ['stage_id', 'turn_index'],
  );
  return _$StatePathItemImpl(
    stageId: $enumDecode(_$StageIdEnumMap, json['stage_id']),
    turnIndex: (json['turn_index'] as num).toInt(),
  );
}

Map<String, dynamic> _$$StatePathItemImplToJson(_$StatePathItemImpl instance) =>
    <String, dynamic>{
      'stage_id': _$StageIdEnumMap[instance.stageId]!,
      'turn_index': instance.turnIndex,
    };

_$FirstComplianceImpl _$$FirstComplianceImplFromJson(
    Map<String, dynamic> json) {
  $checkKeys(
    json,
    allowedKeys: const ['turn_index', 'stage_id', 'label'],
  );
  return _$FirstComplianceImpl(
    turnIndex: (json['turn_index'] as num).toInt(),
    stageId: $enumDecode(_$StageIdEnumMap, json['stage_id']),
    label: $enumDecode(_$LabelIdEnumMap, json['label']),
  );
}

Map<String, dynamic> _$$FirstComplianceImplToJson(
        _$FirstComplianceImpl instance) =>
    <String, dynamic>{
      'turn_index': instance.turnIndex,
      'stage_id': _$StageIdEnumMap[instance.stageId]!,
      'label': _$LabelIdEnumMap[instance.label]!,
    };

_$DebriefContentImpl _$$DebriefContentImplFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    allowedKeys: const [
      'quality',
      'low_confidence',
      'state_path',
      'events',
      'first_compliance',
      'did_well_ids',
      'habit_id'
    ],
  );
  return _$DebriefContentImpl(
    quality: $enumDecode(_$DebriefQualityEnumMap, json['quality']),
    lowConfidence: json['low_confidence'] as bool,
    statePath: (json['state_path'] as List<dynamic>)
        .map((e) => StatePathItem.fromJson(e as Map<String, dynamic>))
        .toList(),
    events: (json['events'] as List<dynamic>)
        .map((e) => DebriefEvent.fromJson(e as Map<String, dynamic>))
        .toList(),
    firstCompliance: json['first_compliance'] == null
        ? null
        : FirstCompliance.fromJson(
            json['first_compliance'] as Map<String, dynamic>),
    didWellIds: (json['did_well_ids'] as List<dynamic>)
        .map((e) => e as String)
        .toList(),
    habitId: $enumDecode(_$HabitIdEnumMap, json['habit_id']),
  );
}

Map<String, dynamic> _$$DebriefContentImplToJson(
        _$DebriefContentImpl instance) =>
    <String, dynamic>{
      'quality': _$DebriefQualityEnumMap[instance.quality]!,
      'low_confidence': instance.lowConfidence,
      'state_path': instance.statePath.map((e) => e.toJson()).toList(),
      'events': instance.events.map((e) => e.toJson()).toList(),
      'first_compliance': instance.firstCompliance?.toJson(),
      'did_well_ids': instance.didWellIds,
      'habit_id': _$HabitIdEnumMap[instance.habitId]!,
    };

const _$DebriefQualityEnumMap = {
  DebriefQuality.quick: 'quick',
  DebriefQuality.full: 'full',
};

const _$HabitIdEnumMap = {
  HabitId.hangUp: 'hang_up',
  HabitId.callBackOfficial: 'call_back_official',
  HabitId.tellFamily: 'tell_family',
};

_$DebriefResponseImpl _$$DebriefResponseImplFromJson(
    Map<String, dynamic> json) {
  $checkKeys(
    json,
    allowedKeys: const ['status', 'quality', 'debrief'],
  );
  return _$DebriefResponseImpl(
    status: $enumDecode(_$DebriefStatusEnumMap, json['status']),
    quality: $enumDecode(_$DebriefQualityEnumMap, json['quality']),
    debrief: json['debrief'] == null
        ? null
        : DebriefContent.fromJson(json['debrief'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$$DebriefResponseImplToJson(
        _$DebriefResponseImpl instance) =>
    <String, dynamic>{
      'status': _$DebriefStatusEnumMap[instance.status]!,
      'quality': _$DebriefQualityEnumMap[instance.quality]!,
      'debrief': instance.debrief?.toJson(),
    };

const _$DebriefStatusEnumMap = {
  DebriefStatus.pending: 'pending',
  DebriefStatus.ready: 'ready',
};

_$ShareRequestImpl _$$ShareRequestImplFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    allowedKeys: const ['consent'],
  );
  return _$ShareRequestImpl(
    consent: json['consent'] as bool,
  );
}

Map<String, dynamic> _$$ShareRequestImplToJson(_$ShareRequestImpl instance) =>
    <String, dynamic>{
      'consent': instance.consent,
    };

_$ShareResponseImpl _$$ShareResponseImplFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    allowedKeys: const ['report_token', 'expires_at'],
  );
  return _$ShareResponseImpl(
    reportToken: json['report_token'] as String,
    expiresAt: json['expires_at'] as String,
  );
}

Map<String, dynamic> _$$ShareResponseImplToJson(_$ShareResponseImpl instance) =>
    <String, dynamic>{
      'report_token': instance.reportToken,
      'expires_at': instance.expiresAt,
    };

_$ReportResponseImpl _$$ReportResponseImplFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    allowedKeys: const ['report_token', 'shared_at', 'debrief'],
  );
  return _$ReportResponseImpl(
    reportToken: json['report_token'] as String,
    sharedAt: json['shared_at'] as String,
    debrief: DebriefContent.fromJson(json['debrief'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$$ReportResponseImplToJson(
        _$ReportResponseImpl instance) =>
    <String, dynamic>{
      'report_token': instance.reportToken,
      'shared_at': instance.sharedAt,
      'debrief': instance.debrief.toJson(),
    };
