import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:lighthouse_pm/bloc.dart';
import 'package:lighthouse_pm/data/Database.dart';
import 'package:lighthouse_pm/data/local/MainPageSettings.dart';
import 'package:lighthouse_pm/data/tables/GroupTable.dart';
import 'package:lighthouse_pm/dialogs/EnableBluetoothDialogFlow.dart';
import 'package:lighthouse_pm/dialogs/LocationPermissionDialogFlow.dart';
import 'package:lighthouse_pm/lighthouseProvider/LighthouseDevice.dart';
import 'package:lighthouse_pm/lighthouseProvider/LighthouseProvider.dart';
import 'package:lighthouse_pm/lighthouseProvider/ble/DeviceIdentifier.dart';
import 'package:lighthouse_pm/lighthouseProvider/widgets/ChangeGroupAlertWidget.dart';
import 'package:lighthouse_pm/lighthouseProvider/widgets/DifferentGroupItemTypesAlertWidget.dart';
import 'package:lighthouse_pm/lighthouseProvider/widgets/LighthouseGroupWidget.dart';
import 'package:lighthouse_pm/lighthouseProvider/widgets/LighthouseWidget.dart';
import 'package:lighthouse_pm/pages/TroubleshootingPage.dart';
import 'package:lighthouse_pm/widgets/MainPageDrawer.dart';
import 'package:lighthouse_pm/widgets/NicknameAlertWidget.dart';
import 'package:lighthouse_pm/widgets/ScanningMixin.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

import 'BasePage.dart';

const double _DEVICE_LIST_SCROLL_PADDING = 80.0;

Stream<Tuple3<List<Nickname>, List<LighthouseDevice>, List<GroupWithEntries>>>
    _mergeNicknameAndLighthouseDevice(LighthousePMBloc bloc) {
  return Rx.combineLatest3<
          List<Nickname>,
          List<LighthouseDevice>,
          List<GroupWithEntries>,
          Tuple3<List<Nickname>, List<LighthouseDevice>,
              List<GroupWithEntries>>>(
      MergeStream([Stream.value([]), bloc.nicknames.watchSavedNicknames]),
      MergeStream(
          [Stream.value([]), LighthouseProvider.instance.lighthouseDevices]),
      MergeStream([Stream.value([]), bloc.groups.watchGroups()]),
      (nicknames, devices, groups) {
    groups.sort((a, b) => a.group.name.compareTo(b.group.name));
    return Tuple3(nicknames, devices, groups);
  });
}

class MainPage extends BasePage with WithBlocStateless {
  MainPage({Key? key}) : super(key: key, replace: true);

  @override
  Widget buildPage(BuildContext context) {
    return MainPageSettings.mainPageSettingsStreamBuilder(
      bloc: blocWithoutListen(context),
      builder: (context, settings) {
        if (settings != null) {
          return StreamBuilder<BluetoothState>(
              stream: FlutterBlue.instance.state,
              initialData: BluetoothState.unknown,
              builder: (BuildContext context,
                  AsyncSnapshot<BluetoothState> snapshot) {
                final state = snapshot.data;
                return state == BluetoothState.on
                    ? ScanDevicesPage(settings: settings)
                    : BluetoothOffScreen(state: state, settings: settings);
              });
        } else {
          return Text('Booting');
        }
      },
    );
  }
}

class _ScanFloatingButtonWidget extends StatelessWidget with ScanningMixin {
  _ScanFloatingButtonWidget({Key? key, required this.settings})
      : super(key: key);

  final MainPageSettings settings;

  @override
  Widget build(BuildContext context) {
    // The button for starting and stopping scanning.
    return StreamBuilder<bool>(
      stream: LighthouseProvider.instance.isScanning,
      initialData: false,
      builder: (c, snapshot) {
        final isScanning = snapshot.data;
        if (isScanning == true) {
          return FloatingActionButton(
            child: Icon(Icons.stop),
            onPressed: () => stopScan(),
            backgroundColor: Colors.red,
          );
        } else {
          return FloatingActionButton(
            child: Icon(Icons.search),
            onPressed: () async {
              if (await LocationPermissionDialogFlow
                  .showLocationPermissionDialogFlow(context)) {
                await startScan(Duration(seconds: settings.scanDuration));
              }
            },
          );
        }
      },
    );
  }
}

