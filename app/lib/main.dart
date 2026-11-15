import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/app_config.dart';
import 'core/initial_link.dart';
import 'core/initial_link_platform.dart';
import 'core/url_strategy.dart';
import 'features/demo/demo_mode.dart';
import 'routing/app_router.dart';
import 'state/token_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureUrlStrategy();
  final InitialLink link = takeInitialLink();
  runApp(
    ProviderScope(
      overrides: <Override>[
        initialTokensProvider.overrideWithValue(
          InitialTokens(
            inviteToken: link.inviteToken,
            reportToken: link.reportToken,
          ),
        ),
        // kDemoMode is a const, so a production compiler removes this branch
        // and every demo string it reaches.
        if (kDemoMode) ...demoOverrides(),
      ],
      child: const _Bootstrap(),
    ),
  );
}

/// Reads the router once so a token change never rebuilds navigation.
class _Bootstrap extends ConsumerWidget {
  const _Bootstrap();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return DryRunApp(routerConfig: router);
  }
}
