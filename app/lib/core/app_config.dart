import 'package:flutter/foundation.dart';

/// Runtime configuration. Values come from compile time definitions so no
/// secret or host is baked into source.
@immutable
class AppConfig {
  const AppConfig({
    required this.apiBaseUrl,
    required this.publicWebUrl,
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
    );
  }

  final Uri apiBaseUrl;
  final Uri publicWebUrl;
  final Duration debriefPollBudget;

  static Uri _asBase(String raw) {
    final Uri parsed = Uri.parse(raw);
    return parsed.path.endsWith('/')
        ? parsed
        : parsed.replace(path: '${parsed.path}/');
  }
}