class ScanDevicesPage extends StatefulWidget {
  ScanDevicesPage({Key? key, required this.settings}) : super(key: key);

  final MainPageSettings settings;

  @override
  State<StatefulWidget> createState() {
    return _ScanDevicesPage();
  }
}

class _ScanDevicesPage extends State<ScanDevicesPage>
    with WidgetsBindingObserver, ScanningMixin {
  final selected = Set<LHDeviceIdentifier>();
  var updates = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    startScanWithCheck(Duration(seconds: widget.settings.scanDuration),
        failMessage:
            "Could not start scan because the permission has not been granted");
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  Map<String, String> _nicknamesToMap(List<Nickname> nicknames) {
    return Map.fromEntries(nicknames
        .map((nickname) => MapEntry(nickname.macAddress, nickname.nickname)));
  }

  List<LighthouseDevice> _devicesNotInAGroup(
      List<LighthouseDevice> devices, List<GroupWithEntries> groups) {
    List<LighthouseDevice> output = [];
    final selectedCopy = Set<LHDeviceIdentifier>();
    selectedCopy.addAll(selected);
    final newSelected = Set<LHDeviceIdentifier>();

    for (final device in devices) {
      bloc.nicknames.insertLastSeenDevice(LastSeenDevicesCompanion.insert(
          macAddress: device.deviceIdentifier.toString()));
      // Make sure a device hasn't left
      if (selectedCopy.contains(device.deviceIdentifier)) {
        newSelected.add(device.deviceIdentifier);
      }

      bool found = false;
      for (final group in groups) {
        for (final mac in group.macs) {
          final deviceIdentifier = LHDeviceIdentifier(mac);
          if (selectedCopy.contains(deviceIdentifier)) {
            newSelected.add(deviceIdentifier);
          }
          if (deviceIdentifier == device.deviceIdentifier) {
            found = true;
          }
        }
      }
      if (!found) {
        output.add(device);
      }
    }
    selected.clear();
    selected.addAll(newSelected);

    return output;
  }

  @override
  Widget build(BuildContext context) {
    return buildScanPopScope(
        child: StreamBuilder<
                Tuple3<List<Nickname>, List<LighthouseDevice>,
                    List<GroupWithEntries>>>(
            stream: _mergeNicknameAndLighthouseDevice(bloc),
            initialData: const Tuple3(const [], const [], const []),
            builder: (c, snapshot) {
              updates++;
              final tuple = snapshot.requireData;
              final devices = tuple.item2;
              if (devices.isNotEmpty) {
                devices.sort((a, b) =>
                    a.deviceIdentifier.id.compareTo(b.deviceIdentifier.id));
              }
              final nicknames = _nicknamesToMap(tuple.item1);
              final groups = tuple.item3;
              final notGroupedDevices = _devicesNotInAGroup(devices, groups);

              final listLength = groups.length + notGroupedDevices.length;

              final Widget body = (devices.isEmpty && updates > 2)
                  ? StreamBuilder<bool>(
                      stream: FlutterBlue.instance.isScanning,
                      initialData: true,
                      builder: (context, scanningSnapshot) {
                        final scanning = scanningSnapshot.data;
                        if (scanning == true) {
                          return Container();
                        } else {
                          return Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(12),
                                child: Text(
                                  'Unable to find lighthouses, try some troubleshooting.',
                                  style: Theme.of(context).textTheme.headline4,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                child: TroubleshootingContentWidget(),
                              )
                            ],
                          );
                        }
                      },
                    )
                  : ListView.builder(
                      itemBuilder: (BuildContext context, int index) {
                        if (index == listLength) {
                          // Add an extra container at the bottom to stop the floating
                          // button from obstructing the last item.
                          return Container(
                            height: _DEVICE_LIST_SCROLL_PADDING,
                          );
                        }
                        if (index < groups.length) {
                          return LighthouseGroupWidget(
                            group: groups[index],
                            devices: devices,
                            selectedDevices: selected,
                            nicknameMap: nicknames,
                            sleepState: widget.settings.sleepState,
                            showOfflineWarning:
                                widget.settings.groupShowOfflineWarning,
                            onGroupSelected: () {},
                            onSelectedDevice: (LHDeviceIdentifier device) {
                              setState(() {
                                if (selected.contains(device)) {
                                  selected.remove(device);
                                } else {
                                  selected.add(device);
                                }
                              });
                            },
                          );
                        }

                        index -= groups.length;
                        final device = notGroupedDevices[index];

                        final nickname =
                            nicknames[device.deviceIdentifier.toString()];
                        return LighthouseWidget(
                          device,
                          selected: selected.contains(device.deviceIdentifier),
                          selecting: selected.isNotEmpty,
                          onSelected: () {
                            setState(() {
                              if (selected.contains(device.deviceIdentifier)) {
                                selected.remove(device.deviceIdentifier);
                              } else {
                                selected.add(device.deviceIdentifier);
                              }
                            });
                          },
                          nickname: nickname,
                          sleepState: widget.settings.sleepState,
                        );
                      },
                      itemCount: listLength + 1,
                    );

              final List<Widget> actions = [];
              Color? actionBarColor;
              if (selected.isNotEmpty) {
                actionBarColor = Theme.of(context).selectedRowColor;
                if (selected.length == 1) {
                  actions.add(
                      _getChangeNicknameAction(context, devices, nicknames));
                }
                actions.add(_getChangeGroupAction(context, groups, devices));
              }
              final Widget? leading = selected.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Cancel selection',
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        setState(() {
                          this.selected.clear();
                        });
                      },
                    );

              return Scaffold(
                appBar: AppBar(
                  title: Text('Lighthouse PM'),
                  actions: actions,
                  backgroundColor: actionBarColor,
                  leading: leading,
                ),
                floatingActionButton: _ScanFloatingButtonWidget(
                  settings: widget.settings,
                ),
                drawer: MainPageDrawer(
                    Duration(seconds: widget.settings.scanDuration)),
                body: body,
              );
            }));
  }

  IconButton _getChangeNicknameAction(
    BuildContext context,
    List<LighthouseDevice> devices,
    Map<String, String> nicknames,
  ) {
    return IconButton(
      tooltip: 'Change nickname',
      icon: Icon(Icons.edit_attributes),
      onPressed: () async {
        if (selected.length == 1) {
          final item = selected.first;
          final name = devices.cast<LighthouseDevice?>().singleWhere((element) {
                if (element != null) {
                  return element.deviceIdentifier == item;
                }
                return false;
              }, orElse: () => null)?.name ??
              item.toString();
          final String? nickname = nicknames[item.toString()];

          final newNickname = await NicknameAlertWidget.showCustomDialog(
              context,
              macAddress: item.toString(),
              deviceName: name,
              nickname: nickname);
          if (newNickname != null) {
            if (newNickname.nickname == null) {
              blocWithoutListen.nicknames
                  .deleteNicknames([newNickname.macAddress]);
            } else {
              blocWithoutListen.nicknames
                  .insertNickname(newNickname.toNickname()!);
            }
            selected.remove(item);
          }
        }
      },
    );
  }

  IconButton _getChangeGroupAction(BuildContext context,
      List<GroupWithEntries> groups, List<LighthouseDevice> devices) {
    return IconButton(
        tooltip: 'Change group',
        icon: Icon(Icons.group),
        onPressed: () async {
          final Group? commonGroup = _getGroupFromSelected(groups);
          final Group? newGroup = await ChangeGroupAlertWidget.showCustomDialog(
              context,
              groups: groups,
              selectedGroup: commonGroup);
          if (newGroup != null) {
            if (newGroup.id == ChangeGroupAlertWidget.REMOVE_GROUP_ID) {
              await blocWithoutListen.groups.deleteGroupEntries(
                  selected.map((e) => e.toString()).toList());
            } else if (newGroup.id == ChangeGroupAlertWidget.NEW_GROUP_ID) {
              final int newGroupId = await blocWithoutListen.groups
                  .insertEmptyGroup(
                      GroupsCompanion.insert(name: newGroup.name));
              final insertGroup = Group(id: newGroupId, name: newGroup.name);

              await blocWithoutListen.groups.insertGroup(GroupWithEntries(
                  insertGroup, selected.map((e) => e.toString()).toList()));
            } else {
              final foundGroup = groups
                  .firstWhere((element) => element.group.id == newGroup.id);
              final Set<String> items = Set<String>();
              items.addAll(foundGroup.macs);
              items.addAll(selected.map((e) => e.toString()));
              bool saveChanges = true;
              final allTheSame = _allSameDeviceType(items, devices);
              if (!allTheSame) {
                saveChanges =
                    await DifferentGroupItemTypesAlertWidget.showCustomDialog(
                        context);
              }
              if (saveChanges) {
                await blocWithoutListen.groups
                    .insertGroup(GroupWithEntries(newGroup, items.toList()));
              }
            }
          }
          selected.clear();
        });
  }

  Group? _getGroupFromSelected(List<GroupWithEntries> groups) {
    Group? firstGroup;
    for (final selectedDevice in selected) {
      bool found = false;
      for (final group in groups) {
        if (group.macs.contains(selectedDevice.toString())) {
          if (firstGroup == null) {
            firstGroup = group.group;
          } else if (firstGroup.id != group.group.id) {
            return null;
          }
          found = true;
          break;
        }
      }
      if (!found) {
        return null;
      }
    }
    return firstGroup;
  }

  /// Check if all the devices in the selected group are of the same type.
  /// If they aren't we should show a warning.
  bool _allSameDeviceType(
      Set<String> deviceIds, List<LighthouseDevice> devices) {
    final foundTypes = Set<String>();
    for (final deviceId in deviceIds) {
      final device = devices.cast<LighthouseDevice?>().firstWhere(
          (element) => element?.deviceIdentifier.toString() == deviceId,
          orElse: () => null);
      if (device != null) {
        foundTypes.add(device.runtimeType.toString());
        if (foundTypes.length > 1) {
          return false;
        }
      }
    }
    return foundTypes.length <= 1;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        setState(() {
          this.updates = 0;
          selected.clear();
        });
        cleanUp();
        break;
      case AppLifecycleState.resumed:
        startScanWithCheck(Duration(seconds: widget.settings.scanDuration),
            failMessage:
                "Could not start scan because the permission has not been granted on resume.");
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        // Do nothing.
        break;
    }
  }
}

