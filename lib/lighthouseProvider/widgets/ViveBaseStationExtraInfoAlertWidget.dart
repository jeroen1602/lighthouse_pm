import 'package:flutter/material.dart';

class ViveBaseStationExtraInfoAlertWidget extends StatefulWidget {
  const ViveBaseStationExtraInfoAlertWidget({Key key, this.existingIdEnd})
      : super(key: key);

  final int existingIdEnd;

  @override
  State<StatefulWidget> createState() {
    return _ViveBaseStationExtraInfoAlertState();
  }

  static Future<String /* ? */ > showCustomDialog(
      BuildContext context, int existingIdEnd) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return ViveBaseStationExtraInfoAlertWidget(
            existingIdEnd: existingIdEnd,
          );
        });
  }
}

class _ViveBaseStationExtraInfoAlertState
    extends State<ViveBaseStationExtraInfoAlertWidget> {
  final textController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: RichText(
        text: TextSpan(children: <InlineSpan>[
          TextSpan(
              style: Theme.of(context).primaryTextTheme.bodyText1,
              text: 'Base station id required.\n'),
          TextSpan(
              style: Theme.of(context).primaryTextTheme.bodyText1,
              text: 'The id is found on the back and should end with: '),
          TextSpan(
              style: Theme.of(context)
                  .primaryTextTheme
                  .bodyText1
                  .copyWith(fontWeight: FontWeight.bold),
              text: widget.existingIdEnd
                  .toRadixString(16)
                  .padLeft(4, '0')
                  .toUpperCase()),
          TextSpan(
              style: Theme.of(context).primaryTextTheme.bodyText1, text: '.'),
        ]),
      ),
      content: TextField(
        decoration: InputDecoration(labelText: 'Id'),
        controller: textController,
      ),
      actions: <Widget>[
        SimpleDialogOption(
          child: Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        SimpleDialogOption(
          child: Text('Set'),
          onPressed: () {
            final text = textController.text.trim();
            if (text.isEmpty) {
              Navigator.pop(context);
            } else {
              Navigator.pop(context, text);
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
