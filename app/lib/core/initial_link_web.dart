import 'package:web/web.dart' as web;

import 'initial_link.dart';
import 'initial_link_parse.dart';

/// Reads the invite or report token from the URL fragment, then removes the
/// fragment with history.replaceState so the token is not left in the address
/// bar, history, or any copied link.
InitialLink takeInitialLink() {
  final Uri current = Uri.parse(web.window.location.href);
  final InitialLink link = parseFragment(current);
  if (link.hasToken) {
    final String clean = current.removeFragment().toString();
    web.window.history.replaceState(null, '', clean);
  }
  return link;
}
