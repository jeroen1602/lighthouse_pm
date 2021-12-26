import 'package:flutter/material.dart';
import 'package:lighthouse_pm/theming.dart';

/// A dialog for changing the nickname of a lighthouse
class DaoSimpleChangeStringAlertWidget extends StatefulWidget {
  DaoSimpleChangeStringAlertWidget({
    Key? key,
    required this.primaryKey,
    this.startValue,
  }) : super(key: key);
  final String primaryKey;
  final String? startValue;

  @override
  State<StatefulWidget> createState() {
    return _DaoSimpleChangeStringAlertWidget();
  }

  /// Open a dialog and return a [String] with the new value.
  /// Can return `null` if the dialog is cancelled.
  static Future<String?> showCustomDialog(BuildContext context,
      {required String primaryKey, String? startValue}) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return DaoSimpleChangeStringAlertWidget(
            primaryKey: primaryKey,
            startValue: startValue,
          );
        });
  }
}

class _DaoSimpleChangeStringAlertWidget
    extends State<DaoSimpleChangeStringAlertWidget> {
  final textController = TextEditingController();

  @override
  void initState() {
    final startValue = widget.startValue;
    if (startValue != null) {
      textController.text = startValue;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theming = Theming.of(context);

    return AlertDialog(
      title: RichText(
          text: TextSpan(
        style: theming.bodyText,
        children: <InlineSpan>[
          TextSpan(text: "Set a new value for "),
          TextSpan(style: theming.bodyTextBold, text: widget.primaryKey),
          TextSpan(
              text: ".\n"
                  "NOTE doing this may force the app into an illegal state."),
        ],
      )),
      content: TextField(
        decoration: InputDecoration(labelText: widget.primaryKey),
        controller: textController,
      ),
      actions: <Widget>[
        SimpleDialogOption(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        SimpleDialogOption(
          child: Text('Save'),
          onPressed: () {
            final text = textController.text;
            Navigator.pop(context, text);
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }
}