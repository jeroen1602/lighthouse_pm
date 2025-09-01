import 'package:flutter/material.dart';
import 'package:lighthouse_pm/theming.dart';

typedef OnSelect = void Function(bool isNowSelected);

Widget createSelectableListTile(
  final BuildContext context, {
  final Key? key,
  required final bool selected,
  required final bool selecting,
  final Widget? leading,
  final Widget? title,
  final Widget? subtitle,
  final OnSelect? onSelect,
  final VoidCallback? onTap,
}) {
  final theme = Theme.of(context);
  final theming = Theming.fromTheme(theme);

  final trailing = selecting
      ? selected
            ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
            : const Icon(Icons.radio_button_unchecked)
      : null;

  return Container(
    key: key,
    color: selected ? theming.selectedRowColor : null,
    child: ListTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      onLongPress: () {
        if (onTap == null) {
          onSelect?.call(!selected);
          return;
        }
        if (!selecting) {
          onSelect?.call(true);
        } else {
          onTap.call();
        }
      },
      onTap: () {
        if (selecting) {
          onSelect?.call(!selected);
        } else {
          onTap?.call();
        }
      },
    ),
  );
}
