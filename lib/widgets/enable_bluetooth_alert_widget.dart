import 'package:flutter/material.dart';

/// An alert dialog to ask the user if they really want to enable the bluetooth
/// adapter.
class EnableBluetoothAlertWidget extends StatelessWidget {
  const EnableBluetoothAlertWidget({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context) {
    return AlertDialog(
        title: const Text('Enable Bluetooth'),
        content: const Text('Do you want to enable Bluetooth?'),
        actions: <Widget>[
          SimpleDialogOption(
            child: const Text("Cancel"),
            onPressed: () {
              Navigator.pop(context, false);
            },
          ),
          SimpleDialogOption(
            child: const Text("Enable Bluetooth"),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
        ]);
  }

  static Future<bool> showCustomDialog(final BuildContext context) async {
    return await showDialog<bool?>(
            context: context,
            builder: (final BuildContext context) {
              return const EnableBluetoothAlertWidget();
            }) ??
        false;
  }
}
