import 'package:flutter/material.dart';

class ClearLastSeenAlertWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Clear last seen devices?'),
      content: Text('Are you sure you want to clear the last seen devices?\nThis is just for displaying when the app has last seen the device and has no effect on functionality.'),
      actions: <Widget>[
        SimpleDialogOption(
          child: Text('Yes'),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
        SimpleDialogOption(
          child: Text('No'),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
    );
  }

  static Future<bool /* ? */ > showCustomDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return ClearLastSeenAlertWidget();
      }
   );
  }

}
