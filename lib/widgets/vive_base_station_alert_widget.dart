import 'package:flutter/material.dart';

/// Show a warning to the user about support still being in beta.
class ViveBaseStationBetaAlertWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Vive Base station support is still in beta'),
      content:
          Text('The support for the Vive Base station is still in beta and '
              'has no guarantee of working correctly.\n'
              'Are you sure you want to enable this?'),
      actions: <Widget>[
        SimpleDialogOption(
          child: Text('No'),
          onPressed: () => Navigator.pop(context),
        ),
        SimpleDialogOption(
          child: Text('Yes'),
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );
  }

  static Future<bool> showCustomDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return ViveBaseStationBetaAlertWidget();
        }).then((value) {
      if (value == null) {
        return false;
      }
      return value;
    });
  }
}

/// Show a warning about clearing all set ids.
class ViveBaseStationClearIds extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text('Delete all base station ids?'),
        content: Text('Are you sure you want to clear saved Base station ids?\n'
            'You will need to input the id again if you want to use the Base station.'),
        actions: <Widget>[
          SimpleDialogOption(
            child: Text('No'),
            onPressed: () => Navigator.pop(context),
          ),
          SimpleDialogOption(
            child: Text('Yes'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ]);
  }

  static Future<bool> showCustomDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return ViveBaseStationClearIds();
        }).then((value) {
      if (value == null) {
        return false;
      }
      return value;
    });
  }
}
