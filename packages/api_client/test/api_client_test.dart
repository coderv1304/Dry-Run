import 'dart:convert';
import 'package:api_client/api_client.dart';
import 'package:test/test.dart';

void main() {
  group('TurnResponse Model', () {
    test('parses active turn with officer line', () {
      final json = {
        'officer_line': {
          'display': 'This is Inspector Sharma.',
          'speak': 'This is Inspector Sharma.',
          'language': 'en',
        },
        'stage_id': 'contact',
        'pressure': 1,
        'status': 'active',
        'turn_index': 1,
        'fallback_used': false,
        'pii_warning': false,
      };

      final resp = TurnResponse.fromJson(json);
      expect(resp.stageId, equals('contact'));
      expect(resp.officerLine?.display, equals('This is Inspector Sharma.'));
      expect(resp.status, equals('active'));
      expect(resp.turnIndex, equals(1));
    });
  });

  group('Debrief Model', () {
    test('parses quick debrief', () {
      final json = {
        'quality': 'quick',
        'low_confidence': false,
        'state_path': [
          {'stage_id': 'contact', 'turn_index': 1},
          {'stage_id': 'accusation', 'turn_index': 2},
        ],
        'events': [
          {
            'turn_index': 2,
            'label': 'C1',
            'confidence': 0.85,
            'quote': {'text': 'my aadhaar number is', 'start': 0, 'end': 20},
          }
        ],
        'first_compliance': {
          'turn_index': 2,
          'stage_id': 'accusation',
          'label': 'C1',
        },
        'did_well_ids': ['asked_badge_number'],
        'habit_id': 'hang_up',
      };

      final debrief = Debrief.fromJson(json);
      expect(debrief.quality, equals('quick'));
      expect(debrief.lowConfidence, isFalse);
      expect(debrief.habitId, equals('hang_up'));
      expect(debrief.didWellIds, contains('asked_badge_number'));
      expect(debrief.firstCompliance?.label, equals('C1'));
    });
  });

  group('ProblemDetail Model', () {
    test('parses problem+json error', () {
      final json = {
        'type': 'https://dryrun.in/errors/invalid_token',
        'title': 'Invalid Token',
        'status': 401,
        'detail': 'The provided session token is not recognized.',
        'code': 'invalid_token',
      };

      final err = ProblemDetail.fromJson(json);
      expect(err.code, equals('invalid_token'));
      expect(err.status, equals(401));
    });
  });
}
