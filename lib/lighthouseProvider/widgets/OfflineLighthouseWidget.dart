import 'package:flutter/material.dart';

import '../LighthouseDevice.dart';

/// A widget for showing an OFFLINE [LighthouseDevice] in a list.
class OfflineLighthouseWidget extends StatelessWidget {
  OfflineLighthouseWidget(this.deviceId,
      {required this.onSelected,
      required this.selected,
        required this.selecting,
      this.nickname,
      Key? key})
      : super(key: key);

  final String deviceId;
  final VoidCallback onSelected;
  final bool selected;
  final bool selecting;
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
            onLongPress: onSelected,
            onTap: selecting ? () {
              onSelected();
            } : null,
            child: IntrinsicHeight(
              child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Column(children: <Widget>[
                    Container(
                        alignment: Alignment.topLeft,
                        child: Text('${this.nickname ?? this.deviceId}',
                            style: theme.textTheme.headline4
                                ?.copyWith(color: disabledColored))),
                    Row(
                      children: [
                        Text('Offline', style: disabledTextTheme),
                        VerticalDivider(),
                        Container(
                            alignment: Alignment.bottomLeft,
                            child: Text('${this.deviceId}',
                                style: disabledTextTheme)),
                      ],
                    ),
                  ])),
            )));
  }
}
