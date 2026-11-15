import 'package:flutter/material.dart';

import '../../design/dr_theme.dart';
import '../../design/space_tokens.g.dart';

/// Standard page body: safe area, centred content column, optional scroll.
class DrPage extends StatelessWidget {
  const DrPage({
    super.key,
    required this.child,
    this.scroll = true,
    this.maxWidth = DrSize.contentMax,
    this.padding = const EdgeInsets.all(DrSpace.s16),
  });

  final Widget child;
  final bool scroll;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final Widget body = Padding(
      padding: padding,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
    return Scaffold(
      backgroundColor: context.drColors.surfacePrimary,
      body: SafeArea(
        child: scroll ? SingleChildScrollView(child: body) : body,
      ),
    );
  }
}
