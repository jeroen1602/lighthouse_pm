import 'package:flutter/material.dart';
import 'package:lighthouse_pm/color_schemes.dart';

class Theming {
  const Theming(
    this.bodyMedium,
    this.disabledBodyText,
    this.bodyTextBold,
    this.linkTheme,
    this.bodyTextIconSize,
    this.iconSizeLarge,
    this.iconColor,
    this.disabledColor,
    this.selectedRowColor,
    this.selectedAppBarColor,
    this.selectedAppBarTextColor,
    this.buttonColor,
    this.displayLarge,
    this.displayMedium,
    this.displaySmall,
    this.headlineMedium,
    this.headlineSmall,
    this.titleLarge,
    this.titleSmall,
    this.customColors,
    this.brightness,
  );

  final TextStyle? bodyMedium;
  final TextStyle? disabledBodyText;
  final TextStyle? bodyTextBold;
  final TextStyle? linkTheme;
  final double bodyTextIconSize;
  final double iconSizeLarge;

  final Color? iconColor;
  final Color disabledColor;

  // region selection:
  final Color selectedRowColor;

  final Color selectedAppBarColor;
  final Color selectedAppBarTextColor;

  final Color buttonColor;

  final TextStyle? displayLarge;
  final TextStyle? displayMedium;
  final TextStyle? displaySmall;
  final TextStyle? headlineMedium;
  final TextStyle? headlineSmall;
  final TextStyle? titleLarge;

  final TextStyle? titleSmall;

  final CustomColors customColors;
  final Brightness brightness;

  factory Theming.of(final BuildContext context) {
    return Theming.fromTheme(Theme.of(context));
  }

  factory Theming.fromTheme(final ThemeData theme) {
    final disabledColor = theme.disabledColor;

    final bodyMedium = theme.textTheme.bodyMedium;

    final disabledBodyText = bodyMedium?.copyWith(color: disabledColor);

    final bodyTextBold = bodyMedium?.copyWith(fontWeight: FontWeight.bold);

    final linkTheme = createLinkTheme(bodyMedium, theme);

    final bodyTextIconSize = (bodyMedium?.fontSize ?? 14) + 4;
    const iconSizeLarge = 24.0;

    final iconColor = getIconColor(theme.iconTheme);
    final selectedRowColor = theme.colorScheme.primary.withAlpha(
      theme.brightness == Brightness.dark ? 0x55 : 0x33,
    );
    final selectedAppBarTextColor = theme.colorScheme.onPrimary;
    final selectedAppBarColor = theme.colorScheme.primary;
    final buttonColor = theme.colorScheme.primary;

    final displayLarge = theme.textTheme.displayLarge;
    final displayMedium = theme.textTheme.displayMedium;
    final displaySmall = theme.textTheme.displaySmall;
    final headlineMedium = theme.textTheme.headlineMedium?.copyWith(
      color: bodyMedium?.color,
    );
    final headlineSmall = theme.textTheme.headlineSmall?.copyWith(
      color: bodyMedium?.color,
      fontWeight: FontWeight.bold,
    );
    final titleLarge = theme.textTheme.titleLarge?.copyWith(
      color: bodyMedium?.color,
    );

    final titleSmall = theme.textTheme.titleSmall?.copyWith(
      color: theme.disabledColor,
    );

    final customColors =
        theme.brightness == Brightness.dark
            ? darkCustomColors
            : lightCustomColors;

    return Theming(
      bodyMedium,
      disabledBodyText,
      bodyTextBold,
      linkTheme,
      bodyTextIconSize,
      iconSizeLarge,
      iconColor,
      disabledColor,
      selectedRowColor,
      selectedAppBarColor,
      selectedAppBarTextColor,
      buttonColor,
      displayLarge,
      displayMedium,
      displaySmall,
      headlineMedium,
      headlineSmall,
      titleLarge,
      titleSmall,
      customColors,
      theme.brightness,
    );
  }

  static TextStyle? createDefaultLinkTheme(final ThemeData theme) {
    return createLinkTheme(theme.textTheme.bodyMedium, theme);
  }

  static TextStyle? createLinkTheme(
    final TextStyle? input,
    final ThemeData theme,
  ) {
    return input?.copyWith(
      color: theme.colorScheme.secondary,
      decoration: TextDecoration.underline,
    );
  }

  static Color? getIconColor(final IconThemeData iconTheme) {
    final double iconOpacity = iconTheme.opacity ?? 1.0;
    Color iconColor = iconTheme.color!;
    if (iconOpacity != 1.0) {
      iconColor = iconColor.withValues(alpha: iconColor.a * iconOpacity);
    }
    return iconColor;
  }

  Color getDisabledColor(final Color original) {
    return staticGetDisabledColor(brightness, original);
  }

  Color getDisabledColorIf(final bool enabled, final Color original) {
    if (enabled) {
      return original;
    } else {
      return getDisabledColor(original);
    }
  }

  static Color staticGetDisabledColor(
    final Brightness brightness,
    final Color original,
  ) {
    return original.withAlpha(brightness == Brightness.dark ? 0x55 : 0x33);
  }
}
