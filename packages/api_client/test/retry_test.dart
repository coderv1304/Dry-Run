import 'dart:convert';
import 'dart:typed_data';

import 'package:api_client/api_client.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this.handler);

  final Future<ResponseBody> Function(RequestOptions options, int call) handler;
  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    calls += 1;
    return handler(options, calls);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _jsonResponse(int status, Map<String, dynamic> body) {
  return ResponseBody.fromString(
    jsonEncode(body),
    status,
    headers: <String, List<String>>{
      Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      'retry-after': <String>['1'],
    },
  );
}

Map<String, dynamic> _turnBody({int turnIndex = 1}) {
  return <String, dynamic>{
    'officer_line': <String, dynamic>{
      'display': 'Please stay on the line.',
      'speak': 'Please stay on the line.',
      'language': 'en',
    },
    'stage_id': 'accusation',
    'pressure': 1,
    'status': 'active',
    'turn_index': turnIndex,
    'fallback_used': true,
    'pii_warning': false,
  };
}

Map<String, dynamic> _problem({
  required int status,
  required String code,
  required String detail,
}) {
  return <String, dynamic>{
    'type': 'https://dryrun.in/errors/$code',
    'title': 'Problem',
    'status': status,
    'detail': detail,
    'code': code,
  };
}

DryRunApiClient _client(
  _ScriptedAdapter adapter, {
  required List<Duration> delays,
}) {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'http://127.0.0.1:9',
      responseType: ResponseType.json,
      validateStatus: (_) => true,
    ),
  )..httpClientAdapter = adapter;
  return DryRunApiClient(
    baseUrl: 'http://127.0.0.1:9',
    dio: dio,
    delay: (Duration duration) async => delays.add(duration),
  );
}

void main() {
  group('turn idempotency and retry', () {
    test('429 retries the same turn id and expected index', () async {
      final List<Map<String, dynamic>> requests = <Map<String, dynamic>>[];
      final List<Duration> delays = <Duration>[];
      final _ScriptedAdapter adapter = _ScriptedAdapter((options, call) async {
        requests.add(Map<String, dynamic>.from(options.data as Map));
        if (call == 1) {
          return _jsonResponse(
            429,
            _problem(
              status: 429,
              code: 'rate_limited',
              detail: 'Too many turns.',
            ),
          );
        }
        return _jsonResponse(200, _turnBody());
      });

      final TurnResponse response = await _client(adapter, delays: delays).submitTurn(
        sessionId: 'ses_1',
        sessionToken: 'tok_1',
        text: 'hello',
        expectedTurnIndex: 1,
        turnId: 'fixed-turn-id',
      );

      expect(response.turnIndex, 1);
      expect(requests, hasLength(2));
      expect(requests[0]['turn_id'], 'fixed-turn-id');
      expect(requests[1]['turn_id'], 'fixed-turn-id');
      expect(requests[0]['expected_turn_index'], 1);
      expect(requests[1]['expected_turn_index'], 1);
      expect(delays.single, const Duration(seconds: 1));
    });

    test('409 turn index mismatch re-syncs and keeps the turn id', () async {
      final List<Map<String, dynamic>> requests = <Map<String, dynamic>>[];
      final List<Duration> delays = <Duration>[];
      final _ScriptedAdapter adapter = _ScriptedAdapter((options, call) async {
        requests.add(Map<String, dynamic>.from(options.data as Map));
        if (call == 1) {
          return _jsonResponse(
            409,
            _problem(
              status: 409,
              code: 'turn_index_mismatch',
              detail: 'Expected turn index is 5.',
            ),
          );
        }
        return _jsonResponse(200, _turnBody(turnIndex: 5));
      });

      await _client(adapter, delays: delays).submitTurn(
        sessionId: 'ses_1',
        sessionToken: 'tok_1',
        text: 'hello',
        expectedTurnIndex: 2,
        turnId: 'same-id',
      );

      expect(requests, hasLength(2));
      expect(requests[0]['expected_turn_index'], 2);
      expect(requests[1]['expected_turn_index'], 5);
      expect(requests[0]['turn_id'], 'same-id');
      expect(requests[1]['turn_id'], 'same-id');
      expect(delays, isEmpty);
    });

    test('network failure reuses the turn id with backoff', () async {
      final List<Map<String, dynamic>> requests = <Map<String, dynamic>>[];
      final List<Duration> delays = <Duration>[];
      final _ScriptedAdapter adapter = _ScriptedAdapter((options, call) async {
        requests.add(Map<String, dynamic>.from(options.data as Map));
        if (call < 3) {
          throw DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
          );
        }
        return _jsonResponse(200, _turnBody());
      });

      await _client(adapter, delays: delays).submitTurn(
        sessionId: 'ses_1',
        sessionToken: 'tok_1',
        text: 'hello',
        expectedTurnIndex: 1,
        turnId: 'network-id',
      );

      expect(requests, hasLength(3));
      expect(requests.map((Map<String, dynamic> body) => body['turn_id']).toSet(),
          <String>{'network-id'});
      expect(delays, <Duration>[
        const Duration(milliseconds: 300),
        const Duration(milliseconds: 600),
      ]);
    });

    test('409 session ended is not retried', () async {
      final List<Duration> delays = <Duration>[];
      final _ScriptedAdapter adapter = _ScriptedAdapter((options, call) async {
        return _jsonResponse(
          409,
          _problem(
            status: 409,
            code: 'session_ended',
            detail: 'This drill has already ended.',
          ),
        );
      });

      await expectLater(
        _client(adapter, delays: delays).submitTurn(
          sessionId: 'ses_1',
          sessionToken: 'tok_1',
          text: 'hello',
          expectedTurnIndex: 1,
        ),
        throwsA(
          isA<ApiException>()
              .having((ApiException e) => e.code, 'code', ProblemCode.sessionEnded),
        ),
      );
      expect(adapter.calls, 1);
      expect(delays, isEmpty);
    });
  });

  group('problem parsing', () {
    test('a problem response becomes a typed ApiException', () async {
      final _ScriptedAdapter adapter = _ScriptedAdapter((options, call) async {
        return _jsonResponse(
          401,
          _problem(
            status: 401,
            code: 'invalid_token',
            detail: 'Provided session token is invalid or expired.',
          ),
        );
      });
      await expectLater(
        _client(adapter, delays: <Duration>[]).getDebrief(
          sessionId: 'ses_1',
          sessionToken: 'bad',
        ),
        throwsA(
          isA<ApiException>()
              .having((ApiException e) => e.statusCode, 'status', 401)
              .having((ApiException e) => e.code, 'code', ProblemCode.invalidToken),
        ),
      );
    });
  });
}
