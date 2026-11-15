import 'package:flutter/material.dart';

import 'color_tokens.g.dart';
import 'components/dr_banner.dart';
import 'components/dr_button.dart';
import 'components/dr_call_status.dart';
import 'components/dr_data_views.dart';
import 'components/dr_hero_heading.dart';
import 'components/dr_icon.dart';
import 'components/dr_list_row.dart';
import 'components/dr_node_line_diagram.dart';
import 'components/dr_text_field.dart';
import 'components/dr_timeline_row.dart';
import 'dr_theme.dart';
import 'icons.g.dart';
import 'space_tokens.g.dart';
import 'type_tokens.g.dart';

/// The visual spec: every token and every component state, in both modes.
class DesignGallery extends StatefulWidget {
  const DesignGallery({
    super.key,
    this.initialBrightness = Brightness.light,
    this.devanagari = false,
  });

  final Brightness initialBrightness;
  final bool devanagari;

  @override
  State<DesignGallery> createState() => _DesignGalleryState();
}

class _DesignGalleryState extends State<DesignGallery> {
  late Brightness _brightness = widget.initialBrightness;

  @override
  void didUpdateWidget(DesignGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialBrightness != widget.initialBrightness) {
      _brightness = widget.initialBrightness;
    }
  }

  void _toggle() {
    setState(() {
      _brightness =
          _brightness == Brightness.light ? Brightness.dark : Brightness.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: drThemeData(brightness: _brightness, devanagari: widget.devanagari),
      child: Builder(
        builder: (BuildContext themed) {
          final DrColors colors = themed.drColors;
          return Material(
            color: colors.surfacePrimary,
            child: Padding(
              padding: const EdgeInsets.all(DrSpace.s32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _GalleryHeader(
                    brightness: _brightness,
                    onToggle: _toggle,
                    devanagari: widget.devanagari,
                  ),
                  const SizedBox(height: DrSpace.s24),
                  const _Rule(),
                  const SizedBox(height: DrSpace.s24),
                  const _CoreColourSection(),
                  const _SemanticSection(),
                  const _SpacingSection(),
                  const _RadiusSection(),
                  const _TypeSection(),
                  const _DevanagariSection(),
                  const _MotionSection(),
                  const _ButtonSection(),
                  const _FieldSection(),
                  const _RowSection(),
                  const _TimelineSection(),
                  const _DiagramSection(),
                  const _BannerSection(),
                  const _CallStatusSection(),
                  const _DataViewSection(),
                  const _IconSection(),
                  const _HeroSection(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GalleryHeader extends StatelessWidget {
  const _GalleryHeader({
    required this.brightness,
    required this.onToggle,
    required this.devanagari,
  });

  final Brightness brightness;
  final VoidCallback onToggle;
  final bool devanagari;

  @override
  Widget build(BuildContext context) {
    final DrColors colors = context.drColors;
    final DrTypeTheme type = context.drType;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Dry Run design system',
                style: type.heading4.copyWith(color: colors.textPrimary),
              ),
              const SizedBox(height: DrSpace.s4),
              Text(
                'Every token and every component state, '
                '${brightness == Brightness.light ? 'light' : 'dark'} mode'
                '${devanagari ? ' with Devanagari leading' : ''}',
                style: type.body6.copyWith(color: colors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(width: DrSpace.s24),
        DrButton(
          label: brightness == Brightness.light ? 'Switch to dark' : 'Switch to light',
          type: DrButtonType.tertiary,
          size: DrButtonSize.sm,
          onPressed: onToggle,
        ),
      ],
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: DrSize.strokeHairline,
      color: context.drColors.borderPrimary,
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final DrColors colors = context.drColors;
    final DrTypeTheme type = context.drType;
    return Padding(
      padding: const EdgeInsets.only(bottom: DrSpace.s32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(title, style: type.title2.copyWith(color: colors.textPrimary)),
          const SizedBox(height: DrSpace.s12),
          child,
          const SizedBox(height: DrSpace.s24),
          const _Rule(),
        ],
      ),
    );
  }
}

class _Caption extends StatelessWidget {
  const _Caption(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: context.drType.caption5.copyWith(color: context.drColors.textTertiary),
    );
  }
}

class _CoreColourSection extends StatelessWidget {
  const _CoreColourSection();

  @override
  Widget build(BuildContext context) {
    final DrTypeTheme type = context.drType;
    final DrColors colors = context.drColors;
    return _Section(
      title: 'Core colours',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _Caption('one row per palette, shades 00 to 1000, 500 is the base hue'),
          const SizedBox(height: DrSpace.s8),
          for (final MapEntry<String, Map<String, Color>> palette
              in DrCore.palettes.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: DrSpace.s8),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: DrSpace.s96,
                    child: Text(
                      palette.key,
                      style: type.caption4.copyWith(color: colors.textSecondary),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        for (final MapEntry<String, Color> shade in palette.value.entries)
                          Expanded(
                            child: Container(
                              height: DrSpace.s24,
                              color: shade.value,
                              alignment: Alignment.center,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SemanticSection extends StatelessWidget {
  const _SemanticSection();

  @override
  Widget build(BuildContext context) {
    final DrColors colors = context.drColors;
    final DrTypeTheme type = context.drType;
    return _Section(
      title: 'Semantic colours',
      child: Wrap(
        spacing: DrSpace.s16,
        runSpacing: DrSpace.s8,
        children: <Widget>[
          for (final String name in DrColors.lightByName.keys)
            SizedBox(
              width: DrSpace.s96 + DrSpace.s72,
              child: Row(
                children: <Widget>[
                  Container(
                    width: DrSpace.s16,
                    height: DrSpace.s16,
                    decoration: BoxDecoration(
                      color: DrColors.lightByName[name],
                      borderRadius: BorderRadius.circular(DrRadius.r2),
                      border: Border.all(
                        color: colors.borderPrimary,
                        width: DrSize.strokeHairline,
                      ),
                    ),
                  ),
                  const SizedBox(width: DrSpace.s2),
                  Container(
                    width: DrSpace.s16,
                    height: DrSpace.s16,
                    decoration: BoxDecoration(
                      color: DrColors.darkByName[name],
                      borderRadius: BorderRadius.circular(DrRadius.r2),
                      border: Border.all(
                        color: colors.borderPrimary,
                        width: DrSize.strokeHairline,
                      ),
                    ),
                  ),
                  const SizedBox(width: DrSpace.s4),
                  Expanded(
                    child: Text(
                      name,
                      style: type.caption5.copyWith(color: colors.textSecondary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SpacingSection extends StatelessWidget {
  const _SpacingSection();

  @override
  Widget build(BuildContext context) {
    final DrColors colors = context.drColors;
    final DrTypeTheme type = context.drType;
    return _Section(
      title: 'Spacing',
      child: Wrap(
        spacing: DrSpace.s16,
        runSpacing: DrSpace.s8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          for (final double value in DrSpace.scale)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: value == 0 ? DrSize.strokeHairline : value,
                  height: DrSpace.s8,
                  color: colors.actionPrimary,
                ),
                const SizedBox(width: DrSpace.s4),
                Text(
                  value.toInt().toString(),
                  style: type.caption5.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _RadiusSection extends StatelessWidget {
  const _RadiusSection();

  @override
  Widget build(BuildContext context) {
    final DrColors colors = context.drColors;
    final DrTypeTheme type = context.drType;
    return _Section(
      title: 'Radius',
      child: Wrap(
        spacing: DrSpace.s16,
        runSpacing: DrSpace.s8,
        children: <Widget>[
          for (final double value in <double>[...DrRadius.scale, DrRadius.full])
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: DrSpace.s48,
                  height: DrSpace.s48,
                  decoration: BoxDecoration(
                    color: colors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(value),
                    border: Border.all(
                      color: colors.borderPrimary,
                      width: DrSize.strokeHairline,
                    ),
                  ),
                ),
                const SizedBox(height: DrSpace.s4),
                Text(
                  value == DrRadius.full ? 'full' : value.toInt().toString(),
                  style: type.caption5.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _TypeSection extends StatelessWidget {
  const _TypeSection();

  @override
  Widget build(BuildContext context) {
    final DrColors colors = context.drColors;
    final DrTypeTheme type = context.drType;
    return _Section(
      title: 'Text styles',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final MapEntry<String, TextStyle> entry in type.styles.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: DrSpace.s8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: <Widget>[
                  SizedBox(
                    width: DrSpace.s96 + DrSpace.s40,
                    child: Text(
                      entry.key,
                      style: type.caption5.copyWith(color: colors.textTertiary),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Drill call 45',
                      style: entry.value.copyWith(color: colors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${entry.value.fontSize?.toInt()} / ${(entry.value.fontSize! * entry.value.height!).round()} w${entry.value.fontWeight!.value}',
                    style: type.caption5.copyWith(color: colors.textTertiary),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DevanagariSection extends StatelessWidget {
  const _DevanagariSection();

  @override
  Widget build(BuildContext context) {
    final DrColors colors = context.drColors;
    final DrTypeTheme hindi = DrTypeTheme.devanagari;
    return _Section(
      title: 'Hindi leading',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'ड्रिल कॉल शुरू होगी',
            style: hindi.heading5.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: DrSpace.s8),
          Text(
            'लाइन पर बने रहें और तुरंत फोन काटें',
            style: hindi.body3.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: DrSpace.s8),
          Text(
            'बैंक खाता ४५',
            style: hindi.caption2.copyWith(color: colors.textTertiary),
          ),
        ],
      ),
    );
  }
}

class _MotionSection extends StatelessWidget {
  const _MotionSection();

  @override
  Widget build(BuildContext context) {
    final DrColors colors = context.drColors;
    final DrTypeTheme type = context.drType;
    final List<String> rows = <String>[
      'curve ${DrMotion.curveCss}',
      'layout ${DrMotion.layout.inMilliseconds} ms',
      'colour ${DrMotion.color.inMilliseconds} ms',
      'minimum ${DrMotion.minimum.inMilliseconds} ms',
      'press ${DrMotion.press.inMilliseconds} ms at ${DrMotion.pressScale}',
      'touch ${DrTouch.minimum.toInt()} min, ${DrTouch.elder.toInt()} elder',
      'hover instant static colour swap, no transition',
    ];
    return _Section(
      title: 'Motion and touch',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final String row in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: DrSpace.s4),
              child: Text(row, style: type.caption4.copyWith(color: colors.textSecondary)),
            ),
        ],
      ),
    );
  }
}

class _ButtonSection extends StatelessWidget {
  const _ButtonSection();

  @override
  Widget build(BuildContext context) {
    final DrColors colors = context.drColors;
    final DrTypeTheme type = context.drType;
    const double column = 168;
    return _Section(
      title: 'Buttons',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              const SizedBox(width: DrSpace.s64 + DrSpace.s24),
              for (final DrState state in DrState.values)
                SizedBox(
                  width: column,
                  child: Text(
                    state.name,
                    style: type.caption5.copyWith(color: colors.textTertiary),
                  ),
                ),
            ],
          ),
          for (final DrButtonType buttonType in DrButtonType.values)
            Padding(
              padding: const EdgeInsets.only(bottom: DrSpace.s8),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: DrSpace.s64 + DrSpace.s24,
                    child: Text(
                      buttonType.name,
                      style: type.caption4.copyWith(color: colors.textSecondary),
                    ),
                  ),
                  for (final DrState state in DrState.values)
                    SizedBox(
                      width: column,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: DrButton(
                          label: 'Take drill',
                          type: buttonType,
                          size: DrButtonSize.sm,
                          stateOverride: state,
                          onPressed: state == DrState.disabled ? null : () {},
                        ),
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(height: DrSpace.s8),
          Row(
            children: <Widget>[
              SizedBox(
                width: DrSpace.s64 + DrSpace.s24,
                child: Text(
                  'sizes',
                  style: type.caption4.copyWith(color: colors.textSecondary),
                ),
              ),
              for (final DrButtonSize size in DrButtonSize.values)
                Padding(
                  padding: const EdgeInsets.only(right: DrSpace.s8),
                  child: DrButton(
                    label: size.name,
                    size: size,
                    type: DrButtonType.tertiary,
                    onPressed: () {},
                  ),
                ),
              DrButton(
                label: 'Elder target',
                type: DrButtonType.primary,
                elder: true,
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FieldSection extends StatelessWidget {
  const _FieldSection();

  @override
  Widget build(BuildContext context) {
    const double column = 320;
    return _Section(
      title: 'Text input',
      child: Wrap(
        spacing: DrSpace.s24,
        runSpacing: DrSpace.s24,
        children: <Widget>[
          SizedBox(
            width: column,
            child: const DrTextField(label: 'Your name', hint: 'As on the call'),
          ),
          SizedBox(
            width: column,
            child: const DrTextField(
              label: 'Filled',
              hint: 'Bank branch',
              filled: true,
            ),
          ),
          SizedBox(
            width: column,
            child: const DrTextField(
              label: 'Focused',
              hint: 'Mumbai',
              stateOverride: DrFieldState.focus,
            ),
          ),
          SizedBox(
            width: column,
            child: const DrTextField(
              label: 'Error',
              hint: 'Account number',
              errorText: 'Use the 11 digit account number',
            ),
          ),
          SizedBox(
            width: column,
            child: const DrTextField(
              label: 'Disabled',
              hint: 'Session closed',
              enabled: false,
            ),
          ),
        ],
      ),
    );
  }
}

class _RowSection extends StatelessWidget {
  const _RowSection();

  @override
  Widget build(BuildContext context) {
    final DrColors colors = context.drColors;
    return _Section(
      title: 'List rows',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          DrListRow(
            title: 'Drill with Amma',
            subtitle: 'Invite sent 12 minutes ago',
            leading: DrIcon(
              data: DrIcons.usersThree,
              size: DrSize.iconLg,
              color: colors.iconSecondary,
            ),
            onTap: () {},
          ),
          DrListRow(
            title: 'Hover state',
            subtitle: 'Instant static surface swap',
            stateOverride: DrState.hover,
            onTap: () {},
          ),
          DrListRow(
            title: 'Focus state',
            subtitle: 'Two pixel ring, no animation',
            stateOverride: DrState.focus,
            onTap: () {},
          ),
          DrListRow(
            title: 'Disabled state',
            subtitle: 'Session expired',
            stateOverride: DrState.disabled,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _TimelineSection extends StatelessWidget {
  const _TimelineSection();

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Timeline',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          DrTimelineRow(
            title: 'Invite sent',
            detail: 'A private link went to the participant',
            trailingLabel: 'done',
            status: DrTimelineStatus.complete,
            isLast: false,
          ),
          DrTimelineRow(
            title: 'Drill call in progress',
            detail: 'Officer line 3 of 8',
            trailingLabel: 'now',
            status: DrTimelineStatus.current,
          ),
          DrTimelineRow(
            title: 'Kind debrief',
            detail: 'Labels come from the engine, never free text',
            status: DrTimelineStatus.upcoming,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _DiagramSection extends StatelessWidget {
  const _DiagramSection();

  @override
  Widget build(BuildContext context) {
    return const _Section(
      title: 'Node and line',
      child: DrNodeLineDiagram(
        nodes: <DrDiagramNode>[
          DrDiagramNode(
            label: 'Warning call',
            detail: 'Fictional officer, fictional agency',
            status: DrDiagramStatus.done,
          ),
          DrDiagramNode(
            label: 'Pressure turn',
            detail: 'Demand for secrecy',
            status: DrDiagramStatus.active,
          ),
          DrDiagramNode(
            label: 'Debrief',
            detail: 'One habit to keep',
          ),
        ],
      ),
    );
  }
}

class _BannerSection extends StatelessWidget {
  const _BannerSection();

  @override
  Widget build(BuildContext context) {
    return const _Section(
      title: 'Banner',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          DrBanner(
            badgeLabel: 'DRILL',
            message: 'This call is practice. The officer and the agency are fictional.',
          ),
          SizedBox(height: DrSpace.s12),
          DrBanner(
            badgeLabel: 'DRILL',
            message: 'Nothing here is recorded beyond the session you delete.',
            variant: DrBannerVariant.info,
          ),
        ],
      ),
    );
  }
}

class _CallStatusSection extends StatelessWidget {
  const _CallStatusSection();

  @override
  Widget build(BuildContext context) {
    const List<(DrCallState, String)> states = <(DrCallState, String)>[
      (DrCallState.ringing, 'Ringing'),
      (DrCallState.answering, 'Answering'),
      (DrCallState.live, 'Live'),
    ];
    return _Section(
      title: 'Call status',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final (DrCallState state, String label) in states)
            Padding(
              padding: const EdgeInsets.only(bottom: DrSpace.s12),
              child: DrCallStatus(
                state: state,
                badgeLabel: 'DRILL',
                stateLabel: label,
                message:
                    'This is a practice drill. No real agency is involved.',
              ),
            ),
        ],
      ),
    );
  }
}

class _DataViewSection extends StatelessWidget {
  const _DataViewSection();

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Data views',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const DrSkeleton(lines: 3),
          const SizedBox(height: DrSpace.s24),
          DrEmptyView(
            title: 'No drill yet',
            message: 'Create a private link and the timeline starts here.',
            actionLabel: 'Create link',
            onAction: () {},
          ),
          const SizedBox(height: DrSpace.s24),
          DrErrorView(
            title: 'Session could not load',
            message: 'The invite expired. Ask the organizer for a new link.',
            retryLabel: 'Try again',
            onRetry: () {},
          ),
        ],
      ),
    );
  }
}

class _IconSection extends StatelessWidget {
  const _IconSection();

  @override
  Widget build(BuildContext context) {
    final DrColors colors = context.drColors;
    final DrTypeTheme type = context.drType;
    final List<DrIconData> icons = <DrIconData>[
      DrIcons.arrowRight,
      DrIcons.checkCircle,
      DrIcons.clipboardText,
      DrIcons.fingerprint,
      DrIcons.lockKey,
      DrIcons.phoneX,
      DrIcons.shieldCheck,
      DrIcons.timer,
      DrIcons.usersThree,
      DrIcons.warningCircle,
    ];
    return _Section(
      title: 'Icons',
      child: Wrap(
        spacing: DrSpace.s24,
        runSpacing: DrSpace.s16,
        children: <Widget>[
          for (final DrIconData icon in icons)
            SizedBox(
              width: DrSpace.s80,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  DrIcon(data: icon, size: DrSize.iconXl, color: colors.iconDefault),
                  const SizedBox(height: DrSpace.s4),
                  Text(
                    icon.name,
                    style: type.caption5.copyWith(color: colors.textTertiary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    final DrColors colors = context.drColors;
    return _Section(
      title: 'Hero heading, the only gradient',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(DrSpace.s24),
        color: colors.surfaceSecondary,
        child: const DrHeroHeading(text: 'Practice the call\nbefore it happens'),
      ),
    );
  }
}
