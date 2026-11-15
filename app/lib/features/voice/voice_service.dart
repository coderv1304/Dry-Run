import 'dart:async';

import 'package:api_client/api_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// The locales a session uses. Hinglish has no separate recognition model, so
/// it uses the Hindi voice and Hindi recognizer.
@immutable
class VoiceLocales {
  const VoiceLocales({required this.recognition, required this.tts});

  final String recognition;
  final String tts;

  static VoiceLocales forLanguage(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return const VoiceLocales(recognition: 'en-IN', tts: 'en-IN');
      case AppLanguage.hi:
      case AppLanguage.hinglish:
        return const VoiceLocales(recognition: 'hi-IN', tts: 'hi-IN');
    }
  }
}

/// Everything the app needs from the phone speech stack. Tests implement this
/// with a fake so no platform channel or microphone is involved.
abstract interface class VoiceService {
  Future<bool> hasMicrophonePermission();
  Future<bool> requestMicrophonePermission();
  Future<bool> recognitionAvailable();
  Future<bool> supportsRecognition(String localeId);
  Future<bool> supportsTts(String localeId);

  /// Listens once and returns the final transcript, or null when nothing was
  /// heard, permission is missing, or the recognizer failed.
  Future<String?> recognizeOnce({
    required String localeId,
    required Duration timeout,
  });

  /// Resolves when the phone starts speaking. Throws when speech is not
  /// available or the language is missing.
  Future<void> speak({required String text, required String localeId});

  Future<void> stopListening();
  Future<void> stopSpeaking();
}

/// Android and iOS implementation. Nothing is written to storage, and the
/// microphone is initialized only after the participant opts in.
class DeviceVoiceService implements VoiceService {
  DeviceVoiceService();

  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _speechReady = false;
  bool _ttsReady = false;
  bool _permissionAsked = false;
  Completer<String?>? _listening;
  String _lastTranscript = '';

  Future<bool> _ensureSpeech() async {
    if (_speechReady) {
      return true;
    }
    try {
      _speechReady = await _speech.initialize(
        onError: (SpeechRecognitionError error) {
          _completeListening(null);
        },
        onStatus: (String status) {
          if (status == SpeechToText.doneStatus ||
              status == SpeechToText.notListeningStatus) {
            _completeListening(_lastTranscript);
          }
        },
        // Bluetooth is not needed and asking for it would add another
        // runtime permission on Android 12 and later.
        options: <SpeechConfigOption>[SpeechToText.androidNoBluetooth],
      );
    } on Object {
      _speechReady = false;
    }
    return _speechReady;
  }

  @override
  Future<bool> hasMicrophonePermission() async {
    try {
      return await _speech.hasPermission;
    } on Object {
      return false;
    }
  }

  @override
  Future<bool> requestMicrophonePermission() async {
    if (_permissionAsked) {
      return hasMicrophonePermission();
    }
    _permissionAsked = true;
    // Initializing asks Android for RECORD_AUDIO. This is the only place the
    // system prompt can appear.
    final bool ready = await _ensureSpeech();
    return ready && await hasMicrophonePermission();
  }

  @override
  Future<bool> recognitionAvailable() async {
    if (!await _ensureSpeech()) {
      return false;
    }
    try {
      return _speech.isAvailable;
    } on Object {
      return false;
    }
  }

  @override
  Future<bool> supportsRecognition(String localeId) async {
    if (!await _ensureSpeech()) {
      return false;
    }
    try {
      final List<LocaleName> locales = await _speech.locales();
      final String wanted = localeId.toLowerCase().replaceAll('_', '-');
      final String language = wanted.split('-').first;
      return locales.any((LocaleName locale) {
        final String id = locale.localeId.toLowerCase().replaceAll('_', '-');
        return id == wanted || id.split('-').first == language;
      });
    } on Object {
      return false;
    }
  }

  Future<bool> _ensureTts() async {
    if (_ttsReady) {
      return true;
    }
    try {
      await _tts.setSpeechRate(0.45);
      await _tts.setVolume(1);
      await _tts.setPitch(1);
      _ttsReady = true;
    } on Object {
      _ttsReady = false;
    }
    return _ttsReady;
  }

  @override
  Future<bool> supportsTts(String localeId) async {
    if (!await _ensureTts()) {
      return false;
    }
    try {
      final Object? available = await _tts.isLanguageAvailable(localeId);
      return available == true || available == 1;
    } on Object {
      return false;
    }
  }

  @override
  Future<String?> recognizeOnce({
    required String localeId,
    required Duration timeout,
  }) async {
    if (!await _ensureSpeech() || !await hasMicrophonePermission()) {
      return null;
    }
    // Cancel first: the plugin emits a not-listening status for the old
    // session, and that must not complete the new completer.
    try {
      await _speech.cancel();
    } on Object {
      // No recognizer attached.
    }
    _lastTranscript = '';
    final Completer<String?> completer = Completer<String?>();
    _listening = completer;
    try {
      await _speech.listen(
        onResult: (SpeechRecognitionResult result) {
          _lastTranscript = result.recognizedWords;
          if (result.finalResult) {
            _completeListening(_lastTranscript);
          }
        },
        listenOptions: SpeechListenOptions(
          localeId: localeId,
          listenFor: timeout,
          pauseFor: const Duration(seconds: 2),
          partialResults: true,
          cancelOnError: true,
        ),
      );
    } on Object {
      _completeListening(null);
    }
    return completer.future.timeout(
      timeout + const Duration(seconds: 2),
      onTimeout: () {
        unawaited(stopListening());
        return null;
      },
    );
  }

  void _completeListening(String? text) {
    final Completer<String?>? completer = _listening;
    _listening = null;
    if (completer == null || completer.isCompleted) {
      return;
    }
    final String trimmed = (text ?? '').trim();
    completer.complete(trimmed.isEmpty ? null : trimmed);
  }

  @override
  Future<void> speak({required String text, required String localeId}) async {
    final String trimmed = text.trim();
    if (trimmed.isEmpty) {
      return;
    }
    if (!await _ensureTts() || !await supportsTts(localeId)) {
      throw StateError('Speech is not available for $localeId');
    }
    final Completer<void> started = Completer<void>();
    _tts.setStartHandler(() {
      if (!started.isCompleted) {
        started.complete();
      }
    });
    _tts.setErrorHandler((dynamic message) {
      if (!started.isCompleted) {
        started.completeError(StateError('Speech failed'));
      }
    });
    try {
      await _tts.stop();
      await _tts.setLanguage(localeId);
      final Object? result = await _tts.speak(trimmed, focus: true);
      if (result == 0) {
        throw StateError('Speech did not start');
      }
    } on Object {
      if (!started.isCompleted) {
        started.completeError(StateError('Speech failed'));
      }
    }
    // A platform that never fires the start handler still queues the audio.
    // Wait briefly for the handler, then report success so the drill is not
    // blocked by a missing callback.
    return started.future.timeout(
      const Duration(seconds: 3),
      onTimeout: () {},
    );
  }

  @override
  Future<void> stopListening() async {
    try {
      await _speech.stop();
    } on Object {
      // No recognizer attached.
    }
    _completeListening(_lastTranscript);
  }

  @override
  Future<void> stopSpeaking() async {
    try {
      await _tts.stop();
    } on Object {
      // No speech engine attached.
    }
  }
}
