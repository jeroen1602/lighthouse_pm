import 'package:flutter/material.dart';
import 'package:lighthouse_pm/color_schemes.dart';

class Theming {
  const Theming(
    this.bodyText,
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
    this.headline1,
    this.headline2,
    this.headline3,
    this.headline4,
    this.headline5,
    this.headline6,
    this.subtitle,
    this.customColors,
    this.brightness,
  );

  final TextStyle? bodyText;
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

  final TextStyle? headline1;
  final TextStyle? headline2;
  final TextStyle? headline3;
  final TextStyle? headline4;
  final TextStyle? headline5;
  final TextStyle? headline6;

  final TextStyle? subtitle;

  final CustomColors customColors;
  final Brightness brightness;

  factory Theming.of(final BuildContext context) {
    return Theming.fromTheme(Theme.of(context));
  }

  factory Theming.fromTheme(final ThemeData theme) {
    final disabledColor = theme.disabledColor;

    final bodyText = theme.textTheme.bodyText2;

    final disabledBodyText = bodyText?.copyWith(color: disabledColor);

    final bodyTextBold = bodyText?.copyWith(fontWeight: FontWeight.bold);

    final linkTheme = createLinkTheme(bodyText, theme);

    final bodyTextIconSize = (bodyText?.fontSize ?? 14) + 4;
    const iconSizeLarge = 24.0;

    final iconColor = getIconColor(theme.iconTheme);
    final selectedRowColor = theme.colorScheme.primary
        .withAlpha(theme.brightness == Brightness.dark ? 0x55 : 0x33);
    final selectedAppBarTextColor = theme.colorScheme.onPrimary;
    final selectedAppBarColor = theme.colorScheme.primary;
    final buttonColor = theme.colorScheme.primary;

    final headline1 = theme.textTheme.headline1;
    final headline2 = theme.textTheme.headline2;
    final headline3 = theme.textTheme.headline3;
    final headline4 =
        theme.textTheme.headline4?.copyWith(color: bodyText?.color);
    final headline5 = theme.textTheme.headline5
        ?.copyWith(color: bodyText?.color, fontWeight: FontWeight.bold);
    final headline6 =
        theme.textTheme.headline6?.copyWith(color: bodyText?.color);

    final subtitle =
        theme.textTheme.subtitle2?.copyWith(color: theme.disabledColor);

    final customColors = theme.brightness == Brightness.dark
        ? darkCustomColors
        : lightCustomColors;

    return Theming(
      bodyText,
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
      headline1,
      headline2,
      headline3,
      headline4,
      headline5,
      headline6,
      subtitle,
      customColors,
      theme.brightness,
    );
  }

  static TextStyle? createDefaultLinkTheme(final ThemeData theme) {
    return createLinkTheme(theme.textTheme.bodyText2, theme);
  }

  static TextStyle? createLinkTheme(
      final TextStyle? input, final ThemeData theme) {
    return input?.copyWith(
        color: theme.colorScheme.secondary,
        decoration: TextDecoration.underline);
  }

  static Color? getIconColor(final IconThemeData iconTheme) {
    final double iconOpacity = iconTheme.opacity ?? 1.0;
    Color iconColor = iconTheme.color!;
    if (iconOpacity != 1.0) {
      iconColor = iconColor.withOpacity(iconColor.opacity * iconOpacity);
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
      final Brightness brightness, final Color original) {
    return original.withAlpha(brightness == Brightness.dark ? 0x55 : 0x33);
  }
}
