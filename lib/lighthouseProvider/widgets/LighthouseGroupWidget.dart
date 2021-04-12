import 'package:flutter/material.dart';
import 'package:lighthouse_pm/bloc.dart';
import 'package:lighthouse_pm/data/Database.dart';
import 'package:lighthouse_pm/data/tables/GroupTable.dart';
import 'package:lighthouse_pm/lighthouseProvider/ble/DeviceIdentifier.dart';
import 'package:lighthouse_pm/lighthouseProvider/deviceExtensions/StandbyExtension.dart';
import 'package:lighthouse_pm/lighthouseProvider/widgets/LighthousePowerButtonWidget.dart';
import 'package:lighthouse_pm/lighthouseProvider/widgets/LighthouseWidget.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

import '../LighthouseDevice.dart';
import '../LighthousePowerState.dart';
import 'OfflineGroupItemAlertWidget.dart';
import 'OfflineLighthouseWidget.dart';
import 'UnknownGroupStateAlertWidget.dart';

typedef SelectedDeviceFunction = void Function(LHDeviceIdentifier identifier);

/// A widget for showing lighthouses as a group.
///
class LighthouseGroupWidget extends StatelessWidget with WithBlocStateless {
  LighthouseGroupWidget(
      {required this.group,
      required this.devices,
      required this.nicknameMap,
      required this.showOfflineWarning,
      required this.onSelectedDevice,
      required this.onGroupSelected,
      required this.selectedDevices,
      this.sleepState = LighthousePowerState.SLEEP,
      Key? key})
      : super(key: key);

  final GroupWithEntries group;
  final List<LighthouseDevice> devices;
  final Map<String, String> nicknameMap;
  final LighthousePowerState sleepState;
  final bool showOfflineWarning;
  final SelectedDeviceFunction onSelectedDevice;
  final VoidCallback onGroupSelected;
  final Set<LHDeviceIdentifier> selectedDevices;

  @override
  Widget build(BuildContext context) {
    final TextDirection textDirection = Directionality.of(context);
    final EdgeInsets groupItemPadding =
        EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0).resolve(textDirection);

    final onlineAndOfflineDevices = _getOnlineAndOfflineDevices();

