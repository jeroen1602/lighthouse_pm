import 'package:flutter/material.dart';
import 'package:lighthouse_pm/lighthouseProvider/widgets/LighthouseMetadataPage.dart';
import 'package:lighthouse_pm/lighthouseProvider/widgets/UnknownStateAlertWidget.dart';

import '../LighthouseDevice.dart';
import '../LighthousePowerState.dart';

typedef LighthousePowerState _ToPowerState(int byte);

/// A widget for showing a [LighthouseDevice] in a list.
class LighthouseWidget extends StatelessWidget {
  LighthouseWidget(this.lighthouseDevice,
      {this.onLongPress, this.selected, this.nickname, Key key})
      : super(key: key);

  final LighthouseDevice lighthouseDevice;
  final GestureLongPressCallback onLongPress;
  final bool selected;
  final String /* ? */ nickname;

  @override
  Widget build(BuildContext context) {
    return Container(
        color: selected ? Colors.black12 : Colors.transparent,
        child: InkWell(
            onLongPress: onLongPress,
            child: IntrinsicHeight(
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                  Expanded(
                      child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Column(children: <Widget>[
                            Container(
                                alignment: Alignment.topLeft,
                                child: Row(
                                  children: <Widget>[
                                    Text(
                                        '${this.nickname != null ? this.nickname : this.lighthouseDevice.name}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline4)
                                  ],
                                )),
                            Container(
                                alignment: Alignment.topLeft,
                                child: Row(
                                  children: <Widget>[
                                    StreamBuilder<int>(
                                        stream:
                                            this.lighthouseDevice.powerState,
                                        initialData: 0xFF,
                                        builder: (c, snapshot) {
                                          final data = snapshot.hasData
                                              ? snapshot.data
                                              : 0xFF;
                                          return _LHItemPowerStateWidget(
                                            powerStateByte: data,
                                            toPowerState: lighthouseDevice
                                                .powerStateFromByte,
                                          );
                                        }),
                                    VerticalDivider(),
                                    Text(
                                        '${this.lighthouseDevice.deviceIdentifier}')
                                  ],
                                ))
                          ]))),
                  StreamBuilder<int>(
                      stream: this.lighthouseDevice.powerState,
                      initialData: 0xFF,
                      builder: (c, snapshot) {
                        final data = snapshot.hasData ? snapshot.data : 0xFF;
                        return _LHItemButtonWidget(
                          powerState: data,
                          toPowerState: lighthouseDevice.powerStateFromByte,
                          onPress: () async {
                            final state =
                                lighthouseDevice.powerStateFromByte(data);
                            switch (state) {
                              case LighthousePowerState.BOOTING:
                                Scaffold.of(context).showSnackBar(SnackBar(
                                    content:
                                        Text('Lighthouse is already booting!'),
                                    action: SnackBarAction(
                                      label: 'I\'m sure',
                                      onPressed: () async {
                                        await this.lighthouseDevice.changeState(
                                            LighthousePowerState.SLEEP);
                                      },
                                    )));
                                break;
                              case LighthousePowerState.UNKNOWN:
                                switch (await UnknownStateAlertWidget
                                    .showCustomDialog(
                                        context, lighthouseDevice, data)) {
                                  case LighthousePowerState.ON:
                                    continue powerOn;
                                  case LighthousePowerState.SLEEP:
                                    continue powerOff;
                                }
                                break;
                              powerOff:
                              case LighthousePowerState.ON:
                                await this
                                    .lighthouseDevice
                                    .changeState(LighthousePowerState.SLEEP);
                                break;
                              powerOn:
                              case LighthousePowerState.SLEEP:
                                await this
                                    .lighthouseDevice
                                    .changeState(LighthousePowerState.ON);
                                break;
                            }
                          },
                          onLongPress: () async {
                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (c) => LighthouseMetadataPage(
                                        lighthouseDevice)));
                          },
                        );
                      })
                ]))));
  }
}

/// Display the state of the device together with the state as a number in hex.
class _LHItemPowerStateWidget extends StatelessWidget {
  _LHItemPowerStateWidget(
      {Key key, @required this.powerStateByte, @required this.toPowerState})
      : super(key: key);

  final int powerStateByte;
  final _ToPowerState toPowerState;

  @override
  Widget build(BuildContext context) {
    final state = toPowerState(powerStateByte);
    return Text(
        '${state.text} (0x${powerStateByte.toRadixString(16).padLeft(2, '0')})');
  }
}

/// Add the toggle button for the power state of the device.
class _LHItemButtonWidget extends StatelessWidget {
  _LHItemButtonWidget({
    Key key,
    @required this.powerState,
    @required this.onPress,
    @required this.onLongPress,
    @required this.toPowerState,
  }) : super(key: key);
  final int powerState;
  final VoidCallback onPress;
  final VoidCallback onLongPress;
  final _ToPowerState toPowerState;

  @override
  Widget build(BuildContext context) {
    final state = toPowerState(powerState);
    var color = Colors.grey;
    switch (state) {
      case LighthousePowerState.ON:
        color = Colors.green;
        break;
      case LighthousePowerState.SLEEP:
        color = Colors.blue;
        break;
      case LighthousePowerState.BOOTING:
        color = Colors.orange;
        break;
    }
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: RawMaterialButton(
          onPressed: () => onPress.call(),
          onLongPress: () => onLongPress.call(),
          elevation: 2.0,
          fillColor: Colors.white,
          padding: const EdgeInsets.all(2.0),
          shape: CircleBorder(),
          child: Icon(
            Icons.power_settings_new,
            color: color,
            size: 24.0,
          )),
    );
  }
}
