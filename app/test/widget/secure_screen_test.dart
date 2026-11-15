import 'package:dryrun/core/secure_screen.dart';
import 'package:dryrun/core/secure_screen_scope.dart';
import 'package:dryrun/state/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingSecureScreen implements SecureScreen {
  final List<bool> calls = <bool>[];

  @override
  Future<void> setSecure(bool secure) async {
    calls.add(secure);
  }
}

void main() {
  testWidgets('a secure route turns FLAG_SECURE on and clears it on leave',
      (WidgetTester tester) async {
    final _RecordingSecureScreen screen = _RecordingSecureScreen();
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        secureScreenProvider.overrideWithValue(screen),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: SecureScreenScope(child: Text('debrief')),
        ),
      ),
    );
    await tester.pump();

    expect(screen.calls, <bool>[true]);
    expect(find.text('debrief'), findsOneWidget);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: SizedBox.shrink()),
      ),
    );
    await tester.pump();

    expect(screen.calls.last, isFalse);
    expect(find.text('debrief'), findsNothing);
  });
}
