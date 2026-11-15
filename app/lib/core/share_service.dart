import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

/// Thin boundary around the OS share sheet and clipboard so widgets stay
/// testable and no screen calls a plugin directly.
abstract interface class ShareService {
  Future<void> share({required String text, required String subject});

  Future<void> copy(String text);
}

class PlatformShareService implements ShareService {
  const PlatformShareService();

  @override
  Future<void> share({required String text, required String subject}) async {
    await Share.share(text, subject: subject);
  }

  @override
  Future<void> copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }
}
