import 'package:flutter/material.dart';
import 'package:lighthouse_pm/lighthouseProvider/LighthouseDevice.dart';
import 'package:lighthouse_pm/lighthouseProvider/LighthousePowerState.dart';

/// An alert dialog to ask the user if they really want to enable the bluetooth
/// adapter.
class UnknownStateAlertWidget extends StatelessWidget {
  UnknownStateAlertWidget(this.device, this.currentState, {Key key}) : super(key: key);

  final LighthouseDevice device;
  final int currentState;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text('Unknown state'),
        content: Text(
            'The state of this device is unknown. What do you want to do?'),
        actions: <Widget>[
          FlatButton(
            child: Text("Start device"),
            onPressed: () {
              Navigator.pop(context, LighthousePowerState.ON);
            },
          ),
          FlatButton(
            child: Text("Shutdown device"),
            onPressed: () {
              Navigator.pop(context, LighthousePowerState.STANDBY);
            },
          ),
          FlatButton(
            child: Text("Cancel"),
            onPressed: () {
              Navigator.pop(context, null);
            },
          ),
        ]);
  }

  static Future<LighthousePowerState /* ? */ > showCustomDialog(
      BuildContext context, LighthouseDevice device, int currentState) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return UnknownStateAlertWidget(device, currentState);
        });
  }
}
