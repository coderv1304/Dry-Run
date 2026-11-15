import 'package:flutter/foundation.dart';

/// Tokens read from the launch URL fragment. They are held in memory only and
/// never written to storage, cookies, or the address bar after boot.
@immutable
class InitialLink {
  const InitialLink({this.inviteToken, this.reportToken});

  static const InitialLink none = InitialLink();

  final String? inviteToken;
  final String? reportToken;

  bool get hasToken => inviteToken != null || reportToken != null;
}
