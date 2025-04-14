import 'package:flutter/material.dart';

/// A warning dialog for when the user wants to add 2 devices that have the
/// same channel
class DifferentGroupItemChannelAlertWidget extends StatefulWidget {
  const DifferentGroupItemChannelAlertWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return _DifferentGroupItemChannelAlertWidgetContent();
  }

  /// Show the dialog.
  ///
  /// Returns a [bool] that will be `true` if the user really wants to continue.
  /// Will be `false` if the user cancels the dialog.
  static Future<bool> showCustomDialog(final BuildContext context) {
    return showDialog(
      context: context,
      builder: (final BuildContext context) {
        return const DifferentGroupItemChannelAlertWidget();
      },
    ).then((final value) {
      if (value is bool) {
        return value;
      }
      return false;
    });
  }
}

class _DifferentGroupItemChannelAlertWidgetContent
    extends State<DifferentGroupItemChannelAlertWidget> {
  @override
  Widget build(final BuildContext context) {
    return AlertDialog(
      title: const Text('Some devices have the same channel'),
      content: const Text(
        'Some of the devices you have selected use the same channel.'
        ' This will cause problems with Steam VR, you should switch the '
        'channel from some of the devices.'
        '\nAre you sure you want to do this?',
      ),
      actions: [
        SimpleDialogOption(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
        SimpleDialogOption(
          child: const Text('I\'m sure'),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ],
    );
  }
}
