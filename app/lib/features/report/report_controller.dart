import 'package:api_client/api_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/providers.dart';
import '../../state/token_store.dart';

@immutable
class ReportState {
  const ReportState({
    this.report,
    this.loading = false,
    this.error,
    this.gone = false,
    this.missing = false,
  });

  final ReportResponse? report;
  final bool loading;
  final Object? error;
  final bool gone;
  final bool missing;
}

final StateNotifierProvider<ReportController, ReportState> reportControllerProvider =
    StateNotifierProvider<ReportController, ReportState>(
  (Ref ref) => ReportController(ref),
);

class ReportController extends StateNotifier<ReportState> {
  ReportController(this._ref) : super(const ReportState());

  final Ref _ref;

  Future<void> load() async {
    final TokenStore store = _ref.read(tokenStoreProvider);
    final String? token = store.reportToken;
    if (token == null) {
      state = const ReportState(missing: true);
      return;
    }
    if (state.loading) {
      return;
    }
    state = ReportState(report: state.report, loading: true);
    try {
      final ReportResponse report = await _ref.read(apiProvider).getReport(token);
      state = ReportState(report: report);
    } on Object catch (error) {
      final bool gone = error is ApiException && error.isUnauthorized;
      state = ReportState(gone: gone, error: gone ? null : error);
    }
  }

  void reset() {
    state = const ReportState();
  }
}
