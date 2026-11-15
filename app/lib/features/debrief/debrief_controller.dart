import 'package:api_client/api_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/providers.dart';
import '../../state/token_store.dart';
import '../session/session_controller.dart';

const Object _keep = Object();

@immutable
class DebriefState {
  const DebriefState({
    this.response,
    this.loading = false,
    this.polling = false,
    this.error,
    this.missing = false,
    this.sharing = false,
    this.shareError,
    this.sharedUrl,
    this.deleting = false,
    this.deleteError,
    this.deleted = false,
  });

  final DebriefResponse? response;
  final bool loading;
  final bool polling;
  final Object? error;
  final bool missing;
  final bool sharing;
  final Object? shareError;
  final String? sharedUrl;
  final bool deleting;
  final Object? deleteError;
  final bool deleted;

  DebriefContent? get content => response?.debrief;

  DebriefState copyWith({
    DebriefResponse? response,
    bool? loading,
    bool? polling,
    Object? error = _keep,
    bool? missing,
    bool? sharing,
    Object? shareError = _keep,
    String? sharedUrl,
    bool? deleting,
    Object? deleteError = _keep,
    bool? deleted,
  }) {
    return DebriefState(
      response: response ?? this.response,
      loading: loading ?? this.loading,
      polling: polling ?? this.polling,
      error: identical(error, _keep) ? this.error : error,
      missing: missing ?? this.missing,
      sharing: sharing ?? this.sharing,
      shareError: identical(shareError, _keep) ? this.shareError : shareError,
      sharedUrl: sharedUrl ?? this.sharedUrl,
      deleting: deleting ?? this.deleting,
      deleteError: identical(deleteError, _keep) ? this.deleteError : deleteError,
      deleted: deleted ?? this.deleted,
    );
  }
}

final StateNotifierProvider<DebriefController, DebriefState> debriefControllerProvider =
    StateNotifierProvider<DebriefController, DebriefState>(
  (Ref ref) => DebriefController(ref),
);

class DebriefController extends StateNotifier<DebriefState> {
  DebriefController(this._ref) : super(const DebriefState());

  static const List<Duration> _pollSchedule = <Duration>[
    Duration(milliseconds: 400),
    Duration(milliseconds: 800),
    Duration(milliseconds: 1600),
    Duration(milliseconds: 3000),
    Duration(milliseconds: 4600),
    Duration(milliseconds: 4600),
  ];

  final Ref _ref;
  bool _running = false;

  Future<void> load() async {
    if (_running || state.deleted) {
      return;
    }
    final TokenStore store = _ref.read(tokenStoreProvider);
    if (!store.hasSession) {
      state = const DebriefState(missing: true);
      return;
    }
    _running = true;
    state = state.copyWith(
      loading: state.response == null,
      polling: false,
      missing: false,
      error: null,
    );
    try {
      DebriefResponse response = await _ref.read(apiProvider).getDebrief(
            sessionId: store.sessionId!,
            sessionToken: store.sessionToken!,
          );
      if (!mounted) {
        return;
      }
      state = state.copyWith(response: response, loading: false, error: null);
      if (_needsFull(response)) {
        state = state.copyWith(polling: true);
        await _pollForFull(store);
      }
    } on Object catch (error) {
      if (mounted) {
        state = state.copyWith(loading: false, polling: false, error: error);
      }
    } finally {
      _running = false;
    }
  }

  bool _needsFull(DebriefResponse response) {
    final DebriefContent? content = response.debrief;
    return content == null || content.quality != DebriefQuality.full;
  }

  Future<void> _pollForFull(TokenStore store) async {
    final Duration budget = _ref.read(appConfigProvider).debriefPollBudget;
    final Future<void> Function(Duration) delay = _ref.read(pollDelayProvider);
    Duration used = Duration.zero;
    for (final Duration wait in _pollSchedule) {
      if (used + wait > budget) {
        break;
      }
      await delay(wait);
      used += wait;
      if (!mounted) {
        return;
      }
      try {
        final DebriefResponse response = await _ref.read(apiProvider).getDebrief(
              sessionId: store.sessionId!,
              sessionToken: store.sessionToken!,
            );
        if (!mounted) {
          return;
        }
        state = state.copyWith(response: response, error: null);
        if (!_needsFull(response)) {
          state = state.copyWith(polling: false);
          return;
        }
      } on Object catch (error) {
        if (mounted) {
          state = state.copyWith(polling: false, error: error);
        }
        return;
      }
    }
    if (mounted) {
      state = state.copyWith(polling: false);
    }
  }

  Future<String?> share() async {
    final TokenStore store = _ref.read(tokenStoreProvider);
    if (!store.hasSession || state.sharing) {
      return null;
    }
    state = state.copyWith(sharing: true, shareError: null, sharedUrl: null);
    try {
      final ShareResponse response = await _ref.read(apiProvider).shareSession(
            sessionId: store.sessionId!,
            sessionToken: store.sessionToken!,
            consent: true,
          );
      _ref.read(tokenStoreProvider.notifier).setReport(response.reportToken);
      final String url =
          _ref.read(linkBuilderProvider).report(response.reportToken).toString();
      state = state.copyWith(sharing: false, sharedUrl: url);
      return url;
    } on Object catch (error) {
      state = state.copyWith(sharing: false, shareError: error);
      return null;
    }
  }

  Future<bool> delete() async {
    final TokenStore store = _ref.read(tokenStoreProvider);
    if (!store.hasSession || state.deleting) {
      return false;
    }
    state = state.copyWith(deleting: true, deleteError: null);
    try {
      await _ref.read(apiProvider).deleteSession(
            sessionId: store.sessionId!,
            sessionToken: store.sessionToken!,
          );
      _ref.read(tokenStoreProvider.notifier).clearSessionAndReport();
      _ref.read(sessionControllerProvider.notifier).reset();
      state = const DebriefState(deleted: true);
      return true;
    } on Object catch (error) {
      state = state.copyWith(deleting: false, deleteError: error);
      return false;
    }
  }

  void reset() {
    state = const DebriefState();
  }
}
