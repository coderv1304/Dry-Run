import 'dart:async';

import 'package:dryrun/features/voice/voice_service.dart';

/// Scriptable stand-in for the phone speech stack. No platform channel, no
/// microphone, and every call is counted so a test can prove that the app did
/// not ask for the microphone before the disclosure.
class FakeVoiceService implements VoiceService {
  bool hasPermission = false;
  bool grantOnRequest = true;
  bool recognizerAvailable = true;
  Set<String> recognitionLocales = <String>{'en-IN', 'hi-IN'};
  Set<String> ttsLocales = <String>{'en-IN', 'hi-IN'};

  /// Results returned by [recognizeOnce], in order. An empty queue means the
  /// recognizer heard nothing.
  List<String?> transcripts = <String?>[];
  Object? listenError;
  Object? speakError;

  /// When set, [recognizeOnce] waits for this instead of returning at once.
  Completer<String?>? listenGate;

  int permissionChecks = 0;
  int permissionRequests = 0;
  int recognitionCalls = 0;
  int recognitionLocaleChecks = 0;
  int ttsChecks = 0;
  int speakCalls = 0;
  int stopListeningCalls = 0;
  int stopSpeakingCalls = 0;
  final List<String> spoken = <String>[];
  final List<String> listenLocales = <String>[];

  @override
  Future<bool> hasMicrophonePermission() async {
    permissionChecks += 1;
    return hasPermission;
  }

  @override
  Future<bool> requestMicrophonePermission() async {
    permissionRequests += 1;
    if (grantOnRequest) {
      hasPermission = true;
    }
    return hasPermission;
  }

  @override
  Future<bool> recognitionAvailable() async {
    recognitionCalls += 1;
    return recognizerAvailable;
  }

  @override
  Future<bool> supportsRecognition(String localeId) async {
    recognitionLocaleChecks += 1;
    return recognitionLocales.contains(localeId);
  }

  @override
  Future<bool> supportsTts(String localeId) async {
    ttsChecks += 1;
    return ttsLocales.contains(localeId);
  }

  @override
  Future<String?> recognizeOnce({
    required String localeId,
    required Duration timeout,
  }) async {
    listenLocales.add(localeId);
    final Completer<String?>? gate = listenGate;
    if (gate != null) {
      return gate.future;
    }
    final Object? failure = listenError;
    if (failure != null) {
      throw failure;
    }
    if (transcripts.isEmpty) {
      return null;
    }
    return transcripts.removeAt(0);
  }

  @override
  Future<void> speak({required String text, required String localeId}) async {
    speakCalls += 1;
    spoken.add(text);
    final Object? failure = speakError;
    if (failure != null) {
      throw failure;
    }
  }

  @override
  Future<void> stopListening() async {
    stopListeningCalls += 1;
  }

  @override
  Future<void> stopSpeaking() async {
    stopSpeakingCalls += 1;
  }
}
