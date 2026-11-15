import 'package:api_client/api_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/providers.dart';
import '../../state/token_store.dart';
import '../session/session_controller.dart';

@immutable
class ConsentState {
  const ConsentState({
    this.token,
    this.language,
    this.loading = false,
    this.loadError,
    this.starting = false,
    this.startError,
  });

  final String? token;
  final AppLanguage? language;
  final bool loading;
  final Object? loadError;
  final bool starting;
  final Object? startError;

  ConsentState copyWith({
    String? token,
    AppLanguage? language,
    bool? loading,
    Object? loadError,
    bool? starting,
    Object? startError,
    bool clearLoadError = false,
    bool clearStartError = false,
  }) {
    return ConsentState(
      token: token ?? this.token,
      language: language ?? this.language,
      loading: loading ?? this.loading,
      loadError: clearLoadError ? null : (loadError ?? this.loadError),
      starting: starting ?? this.starting,
      startError: clearStartError ? null : (startError ?? this.startError),
    );
  }
}

final StateNotifierProvider<ConsentController, ConsentState> consentControllerProvider =
    StateNotifierProvider<ConsentController, ConsentState>(
  (Ref ref) => ConsentController(ref),
);

class ConsentController extends StateNotifier<ConsentState> {
  ConsentController(this._ref) : super(const ConsentState());

  final Ref _ref;

  Future<void> load(String token) async {
    if (state.loading) {
      return;
    }
    if (state.token == token && state.language != null && state.loadError == null) {
      return;
    }
    state = ConsentState(token: token, loading: true);
    try {
      final CurrentInviteResponse invite =
          await _ref.read(apiProvider).getCurrentInvite(token);
      state = ConsentState(
        token: token,
        language: invite.language,
        loading: false,
      );
    } on Object catch (error) {
      state = ConsentState(token: token, loadError: error);
    }
  }

  Future<bool> start({required bool statsOptIn, required String token}) async {
    if (state.starting) {
      return false;
    }
    state = state.copyWith(starting: true, clearStartError: true);
    try {
      final SessionCreateResponse response =
          await _ref.read(apiProvider).createSession(
                inviteToken: token,
                consent: true,
                statsOptIn: statsOptIn,
              );
      _ref.read(tokenStoreProvider.notifier).setSession(
            sessionId: response.sessionId,
            sessionToken: response.sessionToken,
          );
      _ref.read(tokenStoreProvider.notifier).clearInvite();
      _ref.read(sessionControllerProvider.notifier).adopt(response);
      state = ConsentState(token: token, language: state.language);
      return true;
    } on Object catch (error) {
      state = state.copyWith(starting: false, startError: error);
      return false;
    }
  }

  void decline() {
    _ref.read(tokenStoreProvider.notifier).clearInvite();
    state = const ConsentState();
  }

  void reset() {
    state = const ConsentState();
  }
}
