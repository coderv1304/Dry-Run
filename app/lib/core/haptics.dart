import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Short physical confirmations at a few key moments. Android only: iOS runs
/// the app but is not a reviewed target, and the web has no haptics at all, so
/// both fall through to a no op.
abstract class DrHaptics {
  const DrHaptics();

  /// A control was accepted.
  Future<void> tap();

  /// A good moment arrived, such as a reply or a finished debrief.
  Future<void> success();

  /// Something needs attention, such as a warning or an end of drill.
  Future<void> warn();
}

class PlatformDrHaptics implements DrHaptics {
  const PlatformDrHaptics();

  bool get _enabled =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  Future<void> tap() async {
    if (!_enabled) {
      return;
    }
    await HapticFeedback.selectionClick();
  }

  @override
  Future<void> success() async {
    if (!_enabled) {
      return;
    }
    await HapticFeedback.mediumImpact();
  }

  @override
  Future<void> warn() async {
    if (!_enabled) {
      return;
    }
    await HapticFeedback.heavyImpact();
  }
}