    return StreamBuilder<Map<String, Tuple2<int, LighthousePowerState>>>(
      stream: _combinePowerStates(onlineAndOfflineDevices.item2),
      builder: (BuildContext context,
          AsyncSnapshot<Map<String, Tuple2<int, LighthousePowerState>>>
              powerStatesSnapshot) {
        final powerStates = powerStatesSnapshot.data ?? {};
        final combinedPowerStateTuple = _getCombinedPowerState(powerStates);
        final averagePowerState = combinedPowerStateTuple.item2;
        return Column(
          children: [
            _LighthouseGroupWidgetHeader(
              powerState: averagePowerState,
              onSelected: this.onGroupSelected,
              onPowerButtonPress: () async {
                await _handleGroupPowerButton(
                  context,
                  combinedState: averagePowerState,
                  isStateUniversal: combinedPowerStateTuple.item1,
                  onlineDevices: onlineAndOfflineDevices.item2,
                  hasOfflineDevices: onlineAndOfflineDevices.item1.isNotEmpty,
                );
              },
              selected: false,
              group: group.group,
              stateButtonDisabled: onlineAndOfflineDevices.item2.isEmpty,
            ),
            Divider(thickness: 0.7),
            Container(
              margin: groupItemPadding,
              child: Column(
                  children: _getGroupItems(
                      context, powerStates, onlineAndOfflineDevices)),
            ),
            Divider(
              thickness: 1.5,
            ),
          ],
        );
      },
    );
  }

  /// Get the the combined power state of all the online devices in the group.
  /// It will return [LighthousePowerState.UNKNOWN] if all power states don't
  /// match up. Will return the power state if all the devices have the same
  /// power state. It also returns a boolean if the returned state is universal
  /// or if [LighthousePowerState.UNKNOWN] was returned early.
  Tuple2<bool, LighthousePowerState> _getCombinedPowerState(
    Map<String, Tuple2<int, LighthousePowerState>> powerStates,
  ) {
    final states = powerStates.values.map((value) => value.item2).toList();
    if (states.isEmpty) {
      return Tuple2(true, LighthousePowerState.UNKNOWN);
    }
    final firstState = states[0];
    for (final state in states) {
      if (state != firstState) {
        return Tuple2(false, LighthousePowerState.UNKNOWN);
      }
    }
    return Tuple2(true, firstState);
  }

  /// Combine all the power state streams of the devices into a [Stream] which
  /// returns a [Map] of the mac address and the power state of the
  /// [LighthouseDevice]. Every device will start out with the state `0xFF`
  /// ([LighthousePowerState.UNKNOWN]). The [Tuple2] contains the raw power
  /// state [int] and the converted [LighthousePowerState].
  Stream<Map<String, Tuple2<int, LighthousePowerState>>> _combinePowerStates(
      List<LighthouseDevice> devices) {
    final devicePowerStates = devices.map((device) {
      final String mac = device.deviceIdentifier.toString();
      return MergeStream([
        Stream.value(MapEntry(mac, Tuple2(0xFF, LighthousePowerState.UNKNOWN))),
        device.powerState.map((event) {
          return MapEntry(mac, Tuple2(event, device.powerStateFromByte(event)));
        })
      ]);
    });
    return Rx.combineLatestList(devicePowerStates).map((items) {
      return Map.fromEntries(items);
    });
  }

  /// Get the group items for this group.
  ///
  /// [powerStates] should contain the states of [LighthouseDevice]s that are
  /// already known.
  /// [onlineAndOfflineDevices] contains a [Tuple2] of the online and offline
  /// devices to add to the widget.
  List<Widget> _getGroupItems(
    BuildContext context,
    Map<String, Tuple2<int, LighthousePowerState>> powerStates,
    Tuple2<List<String>, List<LighthouseDevice>> onlineAndOfflineDevices,
  ) {
    if (group.macs.isEmpty) {
      return [
        ListTile(
          title: Text('No group items yet'),
        )
      ];
    }
    final List<Widget> children = [];
    // First the online devices.
    final onlineDevices = onlineAndOfflineDevices.item2;
    for (final device in onlineDevices.asMap().entries) {
      final mac = device.value.deviceIdentifier.toString();
      final powerState = powerStates[mac]?.item1 ?? 0xFF;
      children.add(LighthouseWidgetContent(
        device.value,
        powerState,
        onSelected: () {
          onSelectedDevice(device.value.deviceIdentifier);
        },
        selected: selectedDevices.contains(device.value.deviceIdentifier),
        selecting: selectedDevices.isNotEmpty,
        nickname: nicknameMap[mac],
        sleepState: this.sleepState,
      ));
      if (device.key < onlineDevices.length - 1 ||
          (device.key == onlineDevices.length - 1 &&
              onlineDevices.isNotEmpty)) {
        children.add(Divider());
      }
    }

    final offlineDevices = onlineAndOfflineDevices.item1;
    for (final offlineDevice in offlineDevices.asMap().entries) {
      final LHDeviceIdentifier deviceIdentifier =
          LHDeviceIdentifier(offlineDevice.value);
      children.add(OfflineLighthouseWidget(
        offlineDevice.value,
        onSelected: () {
          onSelectedDevice(deviceIdentifier);
        },
        selected: selectedDevices.contains(deviceIdentifier),
        selecting: selectedDevices.isNotEmpty,
        nickname: nicknameMap[offlineDevice.value],
      ));
      if (offlineDevice.key < offlineDevices.length - 1) {
        children.add(Divider());
      }
    }

    return children;
  }

  /// Get a [Tuple2] with a list of offline and online devices. The first item
  /// is offline and the second item is online.
  Tuple2<List<String>, List<LighthouseDevice>> _getOnlineAndOfflineDevices() {
    final List<String> offlineMacs = List.from(group.macs);
    final List<LighthouseDevice> foundDevices = devices.where((device) {
      final index = offlineMacs.indexWhere(
          (mac) => mac.toUpperCase() == device.deviceIdentifier.toString());
      if (index >= 0) {
        offlineMacs.removeAt(index);
        return true;
      }
      return false;
    }).toList();

    return Tuple2(offlineMacs, foundDevices);
  }

  /// Check if the devices in [onlineDevices] support
  /// [LighthousePowerState.STANDBY]. This will return `true` if one of the
  /// devices supports [LighthousePowerState.STANDBY]. It can happen that one
  /// of the devices doesn't support it though.
  bool _supportsStandby(List<LighthouseDevice> onlineDevices) {
    for (final device in onlineDevices) {
      if (device.hasStandbyExtension) {
        return true;
      }
    }
    return false;
  }

  /// Handle the power button for a group. This will check the current state
  /// and switch over to the opposite one.
  Future<void> _handleGroupPowerButton(
    BuildContext context, {
    required LighthousePowerState combinedState,
    required bool isStateUniversal,
    required List<LighthouseDevice> onlineDevices,
    required bool hasOfflineDevices,
  }) async {
    if (hasOfflineDevices && this.showOfflineWarning) {
      final returnValue =
          await OfflineGroupItemAlertWidget.showCustomDialog(context);
      if (returnValue.dialogCanceled) {
        return; // The dialog was canceled so do nothing.
      }
      if (returnValue.disableWarning) {
        // Disable the dialog in the future.
        await blocWithoutListen(context)
            .settings
            .setGroupOfflineWarningEnabled(false);
      }
    }
    var newState = combinedState;
    if (combinedState == LighthousePowerState.UNKNOWN) {
      final state = await UnknownGroupStateAlertWidget.showCustomDialog(
          context, _supportsStandby(onlineDevices), isStateUniversal);
      if (state == null) {
        return;
      }
      newState = state;
    } else if (combinedState == LighthousePowerState.ON) {
      newState = this.sleepState;
    } else if (combinedState == LighthousePowerState.BOOTING) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
          content: Text('Lighthouse is already booting!'),
          action: SnackBarAction(
            label: 'I\'m sure',
            onPressed: () async {
              await this._switchStateAll(onlineDevices, this.sleepState);
            },
          )));
    } else {
      newState = LighthousePowerState.ON;
    }
    await _switchStateAll(onlineDevices, newState);
  }

  /// Switch the state of all the online devices.
  /// This will also check if the [LighthousePowerState.STANDBY] is supported
  /// for the current device.
  Future<void> _switchStateAll(List<LighthouseDevice> onlineDevices,
      LighthousePowerState newState) async {
    List<Future<void>> futures = [];
    for (final device in onlineDevices) {
      var state = newState;
      if (state == LighthousePowerState.STANDBY &&
          !device.hasStandbyExtension) {
        state = LighthousePowerState.SLEEP;
        debugPrint(
            'The device doesn\'t support STANDBY so SLEEP will always be used.');
      }
      futures.add(device.changeState(state));
    }
    await Future.wait(futures);
  }
}

/// The header for the group widget.
///
/// This widget shows the group name and a power button with the average state
/// of the devices in the group.
class _LighthouseGroupWidgetHeader extends StatelessWidget {
  const _LighthouseGroupWidgetHeader({
    Key? key,
    required this.powerState,
    required this.onPowerButtonPress,
    required this.onSelected,
    required this.selected,
    required this.group,
    required this.stateButtonDisabled,
  }) : super(key: key);

  final LighthousePowerState powerState;
  final VoidCallback onPowerButtonPress;
  final VoidCallback onSelected;
  final bool selected;
  final Group group;
  final bool stateButtonDisabled;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      color: selected ? theme.selectedRowColor : Colors.transparent,
      child: InkWell(
          onLongPress: onSelected,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Text(
                    group.name,
                    style: theme.textTheme.headline4
                        ?.copyWith(color: theme.textTheme.bodyText1?.color),
                  ),
                )),
                LighthousePowerButtonWidget(
                  powerState: powerState,
                  onPress: onPowerButtonPress,
                  disabled: stateButtonDisabled,
                )
              ],
            ),
          )),
    );
  }
}
