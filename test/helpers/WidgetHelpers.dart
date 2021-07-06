import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lighthouse_pm/lighthouseProvider/helpers/CustomLongPressGestureRecognizer.dart';

typedef ButtonCallback = void Function(BuildContext context);

MaterialApp buildTestAppForWidgets(ButtonCallback onPressed,
    {String buttonText = "X"}) {
  return buildTestApp((context) {
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

MaterialApp buildTestApp(WidgetBuilder builder) {
  return MaterialApp(
    home: Material(
      child: Builder(builder: builder),
    ),
  );
}

bool findTextAndTap(InlineSpan visitor, String text) {
  if (visitor is TextSpan && visitor.text == text) {
    (visitor.recognizer as TapGestureRecognizer).onTap!();

    return false;
  }

  return true;
}

bool tapTextSpan(RichText richText, String text) {
  final isTapped = !richText.text.visitChildren(
    (visitor) => findTextAndTap(visitor, text),
  );

  return isTapped;
}

bool findTextAndHold(InlineSpan visitor, String text) {
  if (visitor is TextSpan && visitor.text == text) {
    (visitor.recognizer as CustomLongPressGestureRecognizer).onLongPress!();

    return false;
  }
  return true;
}

bool holdTextSpan(RichText richText, String text) {
  final hasHeld =
      !richText.text.visitChildren((visitor) => findTextAndHold(visitor, text));

  return hasHeld;
}

Type typeOf<T>() => T;
