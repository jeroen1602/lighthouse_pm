import 'package:flutter/material.dart';

/// Show a warning to the user about support still being in beta.
class ViveBaseStationBetaAlertWidget extends StatelessWidget {
  const ViveBaseStationBetaAlertWidget({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context) {
    return AlertDialog(
      title: const Text('Vive Base station support is still in beta'),
      content: const Text(
          'The support for the Vive Base station is still in beta and '
          'has no guarantee of working correctly.\n'
          'Are you sure you want to enable this?'),
      actions: <Widget>[
        SimpleDialogOption(
          child: const Text('No'),
          onPressed: () => Navigator.pop(context),
        ),
        SimpleDialogOption(
          child: const Text('Yes'),
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );
  }

  static Future<bool> showCustomDialog(final BuildContext context) {
    return showDialog(
        context: context,
        builder: (final BuildContext context) {
          return const ViveBaseStationBetaAlertWidget();
        }).then((final value) {
      if (value == null) {
        return false;
      }
      return value;
    });
  }
}

/// Show a warning about clearing all set ids.
class ViveBaseStationClearIds extends StatelessWidget {
  const ViveBaseStationClearIds({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context) {
    return AlertDialog(
        title: const Text('Delete all base station ids?'),
        content: const Text(
            'Are you sure you want to clear saved Base station ids?\n'
            'You will need to input the id again if you want to use the Base station.'),
        actions: <Widget>[
          SimpleDialogOption(
            child: const Text('No'),
            onPressed: () => Navigator.pop(context),
          ),
          SimpleDialogOption(
            child: const Text('Yes'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ]);
  }

  static Future<bool> showCustomDialog(final BuildContext context) {
    return showDialog(
        context: context,
        builder: (final BuildContext context) {
          return const ViveBaseStationClearIds();
        }).then((final value) {
      if (value == null) {
        return false;
      }
      return value;
    });
  }
}
