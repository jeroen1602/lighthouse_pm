import 'package:flutter/material.dart';
import 'package:lighthouse_pm/theming.dart';

///
/// A class for generating dialogs for adding new items into the database.
/// These dialogs are very crude and a bit ugly, they shouldn't be used in production code!
///
/// Show a new dialog by calling [showCustomDialog] with a list of [DaoDataCreateAlertDecorator]s.
/// These decorators will determine the fields that the dialog has.
/// After the dialog is done showing the values that the user set will be in the
/// [DaoDataCreateAlertDecorator.getNewValue] call. These can be `null`.
///
class DaoDataCreateAlertWidget extends StatefulWidget {
  const DaoDataCreateAlertWidget(this.decorators, {final Key? key})
      : super(key: key);

  final List<DaoDataCreateAlertDecorator<dynamic>> decorators;

  @override
  State<StatefulWidget> createState() {
    return _DaoDataCreateAlertWidget();
  }

  /// Open a dialog with the question if the user wants to delete a database entry.
  /// `true` if the use has selected the yes option, `false` otherwise.
  static Future<bool> showCustomDialog(final BuildContext context,
      final List<DaoDataCreateAlertDecorator<dynamic>> decorators) {
    return showDialog(
        context: context,
        builder: (final BuildContext context) {
          return DaoDataCreateAlertWidget(decorators);
        }).then((final value) {
      if (value is bool) {
        return value;
      }
      return false;
    });
  }
}

class _DaoDataCreateAlertWidget extends State<DaoDataCreateAlertWidget> {
  final _formKey = GlobalKey<FormState>();
  var saveEnabled = false;

  @override
  Widget build(final BuildContext context) {
    final List<Widget> children = widget.decorators
        .map((final e) => e.getEdit(context, (final value) {
              e.value = value;
              setState(() {
                final value = _formKey.currentState?.validate();
                saveEnabled = value ?? false;
              });
            }))
        .toList();

    return AlertDialog(
      title: const Text('Create new item!'),
      content: IntrinsicHeight(
          child: Form(
              key: _formKey,
              child: Column(
                children: children,
              ))),
      actions: <Widget>[
        SimpleDialogOption(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context, false),
        ),
        SimpleDialogOption(
          onPressed: saveEnabled ? () => Navigator.pop(context, true) : null,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

abstract class DaoDataCreateAlertDecorator<T> {
  final T? originalValue;
  final String name;
  @protected
  T? value;

  DaoDataCreateAlertDecorator(this.name, this.originalValue);

  Widget getEdit(final BuildContext context, final ValueChanged<T?> onChange);

  T? getNewValue() {
    return value;
  }
}

///
/// A [DaoDataCreateAlertDecorator] for entering strings.
/// use [validator] if you require a custom validator.
///
class DaoDataCreateAlertStringDecorator
    extends DaoDataCreateAlertDecorator<String> {
  DaoDataCreateAlertStringDecorator(
      final String name, final String? originalValue,
      {this.validator})
      : super(name, originalValue);

  final FormFieldValidator<String>? validator;

  @override
  Widget getEdit(
      final BuildContext context, final ValueChanged<String> onChange) {
    return _DaoDataCreateAlertStringDecoratorWidget(
      this,
      onChange,
      validator: validator,
    );
  }
}

class _DaoDataCreateAlertStringDecoratorWidget extends StatelessWidget {
  final DaoDataCreateAlertStringDecorator item;
  final ValueChanged<String> onChange;
  final FormFieldValidator<String>? validator;

  const _DaoDataCreateAlertStringDecoratorWidget(this.item, this.onChange,
      {final Key? key, this.validator})
      : super(key: key);

  @override
  Widget build(final BuildContext context) {
    return Column(
      children: [
        TextFormField(
          initialValue: item.originalValue,
          validator: validator,
          decoration: InputDecoration(labelText: item.name),
          onChanged: (final val) {
            onChange(val);
          },
        ),
        const Divider(),
      ],
    );
  }
}

///
/// A [DaoDataCreateAlertDecorator] for entering ints.
/// Use [negative] if the value is allowed to be negative.
/// Use [autoIncrement] if the int can also be null and thus set via autoincrement.
///
class DaoDataCreateAlertIntDecorator extends DaoDataCreateAlertDecorator<int> {
  DaoDataCreateAlertIntDecorator(final String name, final int? originalValue,
      {this.autoIncrement = false, this.negative = false})
      : super(name, originalValue);

  final bool autoIncrement;
  final bool negative;

  @override
  Widget getEdit(
      final BuildContext context, final ValueChanged<int?> onChange) {
    return _DaoDataCreateAlertIntDecoratorWidget(this, onChange);
  }
}

class _DaoDataCreateAlertIntDecoratorWidget extends StatefulWidget {
  final DaoDataCreateAlertIntDecorator item;
  final ValueChanged<int?> onChange;

  const _DaoDataCreateAlertIntDecoratorWidget(this.item, this.onChange,
      {final Key? key})
      : super(key: key);

  String? _validateId(final String? value) {
    if (value == null) {
      return null;
    }
    final intValue = int.tryParse(value, radix: 10);
    if (intValue == null) {
      return 'Not an integer';
    }
    if (!item.negative && intValue < 0) {
      return 'Value may not be negative!';
    }
    return null;
  }

  @override
  State<StatefulWidget> createState() {
    return _DaoDataCreateAlertIntDecoratorWidgetState();
  }
}

class _DaoDataCreateAlertIntDecoratorWidgetState
    extends State<_DaoDataCreateAlertIntDecoratorWidget> {
  bool autoIncrementEnabled = false;
  String savedValue = "";

  @override
  void initState() {
    super.initState();
    autoIncrementEnabled = widget.item.autoIncrement;
  }

  @override
  Widget build(final BuildContext context) {
    final List<Widget> children = [];

    if (widget.item.autoIncrement) {
      children.add(SwitchListTile(
        title: const Text('Auto increment'),
        value: autoIncrementEnabled,
        onChanged: (final newValue) {
          setState(() {
            autoIncrementEnabled = newValue == true;
          });
          if (newValue == true) {
            widget.onChange(null);
          }
        },
      ));
    }

    if (!autoIncrementEnabled) {
      children.add(TextFormField(
        initialValue: widget.item.originalValue?.toRadixString(10),
        validator: widget._validateId,
        decoration: InputDecoration(labelText: widget.item.name),
        onChanged: (final val) {
          final intValue = int.tryParse(val, radix: 10);
          if (intValue != null) {
            widget.onChange(intValue);
          }
        },
      ));
    } else {
      final theming = Theming.of(context);
      children.add(FocusScope(
          node: FocusScopeNode(canRequestFocus: false),
          canRequestFocus: false,
          child: TextFormField(
            style: theming.subtitle,
            decoration: InputDecoration(
                labelText: widget.item.name, hintText: 'Auto increment is on'),
          )));
    }

    children.add(const Divider());

    return Column(
      children: children,
    );
  }
}
