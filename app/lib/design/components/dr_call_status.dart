import 'package:flutter/material.dart';

import '../color_tokens.g.dart';
import '../dr_theme.dart';
import '../space_tokens.g.dart';
import '../type_tokens.g.dart';

/// The three moments of a practice call. Ringing and answering are short; live
/// is the rest of the drill.
enum DrCallState { ringing, answering, live }

/// Call status strip: the practice badge, the call state and a calm waveform.
///
/// The waveform is deliberately still. It reads as a call without pretending a
/// microphone is streaming, it costs no frames, and it never shifts layout
/// because every state keeps the same height.
class DrCallStatus extends StatelessWidget {
  const DrCallStatus({
    super.key,
    required this.state,
    required this.badgeLabel,
    required this.stateLabel,
    this.message,
  });

  final DrCallState state;
  final String badgeLabel;
  final String stateLabel;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final DrColors colors = context.drColors;
    final DrTypeTheme type = context.drType;
    return Container(
      padding: const EdgeInsets.all(DrSpace.s12),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(DrRadius.r12),
        border: Border.all(
          color: colors.borderPrimary,
          width: DrSize.strokeHairline,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _Waveform(state: state),
          const SizedBox(width: DrSpace.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Wrap(
                  spacing: DrSpace.s8,
                  runSpacing: DrSpace.s4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DrSpace.s8,
                        vertical: DrSpace.s2,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceInfoSubtle,
                        borderRadius: BorderRadius.circular(DrRadius.r4),
                        border: Border.all(
                          color: colors.borderAction,
                          width: DrSize.strokeHairline,
                        ),
                      ),
                      child: Text(
                        badgeLabel,
                        style: type.caption3.copyWith(color: colors.textInfo),
                      ),
                    ),
                    Text(
                      stateLabel,
                      style: type.caption2.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (message != null) ...<Widget>[
                  const SizedBox(height: DrSpace.s4),
                  Text(
                    message!,
                    style: type.caption2.copyWith(color: colors.textTertiary),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Waveform extends StatelessWidget {
  const _Waveform({required this.state});

  final DrCallState state;

  static const Map<DrCallState, List<double>> _heights =
      <DrCallState, List<double>>{
        DrCallState.ringing: <double>[
          DrSpace.s4,
          DrSpace.s8,
          DrSpace.s4,
          DrSpace.s8,
          DrSpace.s4,
        ],
        DrCallState.answering: <double>[
          DrSpace.s8,
          DrSpace.s16,
          DrSpace.s8,
          DrSpace.s12,
          DrSpace.s8,
        ],
        DrCallState.live: <double>[
          DrSpace.s8,
          DrSpace.s16,
          DrSpace.s24,
          DrSpace.s16,
          DrSpace.s32,
          DrSpace.s16,
          DrSpace.s8,
        ],
      };

  @override
  Widget build(BuildContext context) {
    final DrColors colors = context.drColors;
    final Color barColor = switch (state) {
      DrCallState.ringing => colors.textTertiary,
      DrCallState.answering => colors.textSecondary,
      DrCallState.live => colors.actionPrimary,
    };
    return SizedBox(
      width: DrSpace.s44,
      height: DrSpace.s32,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          for (final double height in _heights[state]!)
            Container(
              width: DrSize.strokeStrong,
              height: height,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(DrRadius.full),
              ),
            ),
        ],
      ),
    );
  }
}
