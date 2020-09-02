import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../LighthouseDeviceV2.dart';
import '../LighthousePowerState.dart';

/// A widget for showing a [LighthouseDevice] in a list.
class LighthouseWidgetV2 extends StatelessWidget {
  LighthouseWidgetV2(this.lighthouseDevice, {Key key}) : super(key: key);

  final LighthouseDeviceV2 lighthouseDevice;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
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
                            Text('${this.lighthouseDevice.name}',
                                style: Theme.of(context).textTheme.headline4)
                          ],
                        )),
                    Container(
                        alignment: Alignment.topLeft,
                        child: Row(
                          children: <Widget>[
                            StreamBuilder<int>(
                                stream: this.lighthouseDevice.powerState,
                                initialData: 0xFF,
                                builder: (c, snapshot) {
                                  final data =
                                      snapshot.hasData ? snapshot.data : 0xFF;
                                  return _LHItemPowerStateWidget(
                                      powerState: data);
                                }),
                            VerticalDivider(),
                            Text('${this.lighthouseDevice.deviceIdentifier}')
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
                  onTap: () async {
                    final state = LighthousePowerState.fromByte(data);
                    if (state == LighthousePowerState.BOOTING) {
                      Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text('Lighthouse is already booting!'),
                          action: SnackBarAction(
                            label: 'I\'m sure',
                            onPressed: () async {
                              await this
                                  .lighthouseDevice
                                  .changeState(LighthousePowerState.STANDBY);
                            },
                          )));
                      return;
                    }
                    var newSate = LighthousePowerState.ON;
                    if (state == LighthousePowerState.ON) {
                      newSate = LighthousePowerState.STANDBY;
                    }
                    await this.lighthouseDevice.changeState(newSate);
                  },
                );
              })
        ]));
  }
}

/// Display the state of the device together with the state as a number in hex.
class _LHItemPowerStateWidget extends StatelessWidget {
  _LHItemPowerStateWidget({Key key, this.powerState}) : super(key: key);

  final int powerState;

  @override
  Widget build(BuildContext context) {
    var state = LighthousePowerState.fromByte(this.powerState);
    return Text('${state.text} (0x${powerState.toRadixString(16)})');
  }
}

/// Add the toggle button for the power state of the device.
class _LHItemButtonWidget extends StatelessWidget {
  _LHItemButtonWidget({
    Key key,
    this.powerState,
    this.onTap,
  }) : super(key: key);
  final int powerState;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    var state = LighthousePowerState.fromByte(this.powerState);
    var color = Colors.grey;
    switch (state) {
      case LighthousePowerState.ON:
        color = Colors.green;
        break;
      case LighthousePowerState.STANDBY:
        color = Colors.blue;
        break;
    }
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: RawMaterialButton(
          onPressed: () => onTap.call(),
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
