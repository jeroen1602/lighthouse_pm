import 'package:flutter/material.dart';
import 'package:lighthouse_pm/Theming.dart';
import 'package:lighthouse_pm/lighthouseProvider/widgets/LighthouseMetadataPage.dart';
import 'package:lighthouse_pm/lighthouseProvider/widgets/UnknownStateAlertWidget.dart';

import '../LighthouseDevice.dart';
import '../LighthousePowerState.dart';
import '../deviceExtensions/StandbyExtension.dart';
import 'LighthousePowerButtonWidget.dart';

typedef LighthousePowerState _ToPowerState(int byte);

/// A widget for showing a [LighthouseDevice] in a list without automatic
/// updating of the power state.
class LighthouseWidgetContent extends StatelessWidget {
  LighthouseWidgetContent(this.lighthouseDevice, this.powerStateData,
      {required this.onSelected,
      required this.selected,
      required this.selecting,
      this.nickname,
      this.sleepState = LighthousePowerState.SLEEP,
      Key? key})
      : super(key: key) {
    assert(
        sleepState == LighthousePowerState.SLEEP ||
            sleepState == LighthousePowerState.STANDBY,
        'The sleep state may not be ${sleepState.text.toUpperCase()}');

    this.lighthouseDevice.nickname = this.nickname;
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
                                child: Text(
                                    '${this.nickname ?? this.lighthouseDevice.name}',
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
                                    Text(
                                        '${this.lighthouseDevice.deviceIdentifier}')
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

  Future<void> _switchToSleepState() async {
    if (lighthouseDevice.hasStandbyExtension) {
      await this.lighthouseDevice.changeState(this.sleepState);
      return;
    }
    debugPrint(
        'The device doesn\'t support STANDBY so SLEEP will always be used.');
    await this.lighthouseDevice.changeState(LighthousePowerState.SLEEP);
  }

  Future<void> _stateSwitch(BuildContext context, int powerStateData) async {
    if (!await lighthouseDevice.showExtraInfoWidget(context)) {
      return;
    }
    final state = lighthouseDevice.powerStateFromByte(powerStateData);
    switch (state) {
      case LighthousePowerState.BOOTING:
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
            content: Text('Lighthouse is already booting!'),
            action: SnackBarAction(
              label: 'I\'m sure',
              onPressed: () async {
                await this._switchToSleepState();
              },
            )));
        break;
      case LighthousePowerState.ON:
        await this._switchToSleepState();
        break;
      case LighthousePowerState.STANDBY:
      case LighthousePowerState.SLEEP:
        await this.lighthouseDevice.changeState(LighthousePowerState.ON);
        break;
      case LighthousePowerState.UNKNOWN:
        final newState = await UnknownStateAlertWidget.showCustomDialog(
            context, lighthouseDevice, powerStateData);
        if (newState != null) {
          await this.lighthouseDevice.changeState(newState);
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
      this.sleepState = LighthousePowerState.SLEEP,
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
      stream: this.lighthouseDevice.powerState,
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
