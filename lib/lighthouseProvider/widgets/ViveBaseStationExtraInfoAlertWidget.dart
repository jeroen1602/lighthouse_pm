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
  final _textController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  /// Validate that the id provided is of the correct format
  ///
  /// Checks that the length is either 4 or 8.
  /// Checks that the id is parsable as HEX.
  /// Checks that the last 4 digits (lower 2 bytes) match the [widget.existingIdEnd]
  /// (if length is 8).
  String /* ? */ _validateId(String value) {
    value = value.trim().toUpperCase();
    if (value.isEmpty) {
      return 'Please enter the id';
    }
    final intValue = int.tryParse(value, radix: 16);
    if (intValue == null) {
      return 'Please use legal characters [a-fA-F0-9]';
    }
    if (value.length < 4) {
      return 'Please enter at least the first 4 characters';
    }
    if (value.length > 4 && value.length < 8) {
      return 'Please enter the rest of the id';
    }
    if (value.length == 8 && intValue & 0xFFFF != widget.existingIdEnd) {
      return 'The last 4 digits don\'t match "${widget.existingIdEnd.toRadixString(16).padLeft(4, '0').toUpperCase()}"';
    }
    if (value.length > 8) {
      return 'The length of the id must be 8 digits';
    }
    return null;
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
      content: Form(
          key: _formKey,
          child: TextFormField(
            validator: _validateId,
            onChanged: (String value) {
              _formKey.currentState.validate();
            },
            controller: _textController,
          )),
      actions: <Widget>[
        SimpleDialogOption(
          child: Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        SimpleDialogOption(
          child: Text('Set'),
          onPressed: () {
            final text = _textController.text.trim();
            if (_formKey.currentState.validate()) {
              Navigator.pop(context, text);
            }
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
