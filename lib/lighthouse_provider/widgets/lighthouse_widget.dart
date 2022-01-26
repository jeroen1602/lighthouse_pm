import 'package:flutter/material.dart';
import 'package:lighthouse_pm/lighthouse_provider/lighthouse_provider.dart';
import 'package:lighthouse_pm/lighthouse_providers/lighthouse_v2_device_provider.dart';
import 'package:lighthouse_pm/theming.dart';

import 'lighthouse_metadata_page.dart';
import 'lighthouse_power_button_widget.dart';
import 'unknown_state_alert_widget.dart';

typedef _ToPowerState = LighthousePowerState Function(int byte);

/// A widget for showing a [LighthouseDevice] in a list without automatic
/// updating of the power state.
class LighthouseWidgetContent extends StatelessWidget {
  LighthouseWidgetContent(this.lighthouseDevice, this.powerStateData,
      {required this.onSelected,
      required this.selected,
      required this.selecting,
      this.nickname,
      this.sleepState = LighthousePowerState.sleep,
      Key? key})
      : super(key: key) {
    assert(
        sleepState == LighthousePowerState.sleep ||
            sleepState == LighthousePowerState.standby,
        'The sleep state may not be ${sleepState.text.toUpperCase()}');

    lighthouseDevice.nickname = nickname;
  }

  final LighthouseDevice lighthouseDevice;
  final int powerStateData;
  final VoidCallback onSelected;
  final bool selected;
  final String? nickname;
  final LighthousePowerState sleepState;
  final bool selecting;

  Future _openMetadataPage(BuildContext context) async {
    return await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (c) => LighthouseMetadataPage(lighthouseDevice)));
  }

  @override
  Widget build(BuildContext context) {
    final theming = Theming.of(context);
    return Container(
        color: selected ? theming.selectedRowColor : Colors.transparent,
        child: InkWell(
            onLongPress: onSelected,
            onTap: () {
              if (selecting) {
                onSelected();
              } else {
                _openMetadataPage(context);
              }
            },
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
                                child: Text(nickname ?? lighthouseDevice.name,
                                    style: theming.headline4)),
                            Container(
                                alignment: Alignment.topLeft,
                                child: Row(
                                  children: <Widget>[
                                    _LHItemPowerStateWidget(
                                      powerStateByte: powerStateData,
                                      toPowerState:
                                          lighthouseDevice.powerStateFromByte,
                                    ),
                                    VerticalDivider(),
                                    Text('${lighthouseDevice.deviceIdentifier}')
                                  ],
                                ))
                          ]))),
                  LighthousePowerButtonWidget(
                    powerState:
                        lighthouseDevice.powerStateFromByte(powerStateData),
                    onPress: () async {
                      await _stateSwitch(context, powerStateData);
                    },
                    onLongPress: () => _openMetadataPage(context),
                  )
                ]))));
  }

  Future<void> _switchToSleepState(BuildContext context) async {
    if (lighthouseDevice.hasStandbyExtension) {
      await lighthouseDevice.changeState(sleepState, context);
      return;
    }
    debugPrint(
        'The device doesn\'t support STANDBY so SLEEP will always be used.');
    await lighthouseDevice.changeState(LighthousePowerState.sleep, context);
  }

  Future<void> _stateSwitch(BuildContext context, int powerStateData) async {
    if (!await lighthouseDevice.requestExtraInfo(context)) {
      return;
    }
    final state = lighthouseDevice.powerStateFromByte(powerStateData);
    switch (state) {
      case LighthousePowerState.booting:
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
            content: Text('Lighthouse is already booting!'),
            action: SnackBarAction(
              label: 'I\'m sure',
              onPressed: () async {
                await _switchToSleepState(context);
              },
            )));
        break;
      case LighthousePowerState.on:
        await _switchToSleepState(context);
        break;
      case LighthousePowerState.standby:
      case LighthousePowerState.sleep:
        await lighthouseDevice.changeState(LighthousePowerState.on, context);
        break;
      case LighthousePowerState.unknown:
        final newState = await UnknownStateAlertWidget.showCustomDialog(
            context, lighthouseDevice, powerStateData);
        if (newState != null) {
          await lighthouseDevice.changeState(newState, context);
        }
        break;
    }
  }
}

/// A widget for showing a [LighthouseDevice] in a list with automatic updating
/// of the power state.
class LighthouseWidget extends StatelessWidget {
  LighthouseWidget(this.lighthouseDevice,
      {required this.onSelected,
      required this.selected,
      required this.selecting,
      this.nickname,
      this.sleepState = LighthousePowerState.sleep,
      Key? key})
      : super(key: key);

  final LighthouseDevice lighthouseDevice;
  final VoidCallback onSelected;
  final bool selected;
  final String? nickname;
  final LighthousePowerState sleepState;
  final bool selecting;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: lighthouseDevice.powerState,
      builder: (BuildContext context, AsyncSnapshot<int> powerStateSnapshot) {
        final powerStateData = powerStateSnapshot.data ?? 0xFF;

        return LighthouseWidgetContent(
          lighthouseDevice,
          powerStateData,
          onSelected: onSelected,
          selected: selected,
          nickname: nickname,
          sleepState: sleepState,
          selecting: selecting,
        );
      },
    );
  }
}

/// Display the state of the device together with the state as a number in hex.
class _LHItemPowerStateWidget extends StatelessWidget {
  _LHItemPowerStateWidget(
      {Key? key, required this.powerStateByte, required this.toPowerState})
      : super(key: key);

  final int powerStateByte;
  final _ToPowerState toPowerState;

  @override
  Widget build(BuildContext context) {
    final state = toPowerState(powerStateByte);
    final hexString = powerStateByte.toRadixString(16);
    return Text(
        '${state.text} (0x${hexString.padLeft(hexString.length + (hexString.length % 2), '0')})');
  }
}
