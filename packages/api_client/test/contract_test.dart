import 'dart:convert';
import 'dart:io';

import 'package:api_client/api_client.dart';
import 'package:test/test.dart';

/// Every fixture in contracts/examples must be exercised. Valid fixtures must
/// parse into their freezed model, invalid fixtures must fail. A new fixture
/// without a mapping fails this test instead of quietly going unchecked.
void main() {
  final Map<String, dynamic Function(Map<String, dynamic>)> parsers =
      <String, dynamic Function(Map<String, dynamic>)>{
    'problem_detail': ProblemDetail.fromJson,
    'config_response': ConfigResponse.fromJson,
    'scenario_graph': ScenarioGraphResponse.fromJson,
    'invite_response': InviteResponse.fromJson,
    'current_invite_response': CurrentInviteResponse.fromJson,
    'turn_response': TurnResponse.fromJson,
    'session_create_response': SessionCreateResponse.fromJson,
    'debrief_response_quick': DebriefResponse.fromJson,
    'debrief_response_full': DebriefResponse.fromJson,
    'debrief_response_low_confidence': DebriefResponse.fromJson,
    'debrief_response': DebriefResponse.fromJson,
    'share_response': ShareResponse.fromJson,
    'report_response': ReportResponse.fromJson,
  };

  dynamic Function(Map<String, dynamic>)? parserFor(String fileName) {
    final List<String> keys = parsers.keys.toList()
      ..sort((String a, String b) => b.length.compareTo(a.length));
    for (final String key in keys) {
      if (fileName.startsWith(key)) {
        return parsers[key];
      }
    }
    return null;
  }

  group('contract fixtures', () {
    final Directory examples = Directory('../../contracts/examples');

    test('the examples directory exists', () {
      expect(examples.existsSync(), isTrue);
    });

    final List<File> files = examples.existsSync()
        ? (examples
            .listSync()
            .whereType<File>()
            .where((File file) => file.path.endsWith('.json'))
            .toList()
          ..sort((File a, File b) => a.path.compareTo(b.path)))
        : <File>[];

    test('fixtures were discovered', () {
      expect(files, isNotEmpty);
    });

    for (final File file in files) {
      final String name = file.uri.pathSegments.last;
      final bool valid = name.contains('_valid');
      final bool invalid = name.contains('_invalid');

      test('$name ${valid ? 'parses' : 'is rejected'}', () {
        expect(
          valid || invalid,
          isTrue,
          reason: 'fixture names must state _valid or _invalid',
        );
        final dynamic Function(Map<String, dynamic>)? parser = parserFor(name);
        expect(parser, isNotNull, reason: 'no model mapping for $name');
        final Map<String, dynamic> json =
            jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
        if (valid) {
          expect(() => parser!(json), returnsNormally);
        } else {
          expect(() => parser!(json), throwsA(anything));
        }
      });
    }

    test('every fixture has a model mapping', () {
      for (final File file in files) {
        final String name = file.uri.pathSegments.last;
        expect(parserFor(name), isNotNull, reason: 'unmapped fixture $name');
      }
    });
  });

  group('request serialization', () {
    test('turn request uses snake case contract keys', () {
      const TurnRequest request = TurnRequest(
        turnId: 'b3b1f0d2-4d4a-4f37-9f1c-7a7f0a0c9e11',
        expectedTurnIndex: 3,
        text: 'I will call the official number.',
      );
      final Map<String, dynamic> json = request.toJson();
      expect(json['turn_id'], 'b3b1f0d2-4d4a-4f37-9f1c-7a7f0a0c9e11');
      expect(json['expected_turn_index'], 3);
      expect(json['text'], isNotEmpty);
      expect(json.containsKey('turnId'), isFalse);
    });

    test('session request serializes stats opt in and chat mode', () {
      const SessionCreateRequest request = SessionCreateRequest(
        consent: true,
        statsOptIn: true,
        mode: SessionMode.chat,
      );
      final Map<String, dynamic> json = request.toJson();
      expect(json['consent'], isTrue);
      expect(json['stats_opt_in'], isTrue);
      expect(json['mode'], 'chat');
    });

    test('end reason serializes to the contract value', () {
      const SessionEndRequest request =
          SessionEndRequest(reason: EndReason.participantEnded);
      expect(request.toJson()['reason'], 'participant_ended');
    });
  });
}
