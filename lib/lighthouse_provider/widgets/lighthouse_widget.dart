import 'package:flutter/material.dart';
import 'package:lighthouse_pm/theming.dart';
import 'package:lighthouse_provider/lighthouse_provider.dart';
import 'package:lighthouse_providers/lighthouse_v2_device_provider.dart';

import 'lighthouse_metadata_page.dart';
import 'lighthouse_power_button_widget.dart';
import 'unknown_state_alert_widget.dart';

typedef _ToPowerState = LighthousePowerState Function(int byte);

/// A widget for showing a [LighthouseDevice] in a list without automatic
/// updating of the power state.
class LighthouseWidgetContent extends StatefulWidget {
  LighthouseWidgetContent(this.lighthouseDevice, this.powerStateData,
      {required this.onSelected,
      required this.selected,
      required this.selecting,
      this.nickname,
      this.sleepState = LighthousePowerState.sleep,
      super.key}) {
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

  @override
  State<StatefulWidget> createState() {
    return _LighthouseWidgetContentState();
  }
}

class _LighthouseWidgetContentState extends State<LighthouseWidgetContent> {
  @override
  Widget build(final BuildContext context) {
    final theming = Theming.of(context);
    return Container(
        color: widget.selected ? theming.selectedRowColor : Colors.transparent,
        child: InkWell(
            onLongPress: widget.onSelected,
            onTap: () {
              if (widget.selecting) {
                widget.onSelected();
              } else {
                _openMetadataPage();
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
                                    widget.nickname ??
                                        widget.lighthouseDevice.name,
                                    style: theming.headline4)),
                            Container(
                                alignment: Alignment.topLeft,
                                child: Row(
                                  children: <Widget>[
                                    _LHItemPowerStateWidget(
                                      powerStateByte: widget.powerStateData,
                                      toPowerState: widget
                                          .lighthouseDevice.powerStateFromByte,
                                    ),
                                    const VerticalDivider(),
                                    Text(
                                        '${widget.lighthouseDevice.deviceIdentifier}')
                                  ],
                                ))
                          ]))),
                  LighthousePowerButtonWidget(
                    powerState: widget.lighthouseDevice
                        .powerStateFromByte(widget.powerStateData),
                    onPress: () async {
                      await _stateSwitch(widget.powerStateData);
                    },
                    onLongPress: () => _openMetadataPage(),
                  )
                ]))));
  }

  Future _openMetadataPage() async {
    return await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (final c) =>
                LighthouseMetadataPage(widget.lighthouseDevice)));
  }

  Future<void> _switchToSleepState() async {
    if (widget.lighthouseDevice.hasStandbyExtension) {
      await widget.lighthouseDevice.changeState(widget.sleepState, context);
      return;
    }
    debugPrint(
        'The device doesn\'t support STANDBY so SLEEP will always be used.');
    await widget.lighthouseDevice
        .changeState(LighthousePowerState.sleep, context);
  }

  Future<void> _stateSwitch(final int powerStateData) async {
    if (!await widget.lighthouseDevice.requestExtraInfo(context)) {
      return;
    }
    final state = widget.lighthouseDevice.powerStateFromByte(powerStateData);
    switch (state) {
      case LighthousePowerState.booting:
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
            content: const Text('Lighthouse is already booting!'),
            action: SnackBarAction(
              label: 'I\'m sure',
              onPressed: () async {
                await _switchToSleepState();
              },
            )));
        break;
      case LighthousePowerState.on:
        await _switchToSleepState();
        break;
      case LighthousePowerState.standby:
      case LighthousePowerState.sleep:
        await widget.lighthouseDevice
            .changeState(LighthousePowerState.on, context);
        break;
      case LighthousePowerState.unknown:
        final newState = await UnknownStateAlertWidget.showCustomDialog(
            context, widget.lighthouseDevice, powerStateData);
        if (newState != null) {
          if (mounted) {
            await widget.lighthouseDevice.changeState(newState, context);
          }
        }
        break;
    }
  }
}

/// A widget for showing a [LighthouseDevice] in a list with automatic updating
/// of the power state.
class LighthouseWidget extends StatelessWidget {
  const LighthouseWidget(this.lighthouseDevice,
      {required this.onSelected,
      required this.selected,
      required this.selecting,
      this.nickname,
      this.sleepState = LighthousePowerState.sleep,
      final Key? key})
      : super(key: key);

  final LighthouseDevice lighthouseDevice;
  final VoidCallback onSelected;
  final bool selected;
  final String? nickname;
  final LighthousePowerState sleepState;
  final bool selecting;

  @override
  Widget build(final BuildContext context) {
    return StreamBuilder<int>(
      stream: lighthouseDevice.powerState,
      builder: (final BuildContext context,
          final AsyncSnapshot<int> powerStateSnapshot) {
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
  const _LHItemPowerStateWidget(
      {final Key? key,
      required this.powerStateByte,
      required this.toPowerState})
      : super(key: key);

  final int powerStateByte;
  final _ToPowerState toPowerState;

  @override
  Widget build(final BuildContext context) {
    final state = toPowerState(powerStateByte);
    final hexString = powerStateByte.toRadixString(16);
    return Text(
        '${state.text} (0x${hexString.padLeft(hexString.length + (hexString.length % 2), '0')})');
  }
}
