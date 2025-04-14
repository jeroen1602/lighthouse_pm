import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lighthouse_pm/theming.dart';
import 'package:tuple/tuple.dart';

AppBar createSelectableAppBar(
  final BuildContext context, {
  final Key? key,
  final bool? selected,
  final int? numberOfSelections,
  final Widget? title,
  final List<Widget>? actions,
  final VoidCallback? onClearSelection,
}) {
  final isSelecting = selected ?? (numberOfSelections ?? 0) > 0;
  final theming = Theming.of(context);

  var titleWidget = title;
  if (titleWidget is Text && isSelecting) {
    titleWidget = _createTextWithStyle(
      titleWidget,
      theming.selectedAppBarTextColor,
      numberOfSelections,
    );
  }
  var actionsWidget = actions;
  if (actionsWidget != null && isSelecting) {
    actionsWidget = _createActionsWithColor(
      actionsWidget,
      theming.selectedAppBarTextColor,
    );
  }
  Widget? leading;
  if (isSelecting && onClearSelection != null) {
    leading = IconButton(
      icon: Icon(Icons.close, color: theming.selectedAppBarTextColor),
      tooltip: 'Cancel selection',
      onPressed: () {
        onClearSelection.call();
      },
    );
  }

  return AppBar(
    key: key,
    title: titleWidget,
    actions: actionsWidget,
    leading: leading,
    backgroundColor: isSelecting ? theming.selectedAppBarColor : null,
  );
}

Tuple2<bool, Widget> _createIconWithColor(
  final Widget oldIcon,
  final Color selectedAppBarTextColor,
) {
  if (oldIcon is Icon) {
    return Tuple2(
      true,
      Icon(
        oldIcon.icon,
        key: oldIcon.key,
        size: oldIcon.size,
        color: selectedAppBarTextColor,
        semanticLabel: oldIcon.semanticLabel,
        textDirection: oldIcon.textDirection,
      ),
    );
  } else if (oldIcon is SvgPicture) {
    return Tuple2(
      true,
      SvgPicture(
        oldIcon.bytesLoader,
        key: oldIcon.key,
        width: oldIcon.width,
        height: oldIcon.height,
        fit: oldIcon.fit,
        alignment: oldIcon.alignment,
        matchTextDirection: oldIcon.matchTextDirection,
        allowDrawingOutsideViewBox: oldIcon.allowDrawingOutsideViewBox,
        placeholderBuilder: oldIcon.placeholderBuilder,
        colorFilter: ColorFilter.mode(selectedAppBarTextColor, BlendMode.srcIn),
        semanticsLabel: oldIcon.semanticsLabel,
        excludeFromSemantics: oldIcon.excludeFromSemantics,
      ),
    );
  }
  return Tuple2(false, oldIcon);
}

IconButton _createIconButtonWithColor(
  final IconButton old,
  final Color selectedAppBarTextColor,
) {
  final iconTuple = _createIconWithColor(old.icon, selectedAppBarTextColor);
  if (!iconTuple.item1) {
    return old;
  }
  final icon = iconTuple.item2;
  return IconButton(
    key: old.key,
    iconSize: old.iconSize,
    visualDensity: old.visualDensity,
    padding: old.padding,
    alignment: old.alignment,
    splashRadius: old.splashRadius,
    color: null,
    focusColor: old.focusColor,
    hoverColor: old.hoverColor,
    highlightColor: old.highlightColor,
    splashColor: old.splashColor,
    disabledColor: old.disabledColor,
    onPressed: old.onPressed,
    mouseCursor: old.mouseCursor,
    focusNode: old.focusNode,
    autofocus: old.autofocus,
    tooltip: old.tooltip,
    enableFeedback: old.enableFeedback,
    constraints: old.constraints,
    icon: icon,
  );
}

List<Widget> _createActionsWithColor(
  final List<Widget> old,
  final Color selectedAppBarTextColor,
) {
  final out = <Widget>[];
  for (final widget in old) {
    if (widget is! IconButton) {
      out.add(widget);
      continue;
    }
    out.add(_createIconButtonWithColor(widget, selectedAppBarTextColor));
  }

  return out;
}

Text _createTextWithStyle(
  final Text old,
  final Color selectedAppBarTextColor,
  final int? numberOfSelections,
) {
  return Text(
    numberOfSelections != null
        ? "$numberOfSelections selected"
        : old.data ?? "",
    key: old.key,
    style:
        old.style?.copyWith(color: selectedAppBarTextColor) ??
        TextStyle(color: selectedAppBarTextColor),
    strutStyle: old.strutStyle,
    textAlign: old.textAlign,
    textDirection: old.textDirection,
    locale: old.locale,
    softWrap: old.softWrap,
    overflow: old.overflow,
    textScaler: old.textScaler,
    maxLines: old.maxLines,
    semanticsLabel: old.semanticsLabel,
    textWidthBasis: old.textWidthBasis,
    textHeightBehavior: old.textHeightBehavior,
    selectionColor: old.selectionColor,
  );
}
