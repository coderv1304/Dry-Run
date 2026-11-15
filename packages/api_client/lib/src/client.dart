// Pure Dart client for the Dry Run API. No Flutter imports.
//
// Turn submission is idempotent: one UUID is created per logical turn and
// reused for every retry. Timeouts, connection failures and 429 responses
// retry with exponential backoff. A 409 turn_index_mismatch re-syncs to the
// index named by the server and retries the same turn id, so a lost response
// can never create a duplicate turn.

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import 'models.dart';

/// A typed failure returned by the API or by the transport.
class ApiException implements Exception {
  ApiException({
    required this.message,
    this.statusCode,
    this.code,
    this.problem,
    this.retryAfter,
    this.isNetwork = false,
    this.isTimeout = false,
    this.isMalformed = false,
    this.expectedTurnIndex,
    this.cause,
  });

  factory ApiException.network(Object cause) => ApiException(
        message: 'The network request failed.',
        isNetwork: true,
        cause: cause,
      );

  factory ApiException.timeout(Object cause) => ApiException(
        message: 'The network request timed out.',
        isTimeout: true,
        cause: cause,
      );

  factory ApiException.malformed(Object cause) => ApiException(
        message: 'The server response did not match the contract.',
        isMalformed: true,
        cause: cause,
      );

  final String message;
  final int? statusCode;
  final ProblemCode? code;
  final ProblemDetail? problem;
  final Duration? retryAfter;
  final bool isNetwork;
  final bool isTimeout;
  final bool isMalformed;
  final int? expectedTurnIndex;
  final Object? cause;

  bool get isUnauthorized => statusCode == 401 || code == ProblemCode.invalidToken;

  @override
  String toString() {
    final String codeLabel = code?.name ?? statusCode?.toString() ?? 'transport';
    return 'ApiException($codeLabel): $message';
  }
}

/// The operations the app depends on. Tests use a fake implementation.
abstract interface class DryRunApi {
  Future<bool> healthCheck();

  Future<ConfigResponse> getConfig();

  Future<ScenarioGraphResponse> getScenarioGraph();

  Future<InviteResponse> createInvite({
    required AppLanguage language,
    String? cohort,
  });

  Future<CurrentInviteResponse> getCurrentInvite(String inviteToken);

  Future<SessionCreateResponse> createSession({
    required String inviteToken,
    required bool consent,
    required bool statsOptIn,
    SessionMode mode = SessionMode.chat,
  });

  Future<TurnResponse> submitTurn({
    required String sessionId,
    required String sessionToken,
    required String text,
    required int expectedTurnIndex,
    String? turnId,
  });

  Future<EndResponse> endSession({
    required String sessionId,
    required String sessionToken,
    EndReason reason = EndReason.participantEnded,
  });

  Future<DebriefResponse> getDebrief({
    required String sessionId,
    required String sessionToken,
  });

  Future<ShareResponse> shareSession({
    required String sessionId,
    required String sessionToken,
    required bool consent,
  });

  Future<void> deleteSession({
    required String sessionId,
    required String sessionToken,
  });

  Future<ReportResponse> getReport(String reportToken);
}

