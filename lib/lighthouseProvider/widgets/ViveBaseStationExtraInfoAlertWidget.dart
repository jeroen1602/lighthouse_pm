import 'package:flutter/material.dart';

class ViveBaseStationExtraInfoAlertWidget extends StatefulWidget {
  const ViveBaseStationExtraInfoAlertWidget(
      {Key? key, required this.existingIdEnd})
      : super(key: key);

  final int? existingIdEnd;

  @override
  State<StatefulWidget> createState() {
    return _ViveBaseStationExtraInfoAlertState();
  }

  static Future<String?> showCustomDialog(
      BuildContext context, int? existingIdEnd) {
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
  String? _validateId(String? value) {
    if (value == null) {
      value = "";
    }
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
    if (value.length > 8) {
      return 'The length of the id must be 8 digits';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final endHint = widget.existingIdEnd;

    final textTheme = Theme.of(context).textTheme;
    final boldTheme =
        textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold);

    return AlertDialog(
      title: RichText(
        text: TextSpan(style: textTheme.bodyText1, children: <InlineSpan>[
          TextSpan(text: 'Base station id required.\n'),
          if (endHint != null) ...[
            TextSpan(
                text:
                    'The id is found on the back and will probably end with: '),
            TextSpan(
                style: boldTheme,
                text: endHint.toRadixString(16).padLeft(4, '0').toUpperCase()),
            TextSpan(text: '.'),
          ] else
            TextSpan(text: 'The id is found on the back.')
        ]),
      ),
      content: Form(
          key: _formKey,
          child: TextFormField(
            validator: _validateId,
            onChanged: (String value) {
              _formKey.currentState?.validate();
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
          onPressed: () async {
            final text = _textController.text.trim().toUpperCase();
            if (_formKey.currentState?.validate() == true) {
              if (endHint != null) {
                final intValue = int.parse(text, radix: 16);
                if (text.length == 8 && intValue & 0xFFFF != endHint) {
                  if (!(await ViveBaseStationExtraInfoIdWarningAlertWidget
                      .showCustomDialog(context,
                          setId: text, existingIdEnd: endHint))) {
                    // The user doesn't want to close yet.
                    return;
                  }
                }
              }
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

class ViveBaseStationExtraInfoIdWarningAlertWidget extends StatelessWidget {
  ViveBaseStationExtraInfoIdWarningAlertWidget(
      {required this.setId, required this.existingIdEnd, Key? key})
      : super(key: key);

  final String setId;
  final int existingIdEnd;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final boldTheme =
        textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold);

    return AlertDialog(
      title: Text("The end of the id doesn't match"),
      content: RichText(
        text: TextSpan(style: textTheme.bodyText1, children: [
          TextSpan(text: "The id you have provided ("),
          TextSpan(text: '$setId', style: boldTheme),
          TextSpan(
              text: ") doesn't end the same as the end of your lighthouse's "
                  "name ("),
          TextSpan(
              style: boldTheme,
              text: existingIdEnd
                  .toRadixString(16)
                  .padLeft(4, '0')
                  .toUpperCase()),
          TextSpan(
              text: "). That doesn't mean that it isn't correct, but please "
                  "double check to be sure!")
        ]),
      ),
      actions: [
        SimpleDialogOption(
          child: Text('Change it'),
          onPressed: () => Navigator.pop(context, false),
        ),
        SimpleDialogOption(
          child: Text("It's correct"),
          onPressed: () => Navigator.pop(context, true),
        )
      ],
    );
  }

  static Future<bool> showCustomDialog(
    BuildContext context, {
    required String setId,
    required int existingIdEnd,
  }) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return ViveBaseStationExtraInfoIdWarningAlertWidget(
            setId: setId,
            existingIdEnd: existingIdEnd,
          );
        }).then((value) {
      if (value is bool) {
        return value;
      }
      return false;
    });
  }
}
