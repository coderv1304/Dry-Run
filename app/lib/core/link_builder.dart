import 'package:flutter/foundation.dart';

/// Builds the links that participants and family members open. Tokens always
/// travel in the fragment so they never reach a server in a request line.
@immutable
class LinkBuilder {
  const LinkBuilder({required this.base});

  final Uri base;

  Uri invite(String token) =>
      base.removeFragment().replace(fragment: 'token=$token');

  Uri report(String token) =>
      base.removeFragment().replace(fragment: 'report=$token');

  String? inviteTokenFrom(String raw) =>
      _extract(raw, const <String>['token', 'invite'], 'inv_');

  String? reportTokenFrom(String raw) =>
      _extract(raw, const <String>['report', 'token'], 'rep_');

  String? _extract(String raw, List<String> keys, String prefix) {
    final String value = raw.trim();
    if (value.isEmpty) {
      return null;
    }
    if (RegExp('^${RegExp.escape(prefix)}[A-Za-z0-9_-]+\$').hasMatch(value)) {
      return value;
    }
    final Uri? uri = Uri.tryParse(value);
    if (uri != null) {
      final Map<String, String> fragment = uri.fragment.isEmpty
          ? const <String, String>{}
          : Uri.splitQueryString(uri.fragment);
      final Map<String, String> query = uri.queryParameters;
      for (final String key in keys) {
        final String? candidate = fragment[key] ?? query[key];
        if (candidate != null && candidate.startsWith(prefix)) {
          return candidate;
        }
      }
      for (final String segment in uri.pathSegments.reversed) {
        if (segment.startsWith(prefix)) {
          return segment;
        }
      }
    }
    return null;
  }
}
