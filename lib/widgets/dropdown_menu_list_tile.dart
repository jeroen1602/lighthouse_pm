import 'package:flutter/material.dart';

class DropdownMenuListTile<T> extends StatelessWidget {
  const DropdownMenuListTile(
      {final Key? key,
      this.title,
      this.subTitle,
      required this.value,
      this.icon,
      this.iconSize = 24.0,
      this.elevation = 8,
      required this.onChanged,
      required this.items})
      : super(key: key);

  final Widget? title;
  final Widget? subTitle;
  final Widget? icon;
  final double iconSize;
  final int elevation;
  final T value;
  final ValueChanged<T?> onChanged;
  final List<DropdownMenuItem<T>> items;

  @override
  Widget build(final BuildContext context) {
    return ListTile(
      title: title,
      subtitle: subTitle,
      trailing: DropdownButton<T>(
          value: value,
          iconSize: iconSize,
          elevation: elevation,
          onChanged: onChanged,
          items: items),
    );
  }
}
