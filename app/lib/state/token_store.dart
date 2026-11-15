import 'package:api_client/api_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class TokenStore {
  const TokenStore({
    this.inviteToken,
    this.sessionId,
    this.sessionToken,
    this.reportToken,
  });

  final String? inviteToken;
  final String? sessionId;
  final String? sessionToken;
  final String? reportToken;

  bool get hasSession => sessionId != null && sessionToken != null;

  TokenStore copyWith({
    String? inviteToken,
    String? sessionId,
    String? sessionToken,
    String? reportToken,
  }) {
    return TokenStore(
      inviteToken: inviteToken ?? this.inviteToken,
      sessionId: sessionId ?? this.sessionId,
      sessionToken: sessionToken ?? this.sessionToken,
      reportToken: reportToken ?? this.reportToken,
    );
  }
}

/// Every token lives here and in memory only. Nothing is written to storage.
class TokenStoreNotifier extends StateNotifier<TokenStore> {
  TokenStoreNotifier({String? inviteToken, String? reportToken})
      : super(TokenStore(inviteToken: inviteToken, reportToken: reportToken));

  void setInvite(String token) {
    state = TokenStore(
      inviteToken: token,
      sessionId: state.sessionId,
      sessionToken: state.sessionToken,
      reportToken: state.reportToken,
    );
  }

  void clearInvite() {
    state = TokenStore(
      sessionId: state.sessionId,
      sessionToken: state.sessionToken,
      reportToken: state.reportToken,
    );
  }

  void setSession({
    required String sessionId,
    required String sessionToken,
  }) {
    state = TokenStore(
      inviteToken: state.inviteToken,
      sessionId: sessionId,
      sessionToken: sessionToken,
    );
  }

  void setReport(String token) {
    state = TokenStore(
      inviteToken: state.inviteToken,
      sessionId: state.sessionId,
      sessionToken: state.sessionToken,
      reportToken: token,
    );
  }

  void clearReport() {
    state = TokenStore(
      inviteToken: state.inviteToken,
      sessionId: state.sessionId,
      sessionToken: state.sessionToken,
    );
  }

  void clearSessionAndReport() {
    state = TokenStore(inviteToken: state.inviteToken);
  }

  void clearAll() {
    state = const TokenStore();
  }
}

final StateNotifierProvider<TokenStoreNotifier, TokenStore> tokenStoreProvider =
    StateNotifierProvider<TokenStoreNotifier, TokenStore>((Ref ref) {
  final InitialTokens initial = ref.watch(initialTokensProvider);
  return TokenStoreNotifier(
    inviteToken: initial.inviteToken,
    reportToken: initial.reportToken,
  );
});

/// Set by bootstrap before the app runs. Kept separate from app config so a
/// deep link never becomes part of the environment.
@immutable
class InitialTokens {
  const InitialTokens({this.inviteToken, this.reportToken});

  static const InitialTokens none = InitialTokens();

  final String? inviteToken;
  final String? reportToken;
}

final Provider<InitialTokens> initialTokensProvider =
    Provider<InitialTokens>((Ref ref) => InitialTokens.none);

/// Invite metadata used by the consent screen.
@immutable
class InviteMeta {
  const InviteMeta({
    required this.token,
    required this.language,
    this.cohort,
  });

  final String token;
  final AppLanguage language;
  final String? cohort;
}
