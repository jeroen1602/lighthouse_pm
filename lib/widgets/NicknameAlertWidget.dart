import 'package:flutter/material.dart';
import 'package:lighthouse_pm/data/Database.dart';
import 'package:lighthouse_pm/data/tables/NicknameTable.dart';

/// A dialog for changing the nickname of a lighthouse
class NicknameAlertWidget extends StatefulWidget {
  NicknameAlertWidget({
    Key? key,
    required this.deviceId,
    this.deviceName,
    this.nickname,
  }) : super(key: key);
  final String deviceId;
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
            deviceId: macAddress,
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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme.bodyText1;

    return AlertDialog(
      title: RichText(
          text: TextSpan(
        children: <InlineSpan>[
          TextSpan(style: textTheme, text: "Set a nickname for "),
          TextSpan(
              style: textTheme?.copyWith(fontWeight: FontWeight.bold),
              text: widget.deviceName == null
                  ? widget.deviceId
                  : widget.deviceName),
          TextSpan(style: textTheme, text: "."),
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
              Navigator.pop(
                  context,
                  NicknamesHelper(
                      deviceId: widget.deviceId, nickname: null));
            } else {
              Navigator.pop(
                  context,
                  NicknamesHelper(
                      deviceId: widget.deviceId, nickname: text));
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
