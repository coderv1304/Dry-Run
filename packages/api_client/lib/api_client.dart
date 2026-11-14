library api_client;

export 'src/models.dart';

import 'dart:convert';
import 'src/models.dart';

/// Pure Dart client for communicating with the Dry Run backend
class DryRunApiClient {
  final String baseUrl;

  const DryRunApiClient({required this.baseUrl});

  Map<String, String> _headers({
    String? inviteToken,
    String? sessionToken,
    String? reportToken,
  }) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json, application/problem+json',
    };
    if (inviteToken != null) headers['X-Invite-Token'] = inviteToken;
    if (sessionToken != null) headers['X-Session-Token'] = sessionToken;
    if (reportToken != null) headers['X-Report-Token'] = reportToken;
    return headers;
  }
}
