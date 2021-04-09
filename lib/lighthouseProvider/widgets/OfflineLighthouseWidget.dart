import 'package:flutter/material.dart';

import '../LighthouseDevice.dart';

/// A widget for showing an OFFLINE [LighthouseDevice] in a list.
class OfflineLighthouseWidget extends StatelessWidget {
  OfflineLighthouseWidget(this.macAddress,
      {required this.onLongPress,
      required this.selected,
      this.nickname,
      Key? key})
      : super(key: key);

  final String macAddress;
  final GestureLongPressCallback onLongPress;
  final bool selected;
  final String? nickname;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final disabledColored = theme.disabledColor;
    final disabledTextTheme =
        theme.textTheme.bodyText1?.copyWith(color: disabledColored);

    return Container(
        color:
            selected ? Theme.of(context).selectedRowColor : Colors.transparent,
        child: InkWell(
            onLongPress: onLongPress,
            child: IntrinsicHeight(
              child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Column(children: <Widget>[
                    Container(
                        alignment: Alignment.topLeft,
                        child: Text('${this.nickname ?? this.macAddress}',
                            style: theme.textTheme.headline4
                                ?.copyWith(color: disabledColored))),
                    Row(
                      children: [
                        Text('Offline', style: disabledTextTheme),
                        VerticalDivider(),
                        Container(
                            alignment: Alignment.bottomLeft,
                            child: Text('${this.macAddress}',
                                style: disabledTextTheme)),
                      ],
                    ),
                  ])),
            )));
  }
}
