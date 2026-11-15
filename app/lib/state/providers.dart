import 'package:api_client/api_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../core/app_config.dart';
import '../core/haptics.dart';
import '../core/link_builder.dart';
import '../core/secure_screen.dart';
import '../core/share_service.dart';
import '../design/dr_theme.dart';

final Provider<AppConfig> appConfigProvider =
    Provider<AppConfig>((Ref ref) => AppConfig.fromEnvironment());

final Provider<DryRunApi> apiProvider = Provider<DryRunApi>((Ref ref) {
  final AppConfig config = ref.watch(appConfigProvider);
  return DryRunApiClient(baseUrl: config.apiBaseUrl.toString());
});

/// One UUID per logical turn. Tests replace this with a deterministic sequence.
final Provider<String Function()> turnIdProvider =
    Provider<String Function()>((Ref ref) => const Uuid().v4);

final Provider<LinkBuilder> linkBuilderProvider = Provider<LinkBuilder>((Ref ref) {
  final AppConfig config = ref.watch(appConfigProvider);
  return LinkBuilder(base: kIsWeb ? Uri.base : config.publicWebUrl);
});

final Provider<ShareService> shareServiceProvider =
    Provider<ShareService>((Ref ref) => const PlatformShareService());

/// FLAG_SECURE bridge. Tests replace this with a recording fake.
final Provider<SecureScreen> secureScreenProvider =
    Provider<SecureScreen>((Ref ref) => const PlatformSecureScreen());

/// Short Android haptics at key drill moments. Tests replace this with a fake.
final Provider<DrHaptics> hapticsProvider =
    Provider<DrHaptics>((Ref ref) => const PlatformDrHaptics());

/// Language chosen for the current invite. Voice recognition and speech use
/// it, and Hinglish maps to the Hindi voice because it has no separate model.
final StateProvider<AppLanguage> sessionLanguageProvider =
    StateProvider<AppLanguage>((Ref ref) => AppLanguage.en);

/// The debrief poll delay is injectable so tests never wait in real time.
final Provider<Future<void> Function(Duration)> pollDelayProvider =
    Provider<Future<void> Function(Duration)>(
  (Ref ref) => (Duration duration) => Future<void>.delayed(duration),
);

final StateProvider<Locale?> localeOverrideProvider =
    StateProvider<Locale?>((Ref ref) => null);

/// Theme pair for light and dark. Kept with the shared providers so every test
/// can build the same themes without reaching into the design gallery.
class DrThemePair {
  const DrThemePair({required this.light, required this.dark});

  final ThemeData light;
  final ThemeData dark;
}

final Provider<DrThemePair> drThemeProvider = Provider<DrThemePair>((Ref ref) {
  return DrThemePair(
    light: drThemeData(brightness: Brightness.light),
    dark: drThemeData(brightness: Brightness.dark),
  );
});
