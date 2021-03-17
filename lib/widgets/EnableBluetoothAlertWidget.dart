import 'package:flutter/material.dart';

/// An alert dialog to ask the user if they really want to enable the bluetooth
/// adapter.
class EnableBluetoothAlertWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text('Enable Bluetooth'),
        content: Text('Do you want to enable Bluetooth?'),
        actions: <Widget>[
          SimpleDialogOption(
            child: Text("Enable Bluetooth"),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
          SimpleDialogOption(
            child: Text("Cancel"),
            onPressed: () {
              Navigator.pop(context, false);
            },
          ),
        ]);
  }

  static Future<bool?> showCustomDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return EnableBluetoothAlertWidget();
        });
  }
}
