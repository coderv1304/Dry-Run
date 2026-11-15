import 'dart:async';

import 'package:api_client/api_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../session/session_controller.dart';
import 'voice_service.dart';

/// Time budgets for a voice turn. Tests replace this with tiny values so a
/// timeout can be exercised without waiting in real time.
@immutable
class VoicePolicy {
  const VoicePolicy({
    this.listenTimeout = const Duration(seconds: 8),
    this.replyTimeout = const Duration(seconds: 12),
    this.fillerDelay = const Duration(milliseconds: 700),
    this.targetReply = const Duration(seconds: 2),
  });

  final Duration listenTimeout;
  final Duration replyTimeout;
  final Duration fillerDelay;
  final Duration targetReply;
}

enum VoicePhase { off, preparing, ready, listening, thinking, speaking, fallback }

enum VoiceProblem {
  none,
  permissionDenied,
  recognizerMissing,
  languageMissing,
  ttsMissing,
  listenFailed,
  replyFailed,
  replyTimeout,
  speechFailed,
  unavailable,
}

@immutable
class VoiceState {
  const VoiceState({
    this.enabled = false,
    this.phase = VoicePhase.off,
    this.problem = VoiceProblem.none,
    this.transcript,
    this.lastRoundTrip,
    this.overBudget = false,
  });

  final bool enabled;
  final VoicePhase phase;
  final VoiceProblem problem;
  final String? transcript;
  final Duration? lastRoundTrip;
  final bool overBudget;

  bool get busy =>
      phase == VoicePhase.preparing ||
      phase == VoicePhase.listening ||
      phase == VoicePhase.thinking ||
      phase == VoicePhase.speaking;

  VoiceState copyWith({
    bool? enabled,
    VoicePhase? phase,
    VoiceProblem? problem,
    String? transcript,
    bool clearTranscript = false,
    Duration? lastRoundTrip,
    bool? overBudget,
  }) {
    return VoiceState(
      enabled: enabled ?? this.enabled,
      phase: phase ?? this.phase,
      problem: problem ?? this.problem,
      transcript: clearTranscript ? null : (transcript ?? this.transcript),
      lastRoundTrip: lastRoundTrip ?? this.lastRoundTrip,
      overBudget: overBudget ?? this.overBudget,
    );
  }
}

final Provider<VoiceService> voiceServiceProvider =
    Provider<VoiceService>((Ref ref) => DeviceVoiceService());

final Provider<VoicePolicy> voicePolicyProvider =
    Provider<VoicePolicy>((Ref ref) => const VoicePolicy());

final StateNotifierProvider<VoiceController, VoiceState> voiceControllerProvider =
    StateNotifierProvider<VoiceController, VoiceState>(
  (Ref ref) => VoiceController(ref),
);

/// Owns the per-session voice opt-in and a single voice turn. Every failure
/// lands back in a usable chat: this controller never disables typing and it
/// never blocks End drill because [halt] returns immediately.
class VoiceController extends StateNotifier<VoiceState> {
  VoiceController(this._ref) : super(const VoiceState());

  final Ref _ref;
  int _generation = 0;

  VoicePolicy get _policy => _ref.read(voicePolicyProvider);
  VoiceService get _service => _ref.read(voiceServiceProvider);

  Future<void> enable(AppLanguage language) async {
    if (state.busy) {
      return;
    }
    final int generation = ++_generation;
    state = const VoiceState(phase: VoicePhase.preparing);
    final VoiceLocales locales = VoiceLocales.forLanguage(language);
    try {
      bool granted = await _service.hasMicrophonePermission();
      if (!granted) {
        granted = await _service.requestMicrophonePermission();
      }
      if (!granted) {
        _failOff(VoiceProblem.permissionDenied);
        return;
      }
      if (!await _service.recognitionAvailable()) {
        _failOff(VoiceProblem.recognizerMissing);
        return;
      }
      if (!await _service.supportsRecognition(locales.recognition)) {
        _failOff(VoiceProblem.languageMissing);
        return;
      }
      if (!await _service.supportsTts(locales.tts)) {
        _failOff(VoiceProblem.ttsMissing);
        return;
      }
      if (!mounted || generation != _generation) {
        return;
      }
      state = const VoiceState(enabled: true, phase: VoicePhase.ready);
    } on Object {
      _failOff(VoiceProblem.unavailable);
    }
  }

