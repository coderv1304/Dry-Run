import 'dart:async';

import 'package:api_client/api_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'voice_controller.dart';
import 'voice_service.dart';

enum VoiceCheckStatus { untested, testing, pass, fail }

@immutable
class VoiceReadinessState {
  const VoiceReadinessState({
    this.microphone = VoiceCheckStatus.untested,
    this.recognitionEnglish = VoiceCheckStatus.untested,
    this.recognitionHindi = VoiceCheckStatus.untested,
    this.ttsEnglish = VoiceCheckStatus.untested,
    this.ttsHindi = VoiceCheckStatus.untested,
    this.roundTrip = VoiceCheckStatus.untested,
    this.heardEnglish,
    this.heardHindi,
    this.latency,
    this.error,
  });

  final VoiceCheckStatus microphone;
  final VoiceCheckStatus recognitionEnglish;
  final VoiceCheckStatus recognitionHindi;
  final VoiceCheckStatus ttsEnglish;
  final VoiceCheckStatus ttsHindi;
  final VoiceCheckStatus roundTrip;
  final String? heardEnglish;
  final String? heardHindi;
  final Duration? latency;
  final Object? error;

  bool get started => microphone != VoiceCheckStatus.untested ||
      recognitionEnglish != VoiceCheckStatus.untested ||
      recognitionHindi != VoiceCheckStatus.untested ||
      ttsEnglish != VoiceCheckStatus.untested ||
      ttsHindi != VoiceCheckStatus.untested ||
      roundTrip != VoiceCheckStatus.untested;

  bool get hasFailure =>
      microphone == VoiceCheckStatus.fail ||
      recognitionEnglish == VoiceCheckStatus.fail ||
      recognitionHindi == VoiceCheckStatus.fail ||
      ttsEnglish == VoiceCheckStatus.fail ||
      ttsHindi == VoiceCheckStatus.fail ||
      roundTrip == VoiceCheckStatus.fail;

  bool get allPassed =>
      microphone == VoiceCheckStatus.pass &&
      recognitionEnglish == VoiceCheckStatus.pass &&
      recognitionHindi == VoiceCheckStatus.pass &&
      ttsEnglish == VoiceCheckStatus.pass &&
      ttsHindi == VoiceCheckStatus.pass &&
      roundTrip == VoiceCheckStatus.pass;

  VoiceReadinessState copyWith({
    VoiceCheckStatus? microphone,
    VoiceCheckStatus? recognitionEnglish,
    VoiceCheckStatus? recognitionHindi,
    VoiceCheckStatus? ttsEnglish,
    VoiceCheckStatus? ttsHindi,
    VoiceCheckStatus? roundTrip,
    String? heardEnglish,
    String? heardHindi,
    Duration? latency,
    Object? error,
  }) {
    return VoiceReadinessState(
      microphone: microphone ?? this.microphone,
      recognitionEnglish: recognitionEnglish ?? this.recognitionEnglish,
      recognitionHindi: recognitionHindi ?? this.recognitionHindi,
      ttsEnglish: ttsEnglish ?? this.ttsEnglish,
      ttsHindi: ttsHindi ?? this.ttsHindi,
      roundTrip: roundTrip ?? this.roundTrip,
      heardEnglish: heardEnglish ?? this.heardEnglish,
      heardHindi: heardHindi ?? this.heardHindi,
      latency: latency ?? this.latency,
      error: error ?? this.error,
    );
  }
}

final StateNotifierProvider<VoiceReadinessController, VoiceReadinessState>
    voiceReadinessProvider =
    StateNotifierProvider<VoiceReadinessController, VoiceReadinessState>(
  (Ref ref) => VoiceReadinessController(ref),
);

/// Drives the pre-flight screen. Nothing is requested until the participant
/// presses Start, and no audio or transcript is stored anywhere.
class VoiceReadinessController extends StateNotifier<VoiceReadinessState> {
  VoiceReadinessController(this._ref) : super(const VoiceReadinessState());

  final Ref _ref;

  VoiceService get _service => _ref.read(voiceServiceProvider);
  VoicePolicy get _policy => _ref.read(voicePolicyProvider);

