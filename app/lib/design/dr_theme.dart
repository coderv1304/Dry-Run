import 'package:flutter/material.dart';

import 'color_tokens.g.dart';
import 'space_tokens.g.dart';
import 'type_tokens.g.dart';

/// Token access for widgets. Components never read raw values.
extension DrThemeContext on BuildContext {
  DrColors get drColors =>
      Theme.of(this).brightness == Brightness.dark ? DrColors.dark : DrColors.light;

  DrTypeTheme get drType => Theme.of(this).extension<DrTypeTheme>() ?? DrTypeTheme.latin;
}

/// The one theme builder. Poppins overrides Flutter's Roboto default in
/// [ThemeData] and in every component theme below.
ThemeData drThemeData({required Brightness brightness, bool devanagari = false}) {
  final DrColors colors = brightness == Brightness.dark ? DrColors.dark : DrColors.light;
  final DrTypeTheme type = devanagari ? DrTypeTheme.devanagari : DrTypeTheme.latin;

  final ColorScheme scheme = ColorScheme(
    brightness: brightness,
    primary: colors.actionPrimary,
    onPrimary: colors.textOnAction,
    primaryContainer: colors.surfacePrimarySelected,
    onPrimaryContainer: colors.textPrimary,
    secondary: colors.actionSecondary,
    onSecondary: colors.textOnAction,
    secondaryContainer: colors.surfaceSecondary,
    onSecondaryContainer: colors.textPrimary,
    error: colors.actionError,
    onError: colors.textOnAction,
    errorContainer: colors.surfaceErrorSubtle,
    onErrorContainer: colors.textError,
    surface: colors.surfacePrimary,
    onSurface: colors.textPrimary,
    surfaceContainerLowest: colors.surfacePrimary,
    surfaceContainerLow: colors.surfaceSecondary,
    surfaceContainer: colors.surfaceSecondary,
    surfaceContainerHigh: colors.surfaceTertiary,
    surfaceContainerHighest: colors.surfaceTertiary,
    onSurfaceVariant: colors.textSecondary,
    outline: colors.borderPrimary,
    outlineVariant: colors.borderStrong,
    shadow: colors.surfaceTransparent,
    scrim: colors.overlayXl,
    inverseSurface: colors.surfaceTertiary,
    onInverseSurface: colors.textPrimary,
    inversePrimary: colors.actionPrimaryHover,
    surfaceTint: colors.surfaceTransparent,
  );

  final RoundedRectangleBorder controlShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(DrRadius.r8),
  );
  final RoundedRectangleBorder cardShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(DrRadius.r16),
    side: BorderSide(color: colors.borderPrimary, width: DrSize.strokeHairline),
  );
  final RoundedRectangleBorder sheetShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(DrRadius.r16),
  );

  ButtonStyle actionStyle({
    required Color fill,
    required Color label,
    required Color disabledFill,
    required Color disabledLabel,
    BorderSide side = BorderSide.none,
  }) {
    return ButtonStyle(
      animationDuration: Duration.zero,
      elevation: const WidgetStatePropertyAll<double>(0),
      backgroundColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) => states.contains(WidgetState.disabled) ? disabledFill : fill,
      ),
      foregroundColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) => states.contains(WidgetState.disabled) ? disabledLabel : label,
      ),
      iconColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) => states.contains(WidgetState.disabled) ? disabledLabel : label,
      ),
      overlayColor: WidgetStatePropertyAll<Color>(colors.surfaceTransparent),
      shadowColor: WidgetStatePropertyAll<Color>(colors.surfaceTransparent),
      surfaceTintColor: WidgetStatePropertyAll<Color>(colors.surfaceTransparent),
      textStyle: WidgetStatePropertyAll<TextStyle>(type.buttonMd),
      padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
        EdgeInsets.symmetric(horizontal: DrSpace.s12, vertical: DrSpace.s8),
      ),
      minimumSize: const WidgetStatePropertyAll<Size>(Size(0, DrTouch.minimum)),
      shape: WidgetStatePropertyAll<OutlinedBorder>(controlShape),
      side: WidgetStatePropertyAll<BorderSide>(side),
    );
  }

  final ButtonStyle primaryStyle = actionStyle(
    fill: colors.actionPrimary,
    label: colors.textOnAction,
    disabledFill: colors.actionPrimaryDisabled,
    disabledLabel: colors.textDisabled,
  );
  final ButtonStyle quietStyle = actionStyle(
    fill: colors.surfaceTransparent,
    label: colors.textPrimary,
    disabledFill: colors.surfaceTransparent,
    disabledLabel: colors.textDisabled,
  );
  final ButtonStyle outlinedStyle = actionStyle(
    fill: colors.surfaceTransparent,
    label: colors.textPrimary,
    disabledFill: colors.surfaceTransparent,
    disabledLabel: colors.textDisabled,
    side: BorderSide(color: colors.borderPrimary, width: DrSize.strokeHairline),
  );

  final TextTheme textTheme = TextTheme(
    displayLarge: type.heading1.copyWith(color: colors.textPrimary),
    displayMedium: type.heading2.copyWith(color: colors.textPrimary),
    displaySmall: type.heading3.copyWith(color: colors.textPrimary),
    headlineLarge: type.heading4.copyWith(color: colors.textPrimary),
    headlineMedium: type.heading5.copyWith(color: colors.textPrimary),
    headlineSmall: type.heading6.copyWith(color: colors.textPrimary),
    titleLarge: type.title1.copyWith(color: colors.textPrimary),
    titleMedium: type.title2.copyWith(color: colors.textPrimary),
    titleSmall: type.title3.copyWith(color: colors.textPrimary),
    bodyLarge: type.body3.copyWith(color: colors.textPrimary),
    bodyMedium: type.body6.copyWith(color: colors.textSecondary),
    bodySmall: type.caption2.copyWith(color: colors.textTertiary),
    labelLarge: type.buttonMd.copyWith(color: colors.textPrimary),
    labelMedium: type.buttonSm.copyWith(color: colors.textSecondary),
    labelSmall: type.caption4.copyWith(color: colors.textTertiary),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    fontFamily: DrTypeTheme.fontFamily,
    fontFamilyFallback: DrTypeTheme.fontFamilyFallback,
    scaffoldBackgroundColor: colors.surfacePrimary,
    canvasColor: colors.surfacePrimary,
    cardColor: colors.surfaceSecondary,
    dividerColor: colors.borderPrimary,
    hintColor: colors.textTertiary,
    disabledColor: colors.textDisabled,
    shadowColor: colors.surfaceTransparent,
    splashColor: colors.surfaceTransparent,
    highlightColor: colors.surfaceTransparent,
    hoverColor: colors.surfaceTransparent,
    focusColor: colors.surfaceTransparent,
    splashFactory: NoSplash.splashFactory,
    visualDensity: VisualDensity.standard,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    textTheme: textTheme,
    primaryTextTheme: textTheme,
    extensions: <ThemeExtension<dynamic>>[type],
    appBarTheme: AppBarTheme(
      backgroundColor: colors.surfacePrimary,
      foregroundColor: colors.textPrimary,
      surfaceTintColor: colors.surfaceTransparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: type.title3.copyWith(color: colors.textPrimary),
      toolbarTextStyle: type.body6.copyWith(color: colors.textSecondary),
      iconTheme: IconThemeData(color: colors.iconDefault, size: DrSize.iconLg),
      actionsIconTheme: IconThemeData(color: colors.iconSecondary, size: DrSize.iconLg),
    ),
    cardTheme: CardThemeData(
      color: colors.surfaceSecondary,
      surfaceTintColor: colors.surfaceTransparent,
      shadowColor: colors.surfaceTransparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: cardShape,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: colors.surfaceSecondary,
      surfaceTintColor: colors.surfaceTransparent,
      elevation: 0,
      shape: sheetShape,
      titleTextStyle: type.title2.copyWith(color: colors.textPrimary),
      contentTextStyle: type.body3.copyWith(color: colors.textSecondary),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colors.surfaceSecondary,
      surfaceTintColor: colors.surfaceTransparent,
      modalBackgroundColor: colors.surfaceSecondary,
      elevation: 0,
      modalElevation: 0,
      shape: sheetShape,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: colors.surfaceTertiary,
      contentTextStyle: type.body6.copyWith(color: colors.textPrimary),
      actionTextColor: colors.textLink,
      behavior: SnackBarBehavior.fixed,
      elevation: 0,
      shape: controlShape,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(style: primaryStyle),
    filledButtonTheme: FilledButtonThemeData(style: primaryStyle),
    outlinedButtonTheme: OutlinedButtonThemeData(style: outlinedStyle),
    textButtonTheme: TextButtonThemeData(style: quietStyle),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        animationDuration: Duration.zero,
        overlayColor: WidgetStatePropertyAll<Color>(colors.surfaceTransparent),
        foregroundColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) =>
              states.contains(WidgetState.disabled) ? colors.iconDisabled : colors.iconDefault,
        ),
        minimumSize: const WidgetStatePropertyAll<Size>(
          Size(DrTouch.minimum, DrTouch.minimum),
        ),
        iconSize: const WidgetStatePropertyAll<double>(DrSize.iconLg),
        shape: WidgetStatePropertyAll<OutlinedBorder>(controlShape),
      ),
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: colors.surfaceSecondary,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: DrSpace.s12,
        vertical: DrSpace.s12,
      ),
      hintStyle: type.body3.copyWith(color: colors.textTertiary),
      labelStyle: type.body4.copyWith(color: colors.textSecondary),
      floatingLabelStyle: type.caption1.copyWith(color: colors.textSecondary),
      helperStyle: type.caption2.copyWith(color: colors.textSecondary),
      errorStyle: type.caption2.copyWith(color: colors.textError),
      errorMaxLines: 3,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DrRadius.r8),
        borderSide: BorderSide(color: colors.borderPrimary, width: DrSize.strokeHairline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DrRadius.r8),
        borderSide: BorderSide(color: colors.borderPrimary, width: DrSize.strokeHairline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DrRadius.r8),
        borderSide: BorderSide(color: colors.borderFocus, width: DrSize.strokeDefault),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DrRadius.r8),
        borderSide: BorderSide(color: colors.borderDisabled, width: DrSize.strokeHairline),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DrRadius.r8),
        borderSide: BorderSide(color: colors.borderError, width: DrSize.strokeHairline),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DrRadius.r8),
        borderSide: BorderSide(color: colors.borderError, width: DrSize.strokeDefault),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: colors.surfaceSecondary,
      selectedColor: colors.surfacePrimarySelected,
      secondarySelectedColor: colors.surfacePrimarySelected,
      disabledColor: colors.surfaceDisabled,
      labelStyle: type.caption1.copyWith(color: colors.textPrimary),
      secondaryLabelStyle: type.caption1.copyWith(color: colors.textPrimary),
      side: BorderSide(color: colors.borderPrimary, width: DrSize.strokeHairline),
      shape: controlShape,
      padding: const EdgeInsets.symmetric(horizontal: DrSpace.s8, vertical: DrSpace.s4),
      labelPadding: const EdgeInsets.symmetric(horizontal: DrSpace.s4),
      elevation: 0,
      pressElevation: 0,
    ),
    dividerTheme: DividerThemeData(
      color: colors.borderPrimary,
      thickness: DrSize.strokeHairline,
      space: DrSpace.s16,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: colors.surfaceTertiary,
        borderRadius: BorderRadius.circular(DrRadius.r6),
        border: Border.all(color: colors.borderPrimary, width: DrSize.strokeHairline),
      ),
      textStyle: type.caption2.copyWith(color: colors.textPrimary),
      padding: const EdgeInsets.symmetric(horizontal: DrSpace.s8, vertical: DrSpace.s4),
      waitDuration: const Duration(milliseconds: 500),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: colors.actionPrimary,
      linearTrackColor: colors.surfaceDisabled,
      circularTrackColor: colors.surfaceDisabled,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colors.surfacePrimary,
      surfaceTintColor: colors.surfaceTransparent,
      indicatorColor: colors.surfacePrimarySelected,
      elevation: 0,
      height: DrTouch.elder,
      labelTextStyle: WidgetStatePropertyAll<TextStyle>(
        type.caption4.copyWith(color: colors.textSecondary),
      ),
      iconTheme: WidgetStatePropertyAll<IconThemeData>(
        IconThemeData(color: colors.iconDefault, size: DrSize.iconLg),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: colors.surfacePrimary,
      selectedItemColor: colors.textPrimary,
      unselectedItemColor: colors.textSecondary,
      selectedLabelStyle: type.caption4,
      unselectedLabelStyle: type.caption4,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: colors.textPrimary,
      unselectedLabelColor: colors.textSecondary,
      labelStyle: type.title3,
      unselectedLabelStyle: type.title3,
      indicatorColor: colors.borderAction,
      dividerColor: colors.borderPrimary,
      overlayColor: WidgetStatePropertyAll<Color>(colors.surfaceTransparent),
    ),
    listTileTheme: ListTileThemeData(
      titleTextStyle: type.title3.copyWith(color: colors.textPrimary),
      subtitleTextStyle: type.body6.copyWith(color: colors.textSecondary),
      leadingAndTrailingTextStyle: type.caption2.copyWith(color: colors.textTertiary),
      iconColor: colors.iconSecondary,
      textColor: colors.textPrimary,
      tileColor: colors.surfacePrimary,
      shape: controlShape,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: DrSpace.s16,
        vertical: DrSpace.s8,
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) => states.contains(WidgetState.selected)
            ? colors.actionPrimary
            : colors.surfaceTransparent,
      ),
      checkColor: WidgetStatePropertyAll<Color>(colors.iconOnAction),
      side: BorderSide(color: colors.borderPrimary, width: DrSize.strokeHairline),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DrRadius.r4)),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) => states.contains(WidgetState.selected)
            ? colors.actionPrimary
            : colors.iconSecondary,
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) => states.contains(WidgetState.selected)
            ? colors.iconOnAction
            : colors.iconSecondary,
      ),
      trackColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) => states.contains(WidgetState.selected)
            ? colors.actionPrimary
            : colors.surfaceDisabled,
      ),
      trackOutlineColor: WidgetStatePropertyAll<Color>(colors.borderPrimary),
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStatePropertyAll<Color>(colors.iconSubtle),
      radius: Radius.circular(DrRadius.r8),
      thickness: const WidgetStatePropertyAll<double>(DrSize.strokeStrong),
    ),
    iconTheme: IconThemeData(color: colors.iconDefault, size: DrSize.iconLg),
    primaryIconTheme: IconThemeData(color: colors.iconOnAction, size: DrSize.iconLg),
  );
}

/// Light and dark gallery pair, used by the debug screen and the goldens.
List<ThemeData> drThemePair({bool devanagari = false}) => <ThemeData>[
      drThemeData(brightness: Brightness.light, devanagari: devanagari),
      drThemeData(brightness: Brightness.dark, devanagari: devanagari),
    ];
