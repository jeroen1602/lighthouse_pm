import 'package:flutter/material.dart';

const seed = Color(0xFF6750A4);

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xff3f5f90),
  surfaceTint: Color(0xff3f5f90),
  onPrimary: Color(0xffffffff),
  primaryContainer: Color(0xffd5e3ff),
  onPrimaryContainer: Color(0xff001b3c),
  secondary: Color(0xff725188),
  onSecondary: Color(0xffffffff),
  secondaryContainer: Color(0xfff3daff),
  onSecondaryContainer: Color(0xff2a0c40),
  tertiary: Color(0xff1b6b51),
  onTertiary: Color(0xffffffff),
  tertiaryContainer: Color(0xffa6f2d2),
  onTertiaryContainer: Color(0xff002116),
  error: Color(0xff904a43),
  onError: Color(0xffffffff),
  errorContainer: Color(0xffffdad6),
  onErrorContainer: Color(0xff3b0907),
  surface: Color(0xfff5fafb),
  onSurface: Color(0xff171d1e),
  onSurfaceVariant: Color(0xff43474e),
  outline: Color(0xff74777f),
  outlineVariant: Color(0xffc4c6cf),
  shadow: Color(0xff000000),
  scrim: Color(0xff000000),
  inverseSurface: Color(0xff2b3133),
  inversePrimary: Color(0xffa8c8ff),
  primaryFixed: Color(0xffd5e3ff),
  onPrimaryFixed: Color(0xff001b3c),
  primaryFixedDim: Color(0xffa8c8ff),
  onPrimaryFixedVariant: Color(0xff254777),
  secondaryFixed: Color(0xfff3daff),
  onSecondaryFixed: Color(0xff2a0c40),
  secondaryFixedDim: Color(0xffdfb8f7),
  onSecondaryFixedVariant: Color(0xff593a6f),
  tertiaryFixed: Color(0xffa6f2d2),
  onTertiaryFixed: Color(0xff002116),
  tertiaryFixedDim: Color(0xff8ad6b6),
  onTertiaryFixedVariant: Color(0xff00513b),
  surfaceDim: Color(0xffd5dbdc),
  surfaceBright: Color(0xfff5fafb),
  surfaceContainerLowest: Color(0xffffffff),
  surfaceContainerLow: Color(0xffeff5f6),
  surfaceContainer: Color(0xffe9eff0),
  surfaceContainerHigh: Color(0xffe3e9ea),
  surfaceContainerHighest: Color(0xffdee3e5),
);

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xffa8c8ff),
  surfaceTint: Color(0xffa8c8ff),
  onPrimary: Color(0xff05305f),
  primaryContainer: Color(0xff254777),
  onPrimaryContainer: Color(0xffd5e3ff),
  secondary: Color(0xffdfb8f7),
  onSecondary: Color(0xff412356),
  secondaryContainer: Color(0xff593a6f),
  onSecondaryContainer: Color(0xfff3daff),
  tertiary: Color(0xff8ad6b6),
  onTertiary: Color(0xff003828),
  tertiaryContainer: Color(0xff00513b),
  onTertiaryContainer: Color(0xffa6f2d2),
  error: Color(0xffffb4ab),
  onError: Color(0xff561e19),
  errorContainer: Color(0xff73332d),
  onErrorContainer: Color(0xffffdad6),
  surface: Color(0xff0e1415),
  onSurface: Color(0xffdee3e5),
  onSurfaceVariant: Color(0xffc4c6cf),
  outline: Color(0xff8e9199),
  outlineVariant: Color(0xff43474e),
  shadow: Color(0xff000000),
  scrim: Color(0xff000000),
  inverseSurface: Color(0xffdee3e5),
  inversePrimary: Color(0xff3f5f90),
  primaryFixed: Color(0xffd5e3ff),
  onPrimaryFixed: Color(0xff001b3c),
  primaryFixedDim: Color(0xffa8c8ff),
  onPrimaryFixedVariant: Color(0xff254777),
  secondaryFixed: Color(0xfff3daff),
  onSecondaryFixed: Color(0xff2a0c40),
  secondaryFixedDim: Color(0xffdfb8f7),
  onSecondaryFixedVariant: Color(0xff593a6f),
  tertiaryFixed: Color(0xffa6f2d2),
  onTertiaryFixed: Color(0xff002116),
  tertiaryFixedDim: Color(0xff8ad6b6),
  onTertiaryFixedVariant: Color(0xff00513b),
  surfaceDim: Color(0xff0e1415),
  surfaceBright: Color(0xff343a3b),
  surfaceContainerLowest: Color(0xff090f10),
  surfaceContainerLow: Color(0xff171d1e),
  surfaceContainer: Color(0xff1b2122),
  surfaceContainerHigh: Color(0xff252b2c),
  surfaceContainerHighest: Color(0xff303637),
);

