import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/providers.dart';
import '../../state/token_store.dart';

@immutable
class JoinState {
  const JoinState({
    this.validating = false,
    this.error,
    this.invalidLink = false,
  });

  final bool validating;
  final Object? error;
  final bool invalidLink;
}

final StateNotifierProvider<JoinController, JoinState> joinControllerProvider =
    StateNotifierProvider<JoinController, JoinState>(
  (Ref ref) => JoinController(ref),
);

class JoinController extends StateNotifier<JoinState> {
  JoinController(this._ref) : super(const JoinState());

  final Ref _ref;

  Future<bool> validate(String raw) async {
    if (state.validating) {
      return false;
    }
    final String? token = _ref.read(linkBuilderProvider).inviteTokenFrom(raw);
    if (token == null) {
      state = const JoinState(invalidLink: true);
      return false;
    }
    state = const JoinState(validating: true);
    try {
      await _ref.read(apiProvider).getCurrentInvite(token);
      _ref.read(tokenStoreProvider.notifier).setInvite(token);
      state = const JoinState();
      return true;
    } on Object catch (error) {
      state = JoinState(error: error);
      return false;
    }
  }

  void reset() {
    state = const JoinState();
  }
}