class DryRunApiClient implements DryRunApi {
  DryRunApiClient({
    required String baseUrl,
    Dio? dio,
    Uuid? uuid,
    Future<void> Function(Duration)? delay,
    this.maxTurnAttempts = 4,
  })  : baseUrl = baseUrl.endsWith('/')
            ? baseUrl.substring(0, baseUrl.length - 1)
            : baseUrl,
        _uuid = uuid ?? const Uuid(),
        _delay = delay ?? Future<void>.delayed,
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl.endsWith('/')
                    ? baseUrl.substring(0, baseUrl.length - 1)
                    : baseUrl,
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 20),
                sendTimeout: const Duration(seconds: 20),
                responseType: ResponseType.json,
                validateStatus: (_) => true,
                headers: const <String, String>{
                  'Accept': 'application/json, application/problem+json',
                  'Content-Type': 'application/json',
                },
              ),
            );

  final String baseUrl;
  final Dio _dio;
  final Uuid _uuid;
  final Future<void> Function(Duration) _delay;
  final int maxTurnAttempts;

  Map<String, String> _headers({
    String? inviteToken,
    String? sessionToken,
    String? reportToken,
  }) {
    return <String, String>{
      if (inviteToken != null) 'X-Invite-Token': inviteToken,
      if (sessionToken != null) 'X-Session-Token': sessionToken,
      if (reportToken != null) 'X-Report-Token': reportToken,
    };
  }

  @override
  Future<bool> healthCheck() async {
    try {
      final Response<dynamic> response = await _dio.get<dynamic>('/healthz');
      return response.statusCode == 200;
    } on DioException {
      return false;
    }
  }

  @override
  Future<ConfigResponse> getConfig() {
    return _get<ConfigResponse>(
      path: '/v1/config',
      parse: ConfigResponse.fromJson,
    );
  }

  @override
  Future<ScenarioGraphResponse> getScenarioGraph() {
    return _get<ScenarioGraphResponse>(
      path: '/v1/scenario/graph',
      parse: ScenarioGraphResponse.fromJson,
    );
  }

  @override
  Future<InviteResponse> createInvite({
    required AppLanguage language,
    String? cohort,
  }) {
    return _post<InviteResponse>(
      path: '/v1/invites',
      body: InviteCreateRequest(language: language, cohort: cohort).toJson(),
      parse: InviteResponse.fromJson,
    );
  }

  @override
  Future<CurrentInviteResponse> getCurrentInvite(String inviteToken) {
    return _get<CurrentInviteResponse>(
      path: '/v1/invites/current',
      headers: _headers(inviteToken: inviteToken),
      parse: CurrentInviteResponse.fromJson,
    );
  }

  @override
  Future<SessionCreateResponse> createSession({
    required String inviteToken,
    required bool consent,
    required bool statsOptIn,
    SessionMode mode = SessionMode.chat,
  }) {
    return _post<SessionCreateResponse>(
      path: '/v1/sessions',
      headers: _headers(inviteToken: inviteToken),
      body: SessionCreateRequest(
        consent: consent,
        statsOptIn: statsOptIn,
        mode: mode,
      ).toJson(),
      parse: SessionCreateResponse.fromJson,
    );
  }

  @override
  Future<TurnResponse> submitTurn({
    required String sessionId,
    required String sessionToken,
    required String text,
    required int expectedTurnIndex,
    String? turnId,
  }) async {
    final String id = turnId ?? _uuid.v4();
    int expected = expectedTurnIndex;
    int attempt = 0;
    int conflicts = 0;

    while (true) {
      attempt += 1;
      try {
        return await _post<TurnResponse>(
          path: '/v1/sessions/$sessionId/turn',
          headers: _headers(sessionToken: sessionToken),
          body: TurnRequest(
            turnId: id,
            expectedTurnIndex: expected,
            text: text,
          ).toJson(),
          parse: TurnResponse.fromJson,
        );
      } on ApiException catch (error) {
        if (error.code == ProblemCode.turnIndexMismatch) {
          final int? corrected = error.expectedTurnIndex;
          if (corrected != null && corrected != expected && conflicts < 3) {
            conflicts += 1;
            expected = corrected;
            continue;
          }
        }
        final bool retryable = error.isNetwork ||
            error.isTimeout ||
            error.code == ProblemCode.rateLimited ||
            error.statusCode == 503;
        if (!retryable || attempt >= maxTurnAttempts) {
          rethrow;
        }
        await _delay(error.retryAfter ?? _backoff(attempt));
      }
    }
  }

  @override
  Future<EndResponse> endSession({
    required String sessionId,
    required String sessionToken,
    EndReason reason = EndReason.participantEnded,
  }) {
    return _post<EndResponse>(
      path: '/v1/sessions/$sessionId/end',
      headers: _headers(sessionToken: sessionToken),
      body: SessionEndRequest(reason: reason).toJson(),
      parse: EndResponse.fromJson,
    );
  }

  @override
  Future<DebriefResponse> getDebrief({
    required String sessionId,
    required String sessionToken,
  }) {
    return _get<DebriefResponse>(
      path: '/v1/sessions/$sessionId/debrief',
      headers: _headers(sessionToken: sessionToken),
      parse: DebriefResponse.fromJson,
    );
  }

  @override
  Future<ShareResponse> shareSession({
    required String sessionId,
    required String sessionToken,
    required bool consent,
  }) {
    return _post<ShareResponse>(
      path: '/v1/sessions/$sessionId/share',
      headers: _headers(sessionToken: sessionToken),
      body: ShareRequest(consent: consent).toJson(),
      parse: ShareResponse.fromJson,
    );
  }

  @override
  Future<void> deleteSession({
    required String sessionId,
    required String sessionToken,
  }) async {
    final Response<dynamic> response = await _send(
      method: 'DELETE',
      path: '/v1/sessions/$sessionId',
      headers: _headers(sessionToken: sessionToken),
    );
    if (response.statusCode == 204 || response.statusCode == 200) {
      return;
    }
    throw _errorFrom(response);
  }

  @override
  Future<ReportResponse> getReport(String reportToken) {
    return _get<ReportResponse>(
      path: '/v1/reports/current',
      headers: _headers(reportToken: reportToken),
      parse: ReportResponse.fromJson,
    );
  }

  Duration _backoff(int attempt) {
    final int milliseconds = 300 * (1 << (attempt - 1));
    return Duration(milliseconds: milliseconds > 4000 ? 4000 : milliseconds);
  }

  Future<T> _get<T>({
    required String path,
    Map<String, String>? headers,
    required T Function(Map<String, dynamic>) parse,
  }) async {
    final Response<dynamic> response = await _send(
      method: 'GET',
      path: path,
      headers: headers,
    );
    return _parseResponse<T>(response, parse);
  }

  Future<T> _post<T>({
    required String path,
    required Map<String, dynamic> body,
    Map<String, String>? headers,
    required T Function(Map<String, dynamic>) parse,
  }) async {
    final Response<dynamic> response = await _send(
      method: 'POST',
      path: path,
      headers: headers,
      body: body,
    );
    return _parseResponse<T>(response, parse);
  }

  Future<Response<dynamic>> _send({
    required String method,
    required String path,
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    try {
      return await _dio.request<dynamic>(
        path,
        data: body,
        options: Options(method: method, headers: headers),
      );
    } on DioException catch (error) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          throw ApiException.timeout(error);
        case DioExceptionType.connectionError:
        case DioExceptionType.unknown:
          throw ApiException.network(error);
        default:
          throw ApiException(
            message: 'The network request failed.',
            isNetwork: true,
            cause: error,
          );
      }
    }
  }

  T _parseResponse<T>(
    Response<dynamic> response,
    T Function(Map<String, dynamic>) parse,
  ) {
    final int? status = response.statusCode;
    final bool ok = status != null && status >= 200 && status < 300;
    if (!ok) {
      throw _errorFrom(response);
    }
    final Map<String, dynamic> json = _asMap(response.data);
    try {
      return parse(json);
    } on Object catch (error) {
      throw ApiException.malformed(error);
    }
  }

  ApiException _errorFrom(Response<dynamic> response) {
    final int? status = response.statusCode;
    final Map<String, dynamic>? json = _tryMap(response.data);
    ProblemDetail? problem;
    if (json != null) {
      try {
        problem = ProblemDetail.fromJson(json);
      } on Object {
        problem = null;
      }
    }
    Duration? retryAfter;
    final Object? raw = response.headers.value('retry-after');
    if (raw != null) {
      final int? seconds = int.tryParse(raw.toString());
      if (seconds != null) {
        retryAfter = Duration(seconds: seconds);
      }
    }
    int? expected;
    final String? detail = problem?.detail ?? json?['detail']?.toString();
    if (detail != null) {
      final RegExpMatch? match =
          RegExp(r'Expected turn index is (\d+)').firstMatch(detail);
      if (match != null) {
        expected = int.tryParse(match.group(1)!);
      }
    }
    return ApiException(
      message: problem?.detail ??
          (status == null
              ? 'The server response did not include a status.'
              : 'The server returned status $status.'),
      statusCode: status,
      code: problem?.code,
      problem: problem,
      retryAfter: retryAfter,
      expectedTurnIndex: expected,
    );
  }

  Map<String, dynamic> _asMap(Object? data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    throw ApiException.malformed(
      StateError('Expected a JSON object, received ${data.runtimeType}.'),
    );
  }

  Map<String, dynamic>? _tryMap(Object? data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }
}
