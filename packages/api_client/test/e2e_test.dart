import 'dart:async';
import 'dart:io';

import 'package:api_client/api_client.dart';
import 'package:test/test.dart';

/// End to end against the real FastAPI backend in scripted mode. The backend
/// runs from a fresh SQLite file on a free localhost port, so the test never
/// touches a developer database or the public network.
void main() {
  group('real scripted backend', () {
    late Process backend;
    late Directory tempDir;
    late DryRunApiClient api;

    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp('dryrun_e2e_');
      final int port = await _freePort();
      final String databaseUrl =
          'sqlite:///${_posixPath('${tempDir.path}/e2e.db')}';
      final String root = Directory.current.parent.parent.path;
      final Map<String, String> environment = <String, String>{
        ...Platform.environment,
        'APP_ENV': 'development',
        'DATABASE_URL': databaseUrl,
        'AUTO_CREATE_SCHEMA': 'true',
        'TOKEN_PEPPER': 'e2e-only-pepper-that-is-long-enough',
        'LLM_ENABLED': 'false',
        'VOICE_ENABLED': 'false',
        'LOG_LEVEL': 'warning',
        'INVITE_PER_IP_PER_HOUR': '1000',
        'INVITE_GLOBAL_DAILY_CAP': '1000',
        'TURN_PER_IP_PER_MINUTE': '1000',
        'TURN_PER_TOKEN_PER_MINUTE': '1000',
        'MAX_TURNS': '12',
        'MAX_DURATION_SECONDS': '900',
        'IDLE_TIMEOUT_SECONDS': '600',
        'MAX_REQUEST_BODY_BYTES': '4096',
        'RETENTION_DAYS': '7',
        'INVITE_TTL_DAYS': '7',
        'SESSION_TTL_DAYS': '7',
        'REPORT_TTL_DAYS': '7',
      };

      backend = await Process.start(
        Platform.isWindows ? 'python' : 'python3',
        <String>[
          '-m',
          'uvicorn',
          'app.main:app',
          '--host',
          '127.0.0.1',
          '--port',
          '$port',
          '--log-level',
          'warning',
        ],
        workingDirectory: '$root/backend',
        environment: environment,
        runInShell: false,
      );
      unawaited(backend.stdout.drain<void>());
      unawaited(backend.stderr.drain<void>());

      final String baseUrl = 'http://127.0.0.1:$port';
      api = DryRunApiClient(baseUrl: baseUrl);
      final DateTime deadline = DateTime.now().add(const Duration(seconds: 45));
      bool healthy = false;
      while (DateTime.now().isBefore(deadline)) {
        if (await api.healthCheck()) {
          healthy = true;
          break;
        }
        await Future<void>.delayed(const Duration(milliseconds: 250));
      }
      if (!healthy) {
        backend.kill();
        throw StateError('The scripted backend did not become healthy.');
      }
    });

    tearDownAll(() async {
      backend.kill();
      await backend.exitCode.timeout(
        const Duration(seconds: 10),
        onTimeout: () => -1,
      );
      await Future<void>.delayed(const Duration(milliseconds: 250));
      try {
        await tempDir.delete(recursive: true);
      } on FileSystemException {
        // SQLite on Windows can hold the file briefly. A temp directory leak is
        // preferable to a flaky cleanup failure.
      }
    });

    test('invite, session, turns, end, debrief, share, report, delete', () async {
      final ConfigResponse config = await api.getConfig();
      expect(config.flags.llmEnabled, isFalse);
      expect(config.limits.maxTurns, greaterThan(0));

      final ScenarioGraphResponse graph = await api.getScenarioGraph();
      expect(graph.stageIds, isNotEmpty);
      expect(graph.labels, isNotEmpty);

      final InviteResponse invite = await api.createInvite(
        language: AppLanguage.en,
        cohort: 'tryout',
      );
      expect(invite.inviteToken, startsWith('inv_'));
      expect(invite.expiresAt, isNotEmpty);

      final CurrentInviteResponse current =
          await api.getCurrentInvite(invite.inviteToken);
      expect(current.cohort, 'tryout');
      expect(current.language, AppLanguage.en);

      final SessionCreateResponse session = await api.createSession(
        inviteToken: invite.inviteToken,
        consent: true,
        statsOptIn: false,
      );
      expect(session.sessionId, startsWith('ses_'));
      expect(session.sessionToken, startsWith('tok_'));
      expect(session.firstTurn.status, TurnStatus.active);
      expect(session.firstTurn.officerLine, isNotNull);

      int expected = session.firstTurn.turnIndex + 1;
      const String firstTurnId = '7e5d3c4b-2a19-4f80-9c11-0a1b2c3d4e5f';
      final TurnResponse first = await api.submitTurn(
        sessionId: session.sessionId,
        sessionToken: session.sessionToken,
        text: 'I will call the official number and verify this.',
        expectedTurnIndex: expected,
        turnId: firstTurnId,
      );
      expect(first.turnIndex, expected);

      final TurnResponse replay = await api.submitTurn(
        sessionId: session.sessionId,
        sessionToken: session.sessionToken,
        text: 'I will call the official number and verify this.',
        expectedTurnIndex: expected,
        turnId: firstTurnId,
      );
      expect(replay.turnIndex, first.turnIndex,
          reason: 'the same turn id must return the stored response');

      final List<String> replies = <String>[
        'I will not share my OTP or card number.',
        'Please give me your badge number.',
        'I am calling my family now.',
        'I do not trust this call. I am hanging up.',
        'I will only use the number printed on my bank card.',
        'I am not transferring any money.',
        'My family is with me and we are checking this together.',
        'I am ending this call.',
      ];

      expected += 1;
      TurnResponse turn = first;
      for (final String reply in replies) {
        if (turn.status == TurnStatus.ended) {
          break;
        }
        turn = await api.submitTurn(
          sessionId: session.sessionId,
          sessionToken: session.sessionToken,
          text: reply,
          expectedTurnIndex: expected,
        );
        expect(turn.turnIndex, expected);
        expected += 1;
      }

      final EndResponse ended = await api.endSession(
        sessionId: session.sessionId,
        sessionToken: session.sessionToken,
      );
      expect(ended.status, EndedStatus.ended);

      final DebriefResponse debrief = await api.getDebrief(
        sessionId: session.sessionId,
        sessionToken: session.sessionToken,
      );
      expect(debrief.status, DebriefStatus.ready);
      expect(debrief.debrief, isNotNull);
      expect(debrief.debrief!.quality, isNotNull);
      expect(debrief.debrief!.statePath, isNotEmpty);

      final ShareResponse shared = await api.shareSession(
        sessionId: session.sessionId,
        sessionToken: session.sessionToken,
        consent: true,
      );
      expect(shared.reportToken, startsWith('rep_'));

      final ReportResponse report = await api.getReport(shared.reportToken);
      expect(report.debrief.statePath, isNotEmpty);
      expect(report.reportToken, shared.reportToken);

      await api.deleteSession(
        sessionId: session.sessionId,
        sessionToken: session.sessionToken,
      );

      await expectLater(
        api.getReport(shared.reportToken),
        throwsA(
          isA<ApiException>()
              .having((ApiException e) => e.statusCode, 'status', 401),
        ),
      );
      await expectLater(
        api.getDebrief(
          sessionId: session.sessionId,
          sessionToken: session.sessionToken,
        ),
        throwsA(
          isA<ApiException>()
              .having((ApiException e) => e.statusCode, 'status', 401),
        ),
      );
    });
  });
}

Future<int> _freePort() async {
  final ServerSocket socket =
      await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
  final int port = socket.port;
  await socket.close();
  return port;
}

String _posixPath(String path) => path.replaceAll('\\', '/');