  Future<void> start() async {
    state = state.copyWith(microphone: VoiceCheckStatus.testing, error: null);
    try {
      bool granted = await _service.hasMicrophonePermission();
      if (!granted) {
        granted = await _service.requestMicrophonePermission();
      }
      if (!mounted) {
        return;
      }
      state = state.copyWith(
        microphone: granted ? VoiceCheckStatus.pass : VoiceCheckStatus.fail,
      );
    } on Object catch (error) {
      if (mounted) {
        state = state.copyWith(
          microphone: VoiceCheckStatus.fail,
          error: error,
        );
      }
    }
  }

  Future<void> testRecognition(AppLanguage language) async {
    final bool hindi = language != AppLanguage.en;
    state = state.copyWith(
      recognitionEnglish:
          hindi ? state.recognitionEnglish : VoiceCheckStatus.testing,
      recognitionHindi:
          hindi ? VoiceCheckStatus.testing : state.recognitionHindi,
      error: null,
    );
    String? heard;
    try {
      heard = await _service.recognizeOnce(
        localeId: hindi ? 'hi-IN' : 'en-IN',
        timeout: const Duration(seconds: 8),
      );
    } on Object catch (error) {
      if (mounted) {
        state = state.copyWith(error: error);
      }
    }
    if (!mounted) {
      return;
    }
    final VoiceCheckStatus result = (heard ?? '').trim().isEmpty
        ? VoiceCheckStatus.fail
        : VoiceCheckStatus.pass;
    state = state.copyWith(
      recognitionEnglish: hindi ? state.recognitionEnglish : result,
      recognitionHindi: hindi ? result : state.recognitionHindi,
      heardEnglish: hindi ? state.heardEnglish : heard,
      heardHindi: hindi ? heard : state.heardHindi,
    );
  }

  Future<void> testTts(AppLanguage language) async {
    final bool hindi = language != AppLanguage.en;
    state = state.copyWith(
      ttsEnglish: hindi ? state.ttsEnglish : VoiceCheckStatus.testing,
      ttsHindi: hindi ? VoiceCheckStatus.testing : state.ttsHindi,
      error: null,
    );
    final String localeId = hindi ? 'hi-IN' : 'en-IN';
    final String phrase =
        hindi ? 'यह आवाज़ की जाँच है।' : 'This is a voice test.';
    VoiceCheckStatus result = VoiceCheckStatus.fail;
    try {
      if (await _service.supportsTts(localeId)) {
        await _service.speak(text: phrase, localeId: localeId);
        result = VoiceCheckStatus.pass;
      }
    } on Object catch (error) {
      if (mounted) {
        state = state.copyWith(error: error);
      }
    }
    if (!mounted) {
      return;
    }
    state = state.copyWith(
      ttsEnglish: hindi ? state.ttsEnglish : result,
      ttsHindi: hindi ? result : state.ttsHindi,
    );
  }

  Future<void> runRoundTrip(AppLanguage language) async {
    final bool hindi = language != AppLanguage.en;
    final VoiceLocales locales = VoiceLocales.forLanguage(language);
    state = state.copyWith(roundTrip: VoiceCheckStatus.testing, error: null);
    final Stopwatch clock = Stopwatch()..start();
    String? heard;
    try {
      heard = await _service.recognizeOnce(
        localeId: locales.recognition,
        timeout: const Duration(seconds: 8),
      );
      final String spoken = (heard ?? '').trim();
      if (spoken.isEmpty) {
        clock.stop();
        if (mounted) {
          state = state.copyWith(roundTrip: VoiceCheckStatus.fail);
        }
        return;
      }
      await _service.speak(
        text: hindi ? 'आवाज़ तैयार है।' : 'Voice is ready.',
        localeId: locales.tts,
      );
    } on Object catch (error) {
      clock.stop();
      if (mounted) {
        state = state.copyWith(
          roundTrip: VoiceCheckStatus.fail,
          error: error,
        );
      }
      return;
    }
    clock.stop();
    final Duration elapsed = clock.elapsed;
    if (!mounted) {
      return;
    }
    state = state.copyWith(
      roundTrip: elapsed <= _policy.targetReply
          ? VoiceCheckStatus.pass
          : VoiceCheckStatus.fail,
      latency: elapsed,
    );
  }

  void reset() {
    state = const VoiceReadinessState();
  }
}