const _bootingColor = Color(0xFFEDD400);

final _lightBootingScheme = ColorScheme.fromSeed(
  seedColor: _bootingColor,
  brightness: Brightness.light,
);
final _darkBootingScheme = ColorScheme.fromSeed(
  seedColor: _bootingColor,
  brightness: Brightness.dark,
);

const _standbyColor = Color(0xFFf57900);

final _lightStandbyScheme = ColorScheme.fromSeed(
  seedColor: _standbyColor,
  brightness: Brightness.light,
);
final _darkStandbyScheme = ColorScheme.fromSeed(
  seedColor: _standbyColor,
  brightness: Brightness.dark,
);

const _sleepColor = Color(0xFF005eb4);

final _lightSleepScheme = ColorScheme.fromSeed(
  seedColor: _sleepColor,
  brightness: Brightness.light,
);
final _darkSleepScheme = ColorScheme.fromSeed(
  seedColor: _sleepColor,
  brightness: Brightness.dark,
);

const _onColor = Color(0xFF168516);

final _lightOnScheme = ColorScheme.fromSeed(
  seedColor: _onColor,
  brightness: Brightness.light,
);
final _darkOnScheme = ColorScheme.fromSeed(
  seedColor: _onColor,
  brightness: Brightness.dark,
);

final CustomColors lightCustomColors = CustomColors._(
  _lightBootingScheme,
  _lightStandbyScheme,
  _lightSleepScheme,
  _lightOnScheme,
);
final CustomColors darkCustomColors = CustomColors._(
  _darkBootingScheme,
  _darkStandbyScheme,
  _darkSleepScheme,
  _darkOnScheme,
);

class CustomColors {
  CustomColors._(
    final ColorScheme bootingScheme,
    final ColorScheme standbyScheme,
    final ColorScheme sleepScheme,
    final ColorScheme onScheme,
  ) : booting = bootingScheme.primary,
      onBooting = bootingScheme.onPrimary,
      bootingContainer = bootingScheme.primaryContainer,
      onBootingContainer = bootingScheme.onPrimaryContainer,
      bootingSurface = bootingScheme.surface,
      onBootingSurface = bootingScheme.onSurface,
      standby = standbyScheme.primary,
      onStandby = standbyScheme.onPrimary,
      standbyContainer = standbyScheme.primaryContainer,
      onStandbyContainer = standbyScheme.onPrimaryContainer,
      standbySurface = standbyScheme.surface,
      onStandbySurface = standbyScheme.onSurface,
      sleep = sleepScheme.primary,
      onSleep = sleepScheme.onPrimary,
      sleepContainer = sleepScheme.primaryContainer,
      onSleepContainer = sleepScheme.onPrimaryContainer,
      sleepSurface = sleepScheme.surface,
      onSleepSurface = sleepScheme.onSurface,
      on = onScheme.primary,
      onOn = onScheme.onPrimary,
      onContainer = onScheme.primaryContainer,
      onOnContainer = onScheme.onPrimaryContainer,
      onSurface = onScheme.surface,
      onOnSurface = onScheme.onSurface;

  final Color booting;

  final Color onBooting;

  final Color bootingContainer;

  final Color onBootingContainer;

  final Color bootingSurface;

  final Color onBootingSurface;

  final Color standby;

  final Color onStandby;

  final Color standbyContainer;

  final Color onStandbyContainer;

  final Color standbySurface;

  final Color onStandbySurface;

  final Color sleep;

  final Color onSleep;

  final Color sleepContainer;

  final Color onSleepContainer;

  final Color sleepSurface;

  final Color onSleepSurface;

  final Color on;

  final Color onOn;

  final Color onContainer;

  final Color onOnContainer;

  final Color onSurface;

  final Color onOnSurface;
}
