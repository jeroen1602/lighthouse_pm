import 'package:flutter/foundation.dart';
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
  LighthouseWidgetContent(this.lighthouseDevice,
      {this.powerStateData,
      required this.onSelected,
      required this.selected,
      required this.selecting,
      this.nickname,
      this.sleepState = LighthousePowerState.sleep,
      super.key})
      : statefulDevice = lighthouseDevice is StatefulLighthouseDevice {
    assert(
        sleepState == LighthousePowerState.sleep ||
            sleepState == LighthousePowerState.standby,
        'The sleep state may not be ${sleepState.text.toUpperCase()}');

    lighthouseDevice.nickname = nickname;
  }

  final LighthouseDevice lighthouseDevice;
  final int? powerStateData;
  final VoidCallback onSelected;
  final bool selected;
  final String? nickname;
  final LighthousePowerState sleepState;
  final bool selecting;
  final bool statefulDevice;

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
                                    style: theming.headlineMedium)),
                            Container(
                                alignment: Alignment.topLeft,
                                child: Row(
                                  children: <Widget>[
                                    if (widget.statefulDevice) ...[
                                      _LHItemPowerStateWidget(
                                        powerStateByte: widget.powerStateData,
                                        toPowerState: (widget.lighthouseDevice
                                                as StatefulLighthouseDevice)
                                            .powerStateFromByte,
                                      ),
                                      const VerticalDivider(),
                                    ],
                                    Text(
                                        '${widget.lighthouseDevice.deviceIdentifier}')
                                  ],
                                )),
                          ]))),
                  if (widget.powerStateData != null && widget.statefulDevice)
                    LighthousePowerButtonWidget(
                      powerState:
                          (widget.lighthouseDevice as StatefulLighthouseDevice)
                              .powerStateFromByte(widget.powerStateData!),
                      onPress: () async {
                        await _stateSwitch(
                            (widget.lighthouseDevice
                                    as StatefulLighthouseDevice)
                                .powerStateFromByte(widget.powerStateData!),
                            fromStateData: widget.powerStateData);
                      },
                      onLongPress: () => _openMetadataPage(),
                    )
                  else ...[
                    LighthousePowerButtonWidget(
                      powerState: LighthousePowerState.sleep,
                      onPress: () async {
                        await _stateSwitch(LighthousePowerState.on);
                      },
                      onLongPress: () => _openMetadataPage(),
                    ),
                    LighthousePowerButtonWidget(
                      powerState: LighthousePowerState.on,
                      onPress: () async {
                        await _stateSwitch(LighthousePowerState.sleep);
                      },
                      onLongPress: () => _openMetadataPage(),
                    ),
                  ]
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

  Future<void> _stateSwitch(final LighthousePowerState fromState,
      {final int? fromStateData}) async {
    final requestExtraInfo = widget.lighthouseDevice.requestExtraInfo(context);
    if (!await requestExtraInfo) {
      return;
    }
    switch (fromState) {
      case LighthousePowerState.booting:
        if (!mounted) {
          return;
        }
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
        if (!mounted) {
          return;
        }
        await widget.lighthouseDevice
            .changeState(LighthousePowerState.on, context);
        break;
      case LighthousePowerState.unknown:
        if (!mounted) {
          return;
        }
        final newState = await UnknownStateAlertWidget.showCustomDialog(
            context, widget.lighthouseDevice,
            currentState: fromStateData);
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
class LighthouseWidget extends StatefulWidget {
  const LighthouseWidget(this.lighthouseDevice,
      {required this.onSelected,
      required this.selected,
      required this.selecting,
      this.nickname,
      this.sleepState = LighthousePowerState.sleep,
      super.key})
      : statefulDevice = lighthouseDevice is StatefulLighthouseDevice;

  final LighthouseDevice lighthouseDevice;
  final VoidCallback onSelected;
  final bool selected;
  final String? nickname;
  final LighthousePowerState sleepState;
  final bool selecting;
  final bool statefulDevice;

  @override
  State<StatefulWidget> createState() {
    return LighthouseWidgetState();
  }
}

class LighthouseWidgetState extends State<LighthouseWidget> {
  Stream<int>? _powerStateStream;

  @override
  void initState() {
    super.initState();
    if (widget.statefulDevice) {
      _powerStateStream =
          (widget.lighthouseDevice as StatefulLighthouseDevice).powerState;
    }
  }

  @override
  Widget build(final BuildContext context) {
    if (widget.statefulDevice) {
      return StreamBuilder<int>(
        stream: _powerStateStream,
        builder: (final BuildContext context,
            final AsyncSnapshot<int> powerStateSnapshot) {
          final powerStateData = powerStateSnapshot.data ?? 0xFF;

          return LighthouseWidgetContent(
            widget.lighthouseDevice,
            powerStateData: powerStateData,
            onSelected: widget.onSelected,
            selected: widget.selected,
            nickname: widget.nickname,
            sleepState: widget.sleepState,
            selecting: widget.selecting,
          );
        },
      );
    } else {
      return LighthouseWidgetContent(
        widget.lighthouseDevice,
        onSelected: widget.onSelected,
        selected: widget.selected,
        nickname: widget.nickname,
        sleepState: widget.sleepState,
        selecting: widget.selecting,
      );
    }
  }
}

/// Display the state of the device together with the state as a number in hex.
class _LHItemPowerStateWidget extends StatelessWidget {
  const _LHItemPowerStateWidget(
      {final Key? key,
      required this.powerStateByte,
      required this.toPowerState})
      : super(key: key);

  final int? powerStateByte;
  final _ToPowerState toPowerState;

  @override
  Widget build(final BuildContext context) {
    if (kReleaseMode) {
      final state = toPowerState(powerStateByte ?? 0xff);
      return Text(state.text);
    } else {
      final state = toPowerState(powerStateByte ?? 0xff);
      final hexString = powerStateByte?.toRadixString(16) ?? '';
      return Text(
          '${state.text} (0x${hexString.padLeft(hexString.length + (hexString.length % 2), '0')})');
    }
  }
}
