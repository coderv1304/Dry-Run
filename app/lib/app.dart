import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'l10n/app_localizations.dart';
import 'state/providers.dart';

/// Builds the MaterialApp. The router and theme are injected so the rest of
/// the app only depends on this one root widget.
class DryRunApp extends ConsumerWidget {
  const DryRunApp({
    super.key,
    required this.routerConfig,
  });

  final RouterConfig<Object> routerConfig;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Locale? locale = ref.watch(localeOverrideProvider);

    return MaterialApp.router(
      title: 'Dry Run',
      debugShowCheckedModeBanner: false,
      theme: ref.watch(drThemeProvider).light,
      darkTheme: ref.watch(drThemeProvider).dark,
      themeMode: ThemeMode.system,
      routerConfig: routerConfig,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (BuildContext context, Widget? child) {
        // Respect the platform text scale but cap it at 200 percent so a
        // control never clips while still honouring the accessibility ask.
        final MediaQueryData media = MediaQuery.of(context);
        final double scale = media.textScaler.scale(1);
        final double capped = scale > 2 ? 2 : scale;
        return MediaQuery(
          data: media.copyWith(textScaler: TextScaler.linear(capped)),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
