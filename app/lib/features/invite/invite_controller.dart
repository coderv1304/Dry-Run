import 'package:api_client/api_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/providers.dart';
import '../../state/token_store.dart';

final RegExp cohortPattern = RegExp(r'^[a-z0-9-]{1,24}$');

const Object _keep = Object();

@immutable
class InviteState {
  const InviteState({
    this.language = AppLanguage.en,
    this.creating = false,
    this.inviteUrl,
    this.expiresAt,
    this.error,
  });

  final AppLanguage language;
  final bool creating;
  final String? inviteUrl;
  final String? expiresAt;
  final Object? error;

  InviteState copyWith({
    AppLanguage? language,
    bool? creating,
    String? inviteUrl,
    String? expiresAt,
    Object? error = _keep,
  }) {
    return InviteState(
      language: language ?? this.language,
      creating: creating ?? this.creating,
      inviteUrl: inviteUrl ?? this.inviteUrl,
      expiresAt: expiresAt ?? this.expiresAt,
      error: identical(error, _keep) ? this.error : error,
    );
  }

  InviteState cleared() => InviteState(language: language);
}

final StateNotifierProvider<InviteController, InviteState> inviteControllerProvider =
    StateNotifierProvider<InviteController, InviteState>(
  (Ref ref) => InviteController(ref),
);

class InviteController extends StateNotifier<InviteState> {
  InviteController(this._ref) : super(const InviteState());

  final Ref _ref;

  void setLanguage(AppLanguage language) {
    state = state.cleared().copyWith(language: language);
  }

  Future<bool> create({String? cohort}) async {
    if (state.creating) {
      return false;
    }
    state = state.cleared().copyWith(creating: true);
    try {
      final InviteResponse response = await _ref.read(apiProvider).createInvite(
            language: state.language,
            cohort: cohort,
          );
      _ref.read(tokenStoreProvider.notifier).setInvite(response.inviteToken);
      final String url =
          _ref.read(linkBuilderProvider).invite(response.inviteToken).toString();
      state = state.copyWith(
        creating: false,
        inviteUrl: url,
        expiresAt: response.expiresAt,
        error: null,
      );
      return true;
    } on Object catch (error) {
      state = state.copyWith(creating: false, error: error);
      return false;
    }
  }

  void clear() {
    state = state.cleared();
  }
}
