import 'package:flutter/material.dart';
import 'package:lighthouse_pm/theming.dart';

import '../lighthouse_device.dart';

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
    final theming = Theming.of(context);

    return Container(
        color: selected ? theming.selectedRowColor : Colors.transparent,
        child: InkWell(
            onLongPress: onSelected,
            onTap: selecting ? onSelected : null,
            child: IntrinsicHeight(
              child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Column(children: <Widget>[
                    Container(
                        alignment: Alignment.topLeft,
                        child: Text(nickname ?? deviceId,
                            style: theming.headline4
                                ?.copyWith(color: theming.disabledColor))),
                    Row(
                      children: [
                        Text('Offline', style: theming.disabledBodyText),
                        VerticalDivider(),
                        Container(
                            alignment: Alignment.bottomLeft,
                            child: Text(deviceId,
                                style: theming.disabledBodyText)),
                      ],
                    ),
                  ])),
            )));
  }
}
