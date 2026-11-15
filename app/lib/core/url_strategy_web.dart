import 'package:flutter_web_plugins/url_strategy.dart';

/// Real paths, not hash routes, so every route is a shareable URL.
void configureUrlStrategy() => usePathUrlStrategy();
