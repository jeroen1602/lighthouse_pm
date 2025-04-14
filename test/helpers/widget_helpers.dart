import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lighthouse_pm/lighthouse_provider/helpers/custom_long_press_gesture_recognizer.dart';

typedef ButtonCallback = void Function(BuildContext context);

MaterialApp buildTestAppForWidgets(
  final ButtonCallback onPressed, {
  final String buttonText = "X",
}) {
  return buildTestApp((final context) {
    return Center(
      child: ElevatedButton(
        child: Text(buttonText),
        onPressed: () {
          return onPressed(context);
        },
      ),
    );
  });
}

MaterialApp buildTestApp(final WidgetBuilder builder) {
  return MaterialApp(home: Material(child: Builder(builder: builder)));
}

bool findTextAndTap(final InlineSpan visitor, final String text) {
  if (visitor is TextSpan && visitor.text == text) {
    (visitor.recognizer as TapGestureRecognizer).onTap!();

    return false;
  }

  return true;
}

bool tapTextSpan(final RichText richText, final String text) {
  final isTapped =
      !richText.text.visitChildren(
        (final visitor) => findTextAndTap(visitor, text),
      );

  return isTapped;
}

bool findTextAndHold(final InlineSpan visitor, final String text) {
  if (visitor is TextSpan && visitor.text == text) {
    (visitor.recognizer as CustomLongPressGestureRecognizer).onLongPress!();

    return false;
  }
  return true;
}

bool holdTextSpan(final RichText richText, final String text) {
  final hasHeld =
      !richText.text.visitChildren(
        (final visitor) => findTextAndHold(visitor, text),
      );

  return hasHeld;
}

Type typeOf<T>() => T;
