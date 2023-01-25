import 'package:flutter/material.dart';

class ClearLastSeenAlertWidget extends StatelessWidget {
  const ClearLastSeenAlertWidget({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context) {
    return AlertDialog(
      title: const Text('Clear last seen devices?'),
      content:
          const Text('Are you sure you want to clear the last seen devices?\n'
              'This is just for displaying when the app has last seen the '
              'device and has no effect on functionality.'),
      actions: <Widget>[
        SimpleDialogOption(
          child: const Text('No'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        SimpleDialogOption(
          child: const Text('Yes'),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ],
    );
  }

  static Future<bool> showCustomDialog(final BuildContext context) async {
    return await showDialog<bool?>(
            context: context,
            builder: (final BuildContext context) {
              return const ClearLastSeenAlertWidget();
            }) ??
        false;
  }
}
