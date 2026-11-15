import 'package:api_client/api_client.dart';
import 'package:dryrun/features/debrief/debrief_controller.dart';
import 'package:dryrun/features/invite/invite_controller.dart';
import 'package:dryrun/features/join/join_controller.dart';
import 'package:dryrun/features/session/drill_models.dart';
import 'package:dryrun/features/session/session_controller.dart';
import 'package:dryrun/state/token_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_test_support.dart';

void main() {
  group('session controller', () {
    late FakeApi api;
    late ProviderContainer container;
    late SessionCreateResponse session;

    setUp(() {
      api = FakeApi();
      container = buildContainer(appOverrides(api: api));
      session = contractModel(
        'session_create_response_valid',
        SessionCreateResponse.fromJson,
      );
    });

    test('adopt writes the opening turn and the next expected index', () {
      container.read(sessionControllerProvider.notifier).adopt(session);
      final DrillState state = container.read(sessionControllerProvider);

      expect(state.hasSession, isTrue);
      expect(state.messages, hasLength(1));
      expect(state.messages.single.speaker, ChatSpeaker.officer);
      expect(state.messages.single.text, 'Identify yourself.');
      expect(state.expectedTurnIndex, 1);
      expect(state.ended, isFalse);
    });

    test('send submits one turn with a stable id and appends both sides',
        () async {
      container.read(sessionControllerProvider.notifier).adopt(session);
      api.turns = <TurnResponse>[
        contractModel('turn_response_valid', TurnResponse.fromJson),
      ];

      final bool ok =
          await container.read(sessionControllerProvider.notifier).send(
                '  I will not share anything.  ',
              );

      expect(ok, isTrue);
      expect(api.submittedTurns, hasLength(1));
      expect(api.submittedTurns.single.turnId, 'turn-fixed-id');
      expect(api.submittedTurns.single.expectedTurnIndex, 1);
      expect(api.submittedTurns.single.text, 'I will not share anything.');

      final DrillState state = container.read(sessionControllerProvider);
      expect(state.messages, hasLength(3));
      expect(state.messages[1].speaker, ChatSpeaker.participant);
      expect(state.messages[2].speaker, ChatSpeaker.officer);
      expect(state.messages[2].text, 'Who is speaking?');
      expect(state.pending, isNull);
      expect(state.sending, isFalse);
      expect(state.error, isNull);
    });

    test('a failed send keeps the pending turn and retry reuses its id',
        () async {
      container.read(sessionControllerProvider.notifier).adopt(session);
      api.turnError = ApiException.network(StateError('socket closed'));
      api.turns = <TurnResponse>[
        contractModel('turn_response_valid', TurnResponse.fromJson),
      ];

      final bool first =
          await container.read(sessionControllerProvider.notifier).send('Hello');
      expect(first, isFalse);

      DrillState failed = container.read(sessionControllerProvider);
      expect(failed.error, isNotNull);
      expect(failed.pending, isNotNull);
      expect(failed.messages, hasLength(2));

      final bool retried =
          await container.read(sessionControllerProvider.notifier).retry();
      expect(retried, isTrue);

      expect(api.submittedTurns, hasLength(2));
      expect(
        api.submittedTurns[0].turnId,
        api.submittedTurns[1].turnId,
      );
      expect(
        api.submittedTurns[0].expectedTurnIndex,
        api.submittedTurns[1].expectedTurnIndex,
      );
      expect(api.submittedTurns[1].turnId, 'turn-fixed-id');

      final DrillState recovered = container.read(sessionControllerProvider);
      expect(recovered.pending, isNull);
      expect(recovered.error, isNull);
      expect(recovered.messages, hasLength(3));
    });

    test('send is ignored while a turn is already pending', () async {
      container.read(sessionControllerProvider.notifier).adopt(session);
      api.turnError = ApiException.network(StateError('offline'));
      await container.read(sessionControllerProvider.notifier).send('First');

      final bool second =
          await container.read(sessionControllerProvider.notifier).send(
                'Second',
              );
      expect(second, isFalse);
      expect(api.submittedTurns, hasLength(1));
    });

    test('end moves to ended and never calls the API twice', () async {
      container.read(sessionControllerProvider.notifier).adopt(session);

      final bool first =
          await container.read(sessionControllerProvider.notifier).end();
      final bool second =
          await container.read(sessionControllerProvider.notifier).end();

      expect(first, isTrue);
      expect(second, isFalse);
      final DrillState state = container.read(sessionControllerProvider);
      expect(state.ended, isTrue);
      expect(state.ending, isFalse);
    });
  });

  group('invite controller', () {
    test('create stores the invite token and a fragment link', () async {
      final FakeApi api = FakeApi();
      final ProviderContainer container = buildContainer(appOverrides(api: api));

      final bool ok = await container
          .read(inviteControllerProvider.notifier)
          .create(cohort: 'ward-4');

      expect(ok, isTrue);
      final InviteState state = container.read(inviteControllerProvider);
      expect(state.inviteUrl, contains('#token=inv_'));
      expect(state.expiresAt, isNotNull);
      expect(state.creating, isFalse);
      expect(
        container.read(tokenStoreProvider).inviteToken,
        'inv_0123456789abcdef0123456789abcdef',
      );
    });

    test('a failed create keeps the language and exposes the error', () async {
      final FakeApi api = _FailingInviteApi();
      final ProviderContainer container = buildContainer(appOverrides(api: api));

      container
          .read(inviteControllerProvider.notifier)
          .setLanguage(AppLanguage.hi);
      final bool ok =
          await container.read(inviteControllerProvider.notifier).create();

      expect(ok, isFalse);
      final InviteState state = container.read(inviteControllerProvider);
      expect(state.language, AppLanguage.hi);
      expect(state.error, isNotNull);
    });
  });

  group('join controller', () {
    test('accepts a fragment link and stores its token', () async {
      final FakeApi api = FakeApi();
      final ProviderContainer container = buildContainer(appOverrides(api: api));

      final bool ok = await container
          .read(joinControllerProvider.notifier)
          .validate('http://127.0.0.1:8080/#token=inv_abc123');

      expect(ok, isTrue);
      expect(container.read(tokenStoreProvider).inviteToken, 'inv_abc123');
      expect(container.read(joinControllerProvider).invalidLink, isFalse);
    });

    test('rejects text that carries no invite token', () async {
      final FakeApi api = FakeApi();
      final ProviderContainer container = buildContainer(appOverrides(api: api));

      final bool ok = await container
          .read(joinControllerProvider.notifier)
          .validate('not a link');

      expect(ok, isFalse);
      expect(container.read(joinControllerProvider).invalidLink, isTrue);
      expect(container.read(tokenStoreProvider).inviteToken, isNull);
    });
  });

  group('debrief controller', () {
    late FakeApi api;
    late ProviderContainer container;

    setUp(() {
      api = FakeApi();
      container = buildContainer(
        appOverrides(
          api: api,
          tokens: const InitialTokens(
            inviteToken: 'inv_test',
            reportToken: null,
          ),
        ),
      );
      container.read(tokenStoreProvider.notifier).setSession(
            sessionId: 'ses_test',
            sessionToken: 'tok_test',
          );
    });

    test('loads the quick debrief then refines to the full one', () async {
      api.debriefs = <DebriefResponse>[quickDebrief(), fullDebrief()];

      await container.read(debriefControllerProvider.notifier).load();

      final DebriefState state = container.read(debriefControllerProvider);
      expect(state.content, isNotNull);
      expect(state.content!.quality, DebriefQuality.full);
      expect(state.polling, isFalse);
      expect(api.debriefCalls, 2);
    });

    test('share creates a report link and keeps the explicit consent', () async {
      api.debriefs = <DebriefResponse>[fullDebrief()];
      await container.read(debriefControllerProvider.notifier).load();

      final String? url =
          await container.read(debriefControllerProvider.notifier).share();

      expect(url, contains('#report=rep_'));
      expect(api.shareCalls, 1);
      expect(
        container.read(tokenStoreProvider).reportToken,
        'rep_0123456789abcdef0123456789abcdef',
      );
    });

    test('delete clears the session and reports the deleted state', () async {
      api.debriefs = <DebriefResponse>[fullDebrief()];
      await container.read(debriefControllerProvider.notifier).load();

      final bool ok =
          await container.read(debriefControllerProvider.notifier).delete();

      expect(ok, isTrue);
      expect(api.deleteCalls, 1);
      expect(container.read(tokenStoreProvider).hasSession, isFalse);
      final DebriefState state = container.read(debriefControllerProvider);
      expect(state.deleted, isTrue);
      expect(state.content, isNull);
    });

    test('a failed delete keeps the debrief and exposes the error', () async {
      api.debriefs = <DebriefResponse>[fullDebrief()];
      await container.read(debriefControllerProvider.notifier).load();
      api.deleteError = ApiException.network(StateError('offline'));

      final bool ok =
          await container.read(debriefControllerProvider.notifier).delete();

      expect(ok, isFalse);
      final DebriefState state = container.read(debriefControllerProvider);
      expect(state.deleted, isFalse);
      expect(state.deleteError, isNotNull);
      expect(state.content, isNotNull);
    });
  });
}

class _FailingInviteApi extends FakeApi {
  @override
  Future<InviteResponse> createInvite({
    required AppLanguage language,
    String? cohort,
  }) async {
    throw ApiException.network(StateError('offline'));
  }
}
