import 'initial_link.dart';
import 'initial_link_parse.dart';

/// Android and desktop have no browser fragment to clear.
InitialLink takeInitialLink() => parseFragment(Uri.base);
