import 'package:flutter/material.dart';

/// A dialog for changing the name of a group.
/// Can also be used for creating a new group.
class ChangeGroupNameAlertWidget extends StatefulWidget {
  const ChangeGroupNameAlertWidget({this.initialGroupName, super.key});

  final String? initialGroupName;

  @override
  State<ChangeGroupNameAlertWidget> createState() {
    return _ChangeGroupNameAlertWidgetContent();
  }

  /// Show the dialog
  ///
  /// Returns `null` if the user cancels the change or enters a string that
  /// is empty after trimming. Will return the new [String].
  static Future<String?> showCustomDialog(final BuildContext context,
      {final String? initialGroupName}) {
    return showDialog(
        context: context,
        builder: (final BuildContext context) {
          return ChangeGroupNameAlertWidget(
            initialGroupName: initialGroupName,
          );
        }).then((final value) {
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
  Widget build(final BuildContext context) {
    return AlertDialog(
      title: const Text('Group name'),
      content: TextField(
        decoration: const InputDecoration(labelText: 'Group name'),
        controller: textController,
      ),
      actions: [
        SimpleDialogOption(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.pop(context, null);
          },
        ),
        SimpleDialogOption(
          child: Text(widget.initialGroupName == null ? 'Set' : 'Save'),
          onPressed: () {
            final text = textController.text.trim();
            if (text.isEmpty) {
              Navigator.pop(context, null);
            } else {
              Navigator.pop(context, text);
            }
          },
        ),
      ],
    );
  }
}
