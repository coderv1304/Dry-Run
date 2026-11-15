import 'package:api_client/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/providers.dart';

final FutureProvider<ScenarioGraphResponse> scenarioGraphProvider =
    FutureProvider<ScenarioGraphResponse>(
  (Ref ref) => ref.read(apiProvider).getScenarioGraph(),
);

final FutureProvider<ConfigResponse> serviceConfigProvider =
    FutureProvider<ConfigResponse>(
  (Ref ref) => ref.read(apiProvider).getConfig(),
);
