import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../space_tokens.g.dart';

/// Reveals a list of items in order on the base curve.
///
/// Only opacity and transform animate, the stagger is derived from the motion
/// tokens, and the whole group jumps straight to its final state when the
/// platform asks for reduced motion, so the layout never moves.
class DrRevealGroup extends StatefulWidget {
  const DrRevealGroup({
    super.key,
    required this.itemCount,
    required this.builder,
  });

  final int itemCount;
  final Widget Function(BuildContext context, int index) builder;

  @override
  State<DrRevealGroup> createState() => _DrRevealGroupState();
}

class _DrRevealGroupState extends State<DrRevealGroup>
    with SingleTickerProviderStateMixin {
  /// A quarter of the minimum motion token. Keeps the rhythm on the scale.
  static const Duration _stagger = Duration(milliseconds: 50);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _total,
  );
  bool _started = false;

  Duration get _total {
    final int gaps = widget.itemCount <= 1 ? 0 : widget.itemCount - 1;
    return DrMotion.layout + _stagger * gaps;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) {
      return;
    }
    _started = true;
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Animation<double> _interval(int index) {
    final double total = _total.inMilliseconds.toDouble();
    final double start = _stagger.inMilliseconds * index.toDouble();
    final double end = math.min(
      start + DrMotion.layout.inMilliseconds.toDouble(),
      total,
    );
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(start / total, end / total, curve: DrMotion.curve),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.itemCount == 0) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int index = 0; index < widget.itemCount; index++)
          _Reveal(
            animation: _interval(index),
            child: widget.builder(context, index),
          ),
      ],
    );
  }
}

class _Reveal extends StatelessWidget {
  const _Reveal({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: animation.drive(
          Tween<Offset>(begin: Offset(0, DrSpace.s8 / 100), end: Offset.zero),
        ),
        child: child,
      ),
    );
  }
}
