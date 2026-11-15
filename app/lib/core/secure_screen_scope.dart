import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/providers.dart';
import 'secure_screen.dart';

/// Wraps a route that shows a transcript, debrief, or shared report and holds
/// FLAG_SECURE for exactly as long as that route is mounted.
class SecureScreenScope extends ConsumerStatefulWidget {
  const SecureScreenScope({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SecureScreenScope> createState() => _SecureScreenScopeState();
}

class _SecureScreenScopeState extends ConsumerState<SecureScreenScope> {
  SecureScreen? _screen;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final SecureScreen screen = ref.read(secureScreenProvider);
    _screen = screen;
    screen.setSecure(true);
  }

  @override
  void deactivate() {
    _screen?.setSecure(false);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
