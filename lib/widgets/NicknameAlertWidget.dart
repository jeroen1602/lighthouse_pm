import 'package:flutter/material.dart';
import 'package:lighthouse_pm/data/Database.dart';
import 'package:lighthouse_pm/lighthouseProvider/LighthouseDevice.dart';

/// A dialog for changing the nickname of a lighthouse
class NicknameAlertWidget extends StatefulWidget {
  NicknameAlertWidget(this.device, this.nickname, {Key key}) : super(key: key);
  final LighthouseDevice device;
  final Nickname /* ? */ nickname;

  @override
  State<StatefulWidget> createState() {
    return _NicknameAlertWidget();
  }

  /// Open a dialog and return a [Nickname] with the new setting.
  /// Can return `null` if the dialog is cancelled.
  static Future<Nickname /* ? */ > showCustomDialog(BuildContext context,
      LighthouseDevice device, Nickname /* ? */ nickname) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return NicknameAlertWidget(device, nickname);
        });
  }
}

class _NicknameAlertWidget extends State<NicknameAlertWidget> {
  final textController = TextEditingController();

  @override
  void initState() {
    if (widget.nickname != null) {
      textController.text = widget.nickname.nickname;
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
              style: Theme.of(context).primaryTextTheme.bodyText1,
              text: "Set a nickname for "),
          TextSpan(
              style: Theme.of(context)
                  .primaryTextTheme
                  .bodyText1
                  .copyWith(fontWeight: FontWeight.bold),
              text: widget.device.name),
          TextSpan(
              style: Theme.of(context).primaryTextTheme.bodyText1, text: "."),
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
                  Nickname(
                      macAddress: widget.device.deviceIdentifier.toString(),
                      nickname: null));
            } else {
              Navigator.pop(
                  context,
                  Nickname(
                      macAddress: widget.device.deviceIdentifier.toString(),
                      nickname: text));
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
