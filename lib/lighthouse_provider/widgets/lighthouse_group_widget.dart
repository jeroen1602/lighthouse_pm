import 'package:flutter/material.dart';
import 'package:lighthouse_pm/bloc.dart';
import 'package:lighthouse_pm/data/database.dart';
import 'package:lighthouse_pm/data/tables/group_table.dart';
import 'package:lighthouse_pm/theming.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

import '../ble/device_identifier.dart';
import '../device_extensions/standby_extension.dart';
import '../lighthouse_device.dart';
import '../lighthouse_power_state.dart';
import 'lighthouse_power_button_widget.dart';
import 'lighthouse_widget.dart';
import 'offline_group_item_alert_widget.dart';
import 'offline_lighthouse_widget.dart';
import 'unknown_group_state_alert_widget.dart';

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
      required this.selectedGroup,
      this.sleepState = LighthousePowerState.sleep,
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
  final Group? selectedGroup;

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
              onSelected: onGroupSelected,
              selected: isSelected(),
              selecting: selectedDevices.isNotEmpty || selectedGroup != null,
              onPowerButtonPress: () async {
                await _handleGroupPowerButton(
                  context,
                  combinedState: averagePowerState,
                  isStateUniversal: combinedPowerStateTuple.item1,
                  onlineDevices: onlineAndOfflineDevices.item2,
                  hasOfflineDevices: onlineAndOfflineDevices.item1.isNotEmpty,
                  states: powerStates
                      .map((key, value) => MapEntry(key, value.item2)),
                );
              },
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
  /// It will return [LighthousePowerState.unknown] if all power states don't
  /// match up. Will return the power state if all the devices have the same
  /// power state. It also returns a boolean if the returned state is universal
  /// or if [LighthousePowerState.unknown] was returned early.
  Tuple2<bool, LighthousePowerState> _getCombinedPowerState(
    Map<String, Tuple2<int, LighthousePowerState>> powerStates,
  ) {
    final states = powerStates.values.map((value) => value.item2).toList();
    if (states.isEmpty) {
      return Tuple2(true, LighthousePowerState.unknown);
    }
    final firstState = states[0];
    for (final state in states) {
      if (state != firstState) {
        return Tuple2(false, LighthousePowerState.unknown);
      }
    }
    return Tuple2(true, firstState);
  }

  /// Combine all the power state streams of the devices into a [Stream] which
  /// returns a [Map] of the device id and the power state of the
  /// [LighthouseDevice]. Every device will start out with the state `0xFF`
  /// ([LighthousePowerState.unknown]). The [Tuple2] contains the raw power
  /// state [int] and the converted [LighthousePowerState].
  Stream<Map<String, Tuple2<int, LighthousePowerState>>> _combinePowerStates(
      List<LighthouseDevice> devices) {
    final devicePowerStates = devices.map((device) {
      final String deviceId = device.deviceIdentifier.toString();
      return MergeStream([
        Stream.value(
            MapEntry(deviceId, Tuple2(0xFF, LighthousePowerState.unknown))),
        device.powerState.map((event) {
          return MapEntry(
              deviceId, Tuple2(event, device.powerStateFromByte(event)));
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
    if (group.deviceIds.isEmpty) {
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
      final deviceId = device.value.deviceIdentifier.toString();
      final powerState = powerStates[deviceId]?.item1 ?? 0xFF;
      children.add(LighthouseWidgetContent(
        device.value,
        powerState,
        onSelected: () {
          onSelectedDevice(device.value.deviceIdentifier);
        },
        selected: selectedDevices.contains(device.value.deviceIdentifier),
        selecting: selectedDevices.isNotEmpty || selectedGroup != null,
        nickname: nicknameMap[deviceId],
        sleepState: sleepState,
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
        selecting: selectedDevices.isNotEmpty || selectedGroup != null,
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
    final List<String> offlineDeviceIds = List.from(group.deviceIds);
    final List<LighthouseDevice> foundDevices = devices.where((device) {
      final index = offlineDeviceIds.indexWhere(
          (deviceId) => deviceId == device.deviceIdentifier.toString());
      if (index >= 0) {
        offlineDeviceIds.removeAt(index);
        return true;
      }
      return false;
    }).toList();

    return Tuple2(offlineDeviceIds, foundDevices);
  }

  /// Check if the devices in [onlineDevices] support
  /// [LighthousePowerState.standby]. This will return `true` if one of the
  /// devices supports [LighthousePowerState.standby]. It can happen that one
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
    required Map<String, LighthousePowerState> states,
  }) async {
    if (hasOfflineDevices && showOfflineWarning) {
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
    if (combinedState == LighthousePowerState.unknown) {
      final state = await UnknownGroupStateAlertWidget.showCustomDialog(
          context, _supportsStandby(onlineDevices), isStateUniversal);
      if (state == null) {
        return;
      }
      newState = state;
    } else if (combinedState == LighthousePowerState.on) {
      newState = sleepState;
    } else if (combinedState == LighthousePowerState.booting) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
          content: Text('Lighthouse is already booting!'),
          action: SnackBarAction(
            label: 'I\'m sure',
            onPressed: () async {
              await _switchStateAll(onlineDevices, sleepState, states);
            },
          )));
    } else {
      newState = LighthousePowerState.on;
    }
    await _switchStateAll(onlineDevices, newState, states);
  }

  /// Switch the state of all the online devices.
  /// This will also check if the [LighthousePowerState.standby] is supported
  /// for the current device.
  Future<void> _switchStateAll(
    List<LighthouseDevice> onlineDevices,
    LighthousePowerState newState,
    Map<String, LighthousePowerState> states,
  ) async {
    List<Future<void>> futures = [];
    for (final device in onlineDevices) {
      final currentState = states[device.deviceIdentifier.toString()];
      if (currentState == newState) {
        debugPrint('Device is already in the correct state.');
        continue;
      }
      var state = newState;
      if (state == LighthousePowerState.standby &&
          !device.hasStandbyExtension) {
        state = LighthousePowerState.sleep;
        debugPrint(
            'The device doesn\'t support STANDBY so SLEEP will always be used.');
      }
      futures.add(device.changeState(state));
    }
    await Future.wait(futures);
  }

  bool isSelected() {
    final selected = isGroupSelected(
        group.deviceIds, selectedDevices.map((e) => e.toString()).toList());
    if (!selected) {
      return group.group.id == selectedGroup?.id;
    }
    return selected;
  }

  static bool isGroupSelected(List<String> deviceIds, List<String> selected) {
    if (deviceIds.isEmpty) {
      return false;
    }
    if (deviceIds.length != selected.length) {
      return false;
    }
    for (final deviceId in deviceIds) {
      if (!selected.contains(deviceId)) {
        return false;
      }
    }
    return true;
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
    required this.selecting,
    required this.group,
    required this.stateButtonDisabled,
  }) : super(key: key);

  final LighthousePowerState powerState;
  final VoidCallback onPowerButtonPress;
  final VoidCallback onSelected;
  final bool selected;
  final bool selecting;
  final Group group;
  final bool stateButtonDisabled;

  @override
  Widget build(BuildContext context) {
    final theming = Theming.of(context);

    return Container(
      color: selected ? theming.selectedRowColor : Colors.transparent,
      child: InkWell(
          onLongPress: onSelected,
          onTap: selecting ? onSelected : null,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Text(
                    group.name,
                    style: theming.headline4,
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
