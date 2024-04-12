import 'package:flutter/material.dart';
import 'package:lighthouse_pm/theming.dart';

class ViveBaseStationExtraInfoAlertWidget extends StatefulWidget {
  const ViveBaseStationExtraInfoAlertWidget(
      {super.key, required this.pairIdHint});

  final int? pairIdHint;

  @override
  State<StatefulWidget> createState() {
    return _ViveBaseStationExtraInfoAlertState();
  }

  static Future<String?> showCustomDialog(
      final BuildContext context, final int? pairIdHint) {
    return showDialog(
        context: context,
        builder: (final BuildContext context) {
          return ViveBaseStationExtraInfoAlertWidget(
            pairIdHint: pairIdHint,
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
    value ??= "";
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
  Widget build(final BuildContext context) {
    final endHint = widget.pairIdHint;

    final theming = Theming.of(context);

    return AlertDialog(
      title: RichText(
        text: TextSpan(style: theming.bodyMedium, children: <InlineSpan>[
          const TextSpan(text: 'Base station id required.\n'),
          if (endHint != null) ...[
            const TextSpan(
                text:
                    'The id is found on the back and will probably end with: '),
            TextSpan(
                style: theming.bodyTextBold,
                text: endHint.toRadixString(16).padLeft(4, '0').toUpperCase()),
            const TextSpan(text: '.'),
          ] else
            const TextSpan(text: 'The id is found on the back.')
        ]),
      ),
      content: Form(
          key: _formKey,
          child: TextFormField(
            validator: _validateId,
            onChanged: (final String value) {
              _formKey.currentState?.validate();
            },
            controller: _textController,
          )),
      actions: <Widget>[
        SimpleDialogOption(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        SimpleDialogOption(
          child: const Text('Set'),
          onPressed: () async {
            final text = _textController.text.trim().toUpperCase();
            if (_formKey.currentState?.validate() ?? false) {
              if (endHint != null) {
                final intValue = int.parse(text, radix: 16);
                if (text.length == 8 && intValue & 0xFFFF != endHint) {
                  final viveBaseStationExtraInfo =
                      ViveBaseStationExtraInfoIdWarningAlertWidget
                          .showCustomDialog(context,
                              setId: text, existingIdEnd: endHint);
                  if (!(await viveBaseStationExtraInfo)) {
                    // The user doesn't want to close yet.
                    return;
                  }
                }
              }
              if (context.mounted) {
                Navigator.pop(context, text);
              }
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
  const ViveBaseStationExtraInfoIdWarningAlertWidget(
      {required this.setId, required this.existingIdEnd, super.key});

  final String setId;
  final int existingIdEnd;

  @override
  Widget build(final BuildContext context) {
    final theming = Theming.of(context);

    return AlertDialog(
      title: const Text("The end of the id doesn't match"),
      content: RichText(
        text: TextSpan(style: theming.bodyMedium, children: [
          const TextSpan(text: "The id you have provided ("),
          TextSpan(text: setId, style: theming.bodyTextBold),
          const TextSpan(
              text: ") doesn't end the same as the end of your lighthouse's "
                  "name ("),
          TextSpan(
              style: theming.bodyTextBold,
              text: existingIdEnd
                  .toRadixString(16)
                  .padLeft(4, '0')
                  .toUpperCase()),
          const TextSpan(
              text: "). That doesn't mean that it isn't correct, but please "
                  "double check to be sure!")
        ]),
      ),
      actions: [
        SimpleDialogOption(
          child: const Text('Change it'),
          onPressed: () => Navigator.pop(context, false),
        ),
        SimpleDialogOption(
          child: const Text("It's correct"),
          onPressed: () => Navigator.pop(context, true),
        )
      ],
    );
  }

  static Future<bool> showCustomDialog(
    final BuildContext context, {
    required final String setId,
    required final int existingIdEnd,
  }) {
    return showDialog(
        context: context,
        builder: (final BuildContext context) {
          return ViveBaseStationExtraInfoIdWarningAlertWidget(
            setId: setId,
            existingIdEnd: existingIdEnd,
          );
        }).then((final value) {
      if (value is bool) {
        return value;
      }
      return false;
    });
  }
}
