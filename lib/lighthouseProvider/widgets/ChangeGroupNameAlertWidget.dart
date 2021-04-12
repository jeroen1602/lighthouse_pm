import 'package:flutter/material.dart';

/// A dialog for changing the name of a group.
/// Can also be used for creating a new group.
class ChangeGroupNameAlertWidget extends StatefulWidget {
  ChangeGroupNameAlertWidget({this.initialGroupName, Key? key})
      : super(key: key);

  final String? initialGroupName;

  @override
  State<ChangeGroupNameAlertWidget> createState() {
    return _ChangeGroupNameAlertWidgetContent();
  }

  /// Show the dialog
  ///
  /// Returns `null` if the user cancels the change or enters a string that
  /// is empty after trimming. Will return the new [String].
  static Future<String?> showCustomDialog(BuildContext context,
      {String? initialGroupName}) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return ChangeGroupNameAlertWidget(
            initialGroupName: initialGroupName,
          );
        }).then((value) {
      if (value is String) {
        if (value.trim().isEmpty) {
          return null;
        }
        return value;
      }
      return null;
    });
  }
}

class _ChangeGroupNameAlertWidgetContent
    extends State<ChangeGroupNameAlertWidget> {
  final textController = TextEditingController();

  @override
  void initState() {
    final name = widget.initialGroupName;
    if (name != null) {
      textController.text = name;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Group name'),
      content: TextField(
        decoration: InputDecoration(labelText: 'Group name'),
        controller: textController,
      ),
      actions: [
        SimpleDialogOption(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        SimpleDialogOption(
          child: Text(widget.initialGroupName == null ? 'Set' : 'Save'),
          onPressed: () {
            Navigator.pop(context, textController.text.trim());
          },
        ),
      ],
    );
  }
}
