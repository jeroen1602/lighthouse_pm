import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
    this.buttonColor,
    this.headline1,
    this.headline2,
    this.headline3,
    this.headline4,
    this.headline5,
    this.headline6,
    this.subtitle,
  );

  final TextStyle? bodyText;
  final TextStyle? disabledBodyText;
  final TextStyle? bodyTextBold;
  final TextStyle? linkTheme;
  final double bodyTextIconSize;
  final double iconSizeLarge;

  final Color? iconColor;
  final Color disabledColor;
  final Color selectedRowColor;
  final Color buttonColor;

  final TextStyle? headline1;
  final TextStyle? headline2;
  final TextStyle? headline3;
  final TextStyle? headline4;
  final TextStyle? headline5;
  final TextStyle? headline6;

  final TextStyle? subtitle;

  factory Theming.of(BuildContext context) {
    return Theming.fromTheme(Theme.of(context));
  }

  factory Theming.fromTheme(ThemeData theme) {
    final disabledColor = theme.disabledColor;

    final bodyText = theme.textTheme.bodyText2;

    final disabledBodyText = bodyText?.copyWith(color: disabledColor);

    final bodyTextBold = bodyText?.copyWith(fontWeight: FontWeight.bold);

    final linkTheme = createLinkTheme(bodyText, theme);

    final bodyTextIconSize = (bodyText?.fontSize ?? 14) + 4;
    final iconSizeLarge = 24.0;

    final iconColor = getIconColor(theme.iconTheme);
    final selectedRowColor = theme.selectedRowColor;
    final buttonColor = theme.buttonColor;

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
        buttonColor,
        headline1,
        headline2,
        headline3,
        headline4,
        headline5,
        headline6,
        subtitle);
  }

  static TextStyle? createDefaultLinkTheme(ThemeData theme) {
    return createLinkTheme(theme.textTheme.bodyText2, theme);
  }

  static TextStyle? createLinkTheme(TextStyle? input, ThemeData theme) {
    return input?.copyWith(
        color: theme.accentColor, decoration: TextDecoration.underline);
  }

  static Color? getIconColor(IconThemeData iconTheme) {
    final double iconOpacity = iconTheme.opacity ?? 1.0;
    Color iconColor = iconTheme.color!;
    if (iconOpacity != 1.0) {
      iconColor = iconColor.withOpacity(iconColor.opacity * iconOpacity);
    }
    return iconColor;
  }
}