  void _failOff(VoiceProblem problem) {
    if (!mounted) {
      return;
    }
    state = VoiceState(phase: VoicePhase.off, problem: problem);
  }

  /// Listens for one reply, sends it through the same chat controller, then
  /// speaks the officer line. Any voice failure falls back to chat.
  Future<void> listenTurn({
    required AppLanguage language,
    required String fillerLine,
  }) async {
    if (!state.enabled || state.busy) {
      return;
    }
    final VoiceLocales locales = VoiceLocales.forLanguage(language);
    final int generation = ++_generation;
    state = state.copyWith(
      phase: VoicePhase.listening,
      problem: VoiceProblem.none,
      clearTranscript: true,
      overBudget: false,
    );
    String? transcript;
    try {
      transcript = await _service.recognizeOnce(
        localeId: locales.recognition,
        timeout: _policy.listenTimeout,
      );
    } on Object {
      transcript = null;
    }
    if (!mounted || generation != _generation) {
      return;
    }
    final String spoken = (transcript ?? '').trim();
    if (spoken.isEmpty) {
      state = state.copyWith(
        phase: VoicePhase.ready,
        problem: VoiceProblem.listenFailed,
      );
      return;
    }
    state = state.copyWith(
      phase: VoicePhase.thinking,
      transcript: spoken,
      problem: VoiceProblem.none,
    );
    final Stopwatch clock = Stopwatch()..start();
    unawaited(_maybeFiller(generation, fillerLine, locales.tts));
    bool sent = false;
    try {
      sent = await _ref
          .read(sessionControllerProvider.notifier)
          .send(spoken)
          .timeout(_policy.replyTimeout);
    } on TimeoutException {
      _generation++;
      await _service.stopSpeaking();
      if (mounted) {
        state = state.copyWith(
          phase: VoicePhase.ready,
          problem: VoiceProblem.replyTimeout,
        );
      }
      return;
    } on Object {
      sent = false;
    }
    _generation++;
    await _service.stopSpeaking();
    if (!mounted) {
      return;
    }
    if (!sent) {
      state = state.copyWith(
        phase: VoicePhase.ready,
        problem: VoiceProblem.replyFailed,
      );
      return;
    }
    final String? reply = _ref
        .read(sessionControllerProvider)
        .lastTurn
        ?.officerLine
        ?.speak;
    if (reply == null || reply.trim().isEmpty) {
      state = state.copyWith(phase: VoicePhase.ready);
      return;
    }
    final Duration elapsed = clock.elapsed;
    state = state.copyWith(
      phase: VoicePhase.speaking,
      lastRoundTrip: elapsed,
      overBudget: elapsed > _policy.targetReply,
    );
    try {
      await _service.speak(text: reply, localeId: locales.tts);
    } on Object {
      if (!mounted) {
        return;
      }
      state = state.copyWith(
        enabled: false,
        phase: VoicePhase.fallback,
        problem: VoiceProblem.speechFailed,
      );
      return;
    }
    if (mounted) {
      state = state.copyWith(phase: VoicePhase.ready);
    }
  }

  Future<void> _maybeFiller(
    int generation,
    String fillerLine,
    String localeId,
  ) async {
    await Future<void>.delayed(_policy.fillerDelay);
    if (!mounted || generation != _generation) {
      return;
    }
    if (state.phase != VoicePhase.thinking) {
      return;
    }
    try {
      await _service.speak(text: fillerLine, localeId: localeId);
    } on Object {
      // A filler is an optimisation. If it cannot speak, the chat still works.
    }
  }

  Future<void> stopListening() async {
    await _service.stopListening();
  }

  void halt() {
    if (!mounted) {
      return;
    }
    _generation++;
    state = const VoiceState();
    final VoiceService service = _service;
    unawaited(service.stopListening());
    unawaited(service.stopSpeaking());
  }

  void clearProblem() {
    state = state.copyWith(problem: VoiceProblem.none, phase: VoicePhase.off);
  }
}
