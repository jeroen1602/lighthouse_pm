import 'package:flutter/material.dart';
import 'package:lighthouse_pm/data/database.dart';
import 'package:lighthouse_pm/theming.dart';

class DeleteGroupAlertWidget extends StatelessWidget {
  const DeleteGroupAlertWidget({required this.group, final Key? key})
      : super(key: key);

  final Group group;

  @override
  Widget build(final BuildContext context) {
    final theming = Theming.of(context);

    return AlertDialog(
      title: const Text('Delete group'),
      content: RichText(
        text: TextSpan(style: theming.bodyMedium, children: <InlineSpan>[
          const TextSpan(text: "Are you sure you want to delete the group "),
          TextSpan(style: theming.bodyTextBold, text: group.name),
          const TextSpan(text: '?')
        ]),
      ),
      actions: [
        SimpleDialogOption(
          child: const Text('No'),
          onPressed: () {
            Navigator.pop(context, false);
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

  /// Show a dialog asking the user if they are sure if they want to delete
  /// the device.
  static Future<bool> showCustomDialog(final BuildContext context,
      {required final Group group}) {
    return showDialog(
        context: context,
        builder: (final BuildContext context) {
          return DeleteGroupAlertWidget(
            group: group,
          );
        }).then((final value) {
      if (value is bool) {
        return value;
      }
      return false;
    });
  }
}
