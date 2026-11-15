import 'package:api_client/api_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/providers.dart';
import '../../state/token_store.dart';

@immutable
class TryState {
  const TryState({
    this.language = AppLanguage.en,
    this.starting = false,
    this.error,
  });

  final AppLanguage language;
  final bool starting;
  final Object? error;
}

final StateNotifierProvider<TryController, TryState> tryControllerProvider =
    StateNotifierProvider<TryController, TryState>(
  (Ref ref) => TryController(ref),
);

class TryController extends StateNotifier<TryState> {
  TryController(this._ref) : super(const TryState());

  final Ref _ref;

  void setLanguage(AppLanguage language) {
    _ref.read(sessionLanguageProvider.notifier).state = language;
    state = TryState(language: language);
  }

  Future<bool> start() async {
    if (state.starting) {
      return false;
    }
    state = TryState(language: state.language, starting: true);
    try {
      final InviteResponse invite = await _ref.read(apiProvider).createInvite(
            language: state.language,
            cohort: 'tryout',
          );
      _ref.read(tokenStoreProvider.notifier).setInvite(invite.inviteToken);
      state = TryState(language: state.language);
      return true;
    } on Object catch (error) {
      state = TryState(language: state.language, error: error);
      return false;
    }
  }
}
