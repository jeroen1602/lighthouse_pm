import 'package:flutter/material.dart';
import 'package:lighthouse_pm/data/Database.dart';
import 'package:lighthouse_pm/data/tables/NicknameTable.dart';

/// A dialog for changing the nickname of a lighthouse
class NicknameAlertWidget extends StatefulWidget {
  NicknameAlertWidget({
    Key? key,
    required this.macAddress,
    this.deviceName,
    this.nickname,
  }) : super(key: key);
  final String macAddress;
  final String? deviceName;
  final String? nickname;

  @override
  State<StatefulWidget> createState() {
    return _NicknameAlertWidget();
  }

  /// Open a dialog and return a [Nickname] with the new setting.
  /// Can return `null` if the dialog is cancelled.
  static Future<NicknamesHelper?> showCustomDialog(BuildContext context,
      {required String macAddress, String? deviceName, String? nickname}) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return NicknameAlertWidget(
            macAddress: macAddress,
            deviceName: deviceName,
            nickname: nickname,
          );
        });
  }
}

class _NicknameAlertWidget extends State<NicknameAlertWidget> {
  final textController = TextEditingController();

  @override
  void initState() {
    final nickname = widget.nickname;
    if (nickname != null) {
      textController.text = nickname;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: RichText(
          text: TextSpan(
        children: <InlineSpan>[
          TextSpan(
              style: Theme.of(context).textTheme.bodyText1,
              text: "Set a nickname for "),
          TextSpan(
              style: Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .copyWith(fontWeight: FontWeight.bold),
              text: widget.deviceName == null
                  ? widget.macAddress
                  : widget.deviceName),
          TextSpan(style: Theme.of(context).textTheme.bodyText1, text: "."),
        ],
      )),
      content: TextField(
        decoration: InputDecoration(labelText: 'Nickname'),
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
            final text = textController.text.trim();
            if (text.isEmpty) {
              Navigator.pop(context,
                  NicknamesHelper(macAddress: widget.macAddress, nickname: null));
            } else {
              Navigator.pop(context,
                  NicknamesHelper(macAddress: widget.macAddress, nickname: text));
            }
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