class BluetoothOffScreen extends StatelessWidget with ScanningMixin {
  const BluetoothOffScreen(
      {Key? key, required this.state, required this.settings})
      : super(key: key);

  final BluetoothState? state;
  final MainPageSettings settings;

  Widget _toSettingsButton(BuildContext context) {
    if (Platform.isAndroid && state == BluetoothState.off) {
      return ElevatedButton(
          onPressed: () async {
            await EnableBluetoothDialogFlow.showEnableBluetoothDialogFlow(
                context);
          },
          child: Text(
            'Enable Bluetooth.',
            style: Theme.of(context)
                .textTheme
                .bodyText1
                ?.copyWith(color: Colors.black),
          ));
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      drawer: MainPageDrawer(Duration(seconds: settings.scanDuration)),
      appBar: AppBar(
        title: Text('Lighthouse PM'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.bluetooth_disabled,
              size: 200.0,
              color: Colors.white54,
            ),
            Text(
              'Bluetooth is ${state != null ? state.toString().substring(15) : 'not available'}.',
              style: Theme.of(context)
                  .textTheme
                  .headline6!
                  .copyWith(color: Colors.white),
            ),
            Text(
              'Bluetooth needs to be enabled to talk to the lighthouses',
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  ?.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            _toSettingsButton(context)
          ],
        ),
      ),
    );
  }
}
