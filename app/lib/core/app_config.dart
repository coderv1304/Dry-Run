import 'package:flutter/foundation.dart';

/// True only when the build was started with
/// `--dart-define=DEMO_MODE=true`. Keeping this as a top level const lets the
/// compiler fold the demo branch out of a production build.
const bool kDemoMode = bool.fromEnvironment('DEMO_MODE', defaultValue: false);

/// Runtime configuration. Values come from compile time definitions so no
/// secret or host is baked into source.
@immutable
class AppConfig {
  const AppConfig({
    required this.apiBaseUrl,
    required this.publicWebUrl,
    this.demoMode = kDemoMode,
    this.debriefPollBudget = const Duration(seconds: 15),
  });

  factory AppConfig.fromEnvironment() {
    const String api = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://127.0.0.1:8000',
    );
    const String publicUrl = String.fromEnvironment(
      'PUBLIC_WEB_URL',
      defaultValue: 'http://127.0.0.1:8080/',
    );
    return AppConfig(
      apiBaseUrl: _asBase(api),
      publicWebUrl: _asBase(publicUrl),
      demoMode: kDemoMode,
    );
  }

  final Uri apiBaseUrl;
  final Uri publicWebUrl;

  /// Set only by `--dart-define=DEMO_MODE=true`. The demo uses a fixed
  /// transcript and canned debrief and never calls the network.
  final bool demoMode;
  final Duration debriefPollBudget;

  static Uri _asBase(String raw) {
    final Uri parsed = Uri.parse(raw);
    return parsed.path.endsWith('/')
        ? parsed
        : parsed.replace(path: '${parsed.path}/');
  }
}
