import 'package:flutter/material.dart';
import 'package:lighthouse_pm/data/Database.dart';

class DeleteGroupAlertWidget extends StatelessWidget {
  DeleteGroupAlertWidget({required this.group, Key? key}) : super(key: key);

  Group group;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme.bodyText1;

    return AlertDialog(
      title: Text('Delete group'),
      content: RichText(
        text: TextSpan(children: <InlineSpan>[
          TextSpan(
              style: textTheme,
              text: "Are you sure you want to delete the group "),
          TextSpan(
              style: textTheme?.copyWith(fontWeight: FontWeight.bold),
              text: "${group.name}"),
          TextSpan(style: textTheme, text: '?')
        ]),
      ),
      actions: [
        SimpleDialogOption(
          child: Text('No'),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
        SimpleDialogOption(
          child: Text('Yes'),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ],
    );
  }

  /// Show a dialog asking the user if they are sure if they want to delete
  /// the device.
  static Future<bool> showCustomDialog(BuildContext context,
      {required Group group}) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return DeleteGroupAlertWidget(
            group: group,
          );
        }).then((value) {
      if (value is bool) {
        return value;
      }
      return false;
    });
  }
}
