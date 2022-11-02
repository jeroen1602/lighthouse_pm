import 'package:flutter/material.dart';

const seed = Color(0xFF6750A4);

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF005EB4),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFD3E3FF),
  onPrimaryContainer: Color(0xFF001B3C),
  secondary: Color(0xFF9000DF),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFF5D9FF),
  onSecondaryContainer: Color(0xFF2E004D),
  tertiary: Color(0xFF006C50),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFF4AFEC8),
  onTertiaryContainer: Color(0xFF002116),
  error: Color(0xFFBA1B1B),
  errorContainer: Color(0xFFFFDAD4),
  onError: Color(0xFFFFFFFF),
  onErrorContainer: Color(0xFF410001),
  background: Color(0xFFFCFCFC),
  onBackground: Color(0xFF211A1A),
  surface: Color(0xFFFCFCFC),
  onSurface: Color(0xFF211A1A),
  surfaceVariant: Color(0xFFE0E2EC),
  onSurfaceVariant: Color(0xFF44474F),
  outline: Color(0xFF74777F),
  onInverseSurface: Color(0xFFFBEEED),
  inverseSurface: Color(0xFF362F2F),
  inversePrimary: Color(0xFFA5C8FF),
  shadow: Color(0xFF000000),
);

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFFA5C8FF),
  onPrimary: Color(0xFF003062),
  primaryContainer: Color(0xFF004789),
  onPrimaryContainer: Color(0xFFD3E3FF),
  secondary: Color(0xFFE5B4FF),
  onSecondary: Color(0xFF4D007B),
  secondaryContainer: Color(0xFF6E00AC),
  onSecondaryContainer: Color(0xFFF5D9FF),
  tertiary: Color(0xFF09E0AC),
  onTertiary: Color(0xFF003828),
  tertiaryContainer: Color(0xFF00513B),
  onTertiaryContainer: Color(0xFF4AFEC8),
  error: Color(0xFFFFB4A9),
  errorContainer: Color(0xFF930006),
  onError: Color(0xFF680003),
  onErrorContainer: Color(0xFFFFDAD4),
  background: Color(0xFF211A1A),
  onBackground: Color(0xFFEDE0DF),
  surface: Color(0xFF211A1A),
  onSurface: Color(0xFFEDE0DF),
  surfaceVariant: Color(0xFF44474F),
  onSurfaceVariant: Color(0xFFC4C6CF),
  outline: Color(0xFF8D9099),
  onInverseSurface: Color(0xFF211A1A),
  inverseSurface: Color(0xFFEDE0DF),
  inversePrimary: Color(0xFF005EB4),
  shadow: Color(0xFF000000),
);

const _bootingColor = Color(0xFFEDD400);

final _lightBootingScheme = ColorScheme.fromSeed(
    seedColor: _bootingColor, brightness: Brightness.light);
final _darkBootingScheme =
    ColorScheme.fromSeed(seedColor: _bootingColor, brightness: Brightness.dark);

const _standbyColor = Color(0xFFf57900);

final _lightStandbyScheme = ColorScheme.fromSeed(
    seedColor: _standbyColor, brightness: Brightness.light);
final _darkStandbyScheme =
    ColorScheme.fromSeed(seedColor: _standbyColor, brightness: Brightness.dark);

const _sleepColor = Color(0xFF005eb4);

final _lightSleepScheme =
    ColorScheme.fromSeed(seedColor: _sleepColor, brightness: Brightness.light);
final _darkSleepScheme =
    ColorScheme.fromSeed(seedColor: _sleepColor, brightness: Brightness.dark);

const _onColor = Color(0xFF168516);

final _lightOnScheme =
    ColorScheme.fromSeed(seedColor: _onColor, brightness: Brightness.light);
final _darkOnScheme =
    ColorScheme.fromSeed(seedColor: _onColor, brightness: Brightness.dark);

final CustomColors lightCustomColors = CustomColors._(_lightBootingScheme,
    _lightStandbyScheme, _lightSleepScheme, _lightOnScheme);
final CustomColors darkCustomColors = CustomColors._(
    _darkBootingScheme, _darkStandbyScheme, _darkSleepScheme, _darkOnScheme);

class CustomColors {
  CustomColors._(
      final ColorScheme bootingScheme,
      final ColorScheme standbyScheme,
      final ColorScheme sleepScheme,
      final ColorScheme onScheme)
      : booting = bootingScheme.primary,
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
