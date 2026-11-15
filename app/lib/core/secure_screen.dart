import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Turns Android FLAG_SECURE on while a debrief or report is on screen. That
/// blocks screenshots and blanks the recent-tasks preview. Every other
/// platform is a no-op, so tests and web never touch a platform channel.
abstract interface class SecureScreen {
  Future<void> setSecure(bool secure);
}

class PlatformSecureScreen implements SecureScreen {
  const PlatformSecureScreen();

  static const MethodChannel _channel =
      MethodChannel('in.dryrun/secure_screen');

  @override
  Future<void> setSecure(bool secure) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return;
    }
    try {
      await _channel.invokeMethod<void>('setSecure', <String, dynamic>{
        'secure': secure,
      });
    } on Object {
      // A missing channel on an unusual build must never block the screen.
    }
  }
}
