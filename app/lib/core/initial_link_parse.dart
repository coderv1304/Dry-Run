import 'initial_link.dart';

InitialLink parseFragment(Uri uri) {
  final String fragment = uri.fragment;
  if (fragment.isEmpty) {
    return InitialLink.none;
  }
  final Map<String, String> values = Uri.splitQueryString(fragment);
  final String? report = values['report'];
  final String? invite = values['token'] ?? values['invite'];
  return InitialLink(
    inviteToken: _clean(invite),
    reportToken: _clean(report),
  );
}

String? _clean(String? value) {
  if (value == null) {
    return null;
  }
  final String trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
