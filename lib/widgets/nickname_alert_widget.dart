import 'package:flutter/material.dart';
import 'package:lighthouse_pm/data/database.dart';
import 'package:lighthouse_pm/data/tables/nickname_table.dart';
import 'package:lighthouse_pm/theming.dart';

/// A dialog for changing the nickname of a lighthouse
class NicknameAlertWidget extends StatefulWidget {
  const NicknameAlertWidget({
    super.key,
    required this.deviceId,
    this.deviceName,
    this.nickname,
  });
  final String deviceId;
  final String? deviceName;
  final String? nickname;

  @override
  State<StatefulWidget> createState() {
    return _NicknameAlertWidget();
  }

  /// Open a dialog and return a [Nickname] with the new setting.
  /// Can return `null` if the dialog is cancelled.
  static Future<NicknamesHelper?> showCustomDialog(
    final BuildContext context, {
    required final String deviceId,
    final String? deviceName,
    final String? nickname,
  }) {
    return showDialog(
      context: context,
      builder: (final BuildContext context) {
        return NicknameAlertWidget(
          deviceId: deviceId,
          deviceName: deviceName,
          nickname: nickname,
        );
      },
    );
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
  Widget build(final BuildContext context) {
    final theming = Theming.of(context);

    return AlertDialog(
      title: RichText(
        text: TextSpan(
          style: theming.bodyMedium,
          children: <InlineSpan>[
            const TextSpan(text: "Set a nickname for "),
            TextSpan(
              style: theming.bodyTextBold,
              text: widget.deviceName ?? widget.deviceId,
            ),
            const TextSpan(text: "."),
          ],
        ),
      ),
      content: TextField(
        decoration: const InputDecoration(labelText: 'Nickname'),
        controller: textController,
      ),
      actions: <Widget>[
        SimpleDialogOption(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        SimpleDialogOption(
          child: const Text('Save'),
          onPressed: () {
            final text = textController.text.trim();
            if (text.isEmpty) {
              Navigator.pop(
                context,
                NicknamesHelper(deviceId: widget.deviceId, nickname: null),
              );
            } else {
              Navigator.pop(
                context,
                NicknamesHelper(deviceId: widget.deviceId, nickname: text),
              );
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
