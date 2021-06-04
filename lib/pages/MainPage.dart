import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_web_bluetooth/flutter_web_bluetooth.dart';
import 'package:lighthouse_pm/Theming.dart';
import 'package:lighthouse_pm/bloc.dart';
import 'package:lighthouse_pm/data/Database.dart';
import 'package:lighthouse_pm/data/local/MainPageSettings.dart';
import 'package:lighthouse_pm/data/tables/GroupTable.dart';
import 'package:lighthouse_pm/dialogs/EnableBluetoothDialogFlow.dart';
import 'package:lighthouse_pm/dialogs/LocationPermissionDialogFlow.dart';
import 'package:lighthouse_pm/lighthouseProvider/LighthouseDevice.dart';
import 'package:lighthouse_pm/lighthouseProvider/LighthouseProvider.dart';
import 'package:lighthouse_pm/lighthouseProvider/adapterState/AdapterState.dart';
import 'package:lighthouse_pm/lighthouseProvider/backEnd/PairBackEnd.dart';
import 'package:lighthouse_pm/lighthouseProvider/ble/DeviceIdentifier.dart';
import 'package:lighthouse_pm/lighthouseProvider/widgets/ChangeGroupAlertWidget.dart';
import 'package:lighthouse_pm/lighthouseProvider/widgets/ChangeGroupNameAlertWidget.dart';
import 'package:lighthouse_pm/lighthouseProvider/widgets/DeleteGroupAlertWidget.dart';
import 'package:lighthouse_pm/lighthouseProvider/widgets/DifferentGroupItemChannelAlertWidget.dart';
import 'package:lighthouse_pm/lighthouseProvider/widgets/DifferentGroupItemTypesAlertWidget.dart';
import 'package:lighthouse_pm/lighthouseProvider/widgets/LighthouseGroupWidget.dart';
import 'package:lighthouse_pm/lighthouseProvider/widgets/LighthouseWidget.dart';
import 'package:lighthouse_pm/pages/TroubleshootingPage.dart';
import 'package:lighthouse_pm/platformSpecific/shared/LocalPlatform.dart';
import 'package:lighthouse_pm/widgets/ContentContainerWidget.dart';
import 'package:lighthouse_pm/widgets/MainPageDrawer.dart';
import 'package:lighthouse_pm/widgets/NicknameAlertWidget.dart';
import 'package:lighthouse_pm/widgets/ScanningMixin.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';
import 'package:web_browser_detect/web_browser_detect.dart';

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
          return StreamBuilder<BluetoothAdapterState>(
              stream: LighthouseProvider.instance.state,
              initialData: BluetoothAdapterState.unknown,
              builder: (BuildContext context,
                  AsyncSnapshot<BluetoothAdapterState> snapshot) {
                final state = snapshot.data;
                return state == BluetoothAdapterState.on
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
  const _ScanFloatingButtonWidget({Key? key, required this.settings})
      : super(key: key);

  final MainPageSettings settings;

  Stream<int> getPairedDevicesStream(List<PairBackEnd> backEnds) {
    return Rx.combineLatestList(backEnds.map((e) => e.numberOfPairedDevices()))
        .map((event) => event.reduce((value, element) => element + value));
  }

  @override
  Widget build(BuildContext context) {
    final pairBackEnds = LighthouseProvider.instance.getPairBackEnds();
    final onlyPairBackEnds = LighthouseProvider.instance.hasOnlyPairBackends();
    final pairedDevicesStream = getPairedDevicesStream(pairBackEnds);

    return StreamBuilder<int>(
      stream: pairedDevicesStream,
      initialData: 0,
      builder:
          (BuildContext context, AsyncSnapshot<int> pairedDevicesSnapshot) {
        var pairedDevices = 0;
        if (pairedDevicesSnapshot.hasError) {
          debugPrint(pairedDevicesSnapshot.error.toString());
        } else {
          pairedDevices = pairedDevicesSnapshot.requireData;
        }
        final shouldScanBeDisabled = onlyPairBackEnds && pairedDevices <= 0;
        final theming = Theming.of(context);

        return Row(
          children: [
            Spacer(),
            if (pairBackEnds.isNotEmpty) ...[
              FloatingActionButton(
                heroTag: 'pairButton',
                child: Icon(Icons.bluetooth_connected),
                onPressed: () {
                  if (pairBackEnds.length > 1) {
                    // TODO show dialog to select the provider
                  } else {
                    pairBackEnds[0].pairNewDevice(
                        timeout: Duration(seconds: settings.scanDuration),
                        updateInterval:
                            Duration(seconds: settings.updateInterval));
                  }
                },
                tooltip: 'Pair a new device',
              ),
              Padding(
                padding: EdgeInsets.all(4.0),
              ),
            ],
            // The button for starting and stopping scanning.
            StreamBuilder<bool>(
              stream: LighthouseProvider.instance.isScanning,
              initialData: false,
              builder: (c, snapshot) {
                final isScanning = snapshot.data;
                if (isScanning == true) {
                  return FloatingActionButton(
                    heroTag: 'scanButton',
                    child: Icon(Icons.stop),
                    onPressed: () => stopScan(),
                    backgroundColor: Colors.red,
                    tooltip: 'Stop scanning',
                  );
                } else {
                  return FloatingActionButton(
                    heroTag: 'scanButton',
                    child: Icon(Icons.search),
                    backgroundColor:
                        shouldScanBeDisabled ? theming.disabledColor : null,
                    elevation: shouldScanBeDisabled ? 0 : null,
                    hoverElevation: shouldScanBeDisabled ? 0 : null,
                    onPressed: () async {
                      if (shouldScanBeDisabled) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                'Please pair a device first, before scanning for devices.')));
                        return;
                      }
                      if (await LocationPermissionDialogFlow
                          .showLocationPermissionDialogFlow(context)) {
                        await startScan(
                          Duration(seconds: settings.scanDuration),
                          updateInterval:
                              Duration(seconds: settings.updateInterval),
                        );
                      }
                    },
                    tooltip: 'Start scanning',
                  );
                }
              },
            )
          ],
        );
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
  Group? selectedGroup;
  var updates = 0;

  void clearSelected() {
    selected.clear();
    selectedGroup = null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    startScanWithCheck(Duration(seconds: widget.settings.scanDuration),
        updateInterval: Duration(seconds: widget.settings.updateInterval),
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
        .map((nickname) => MapEntry(nickname.deviceId, nickname.nickname)));
  }

  List<LighthouseDevice> _devicesNotInAGroup(
      List<LighthouseDevice> devices, List<GroupWithEntries> groups) {
    List<LighthouseDevice> output = [];
    final selectedCopy = Set<LHDeviceIdentifier>();
    selectedCopy.addAll(selected);
    final newSelected = Set<LHDeviceIdentifier>();

    for (final device in devices) {
      bloc.nicknames.insertLastSeenDevice(LastSeenDevicesCompanion.insert(
          deviceId: device.deviceIdentifier.toString()));
      // Make sure a device hasn't left
      if (selectedCopy.contains(device.deviceIdentifier)) {
        newSelected.add(device.deviceIdentifier);
      }

      bool found = false;
      bool groupFound = false;
      for (final group in groups) {
        for (final deviceId in group.deviceIds) {
          final deviceIdentifier = LHDeviceIdentifier(deviceId);
          if (selectedCopy.contains(deviceIdentifier)) {
            newSelected.add(deviceIdentifier);
          }
          if (deviceIdentifier == device.deviceIdentifier) {
            found = true;
          }
        }
        if (group.group.id == this.selectedGroup?.id) {
          groupFound = true;
        }
      }
      if (!groupFound) {
        this.selectedGroup = null;
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
    final selecting = selected.isNotEmpty || selectedGroup != null;
    return buildScanPopScope(
        beforeWillPop: () async {
          if (selecting) {
            setState(() {
              clearSelected();
            });
            return false;
          }
          return true;
        },
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
              final theming = Theming.of(context);

              final Widget body = (devices.isEmpty && updates > 2)
                  ? StreamBuilder<bool>(
                      stream: LighthouseProvider.instance.isScanning,
                      initialData: true,
                      builder: (context, scanningSnapshot) {
                        final scanning = scanningSnapshot.data;
                        if (scanning == true) {
                          return Container();
                        } else {
                          return ContentContainerListView(children: [
                            Padding(
                              padding: EdgeInsets.all(12),
                              child: Text(
                                'Unable to find lighthouses, try some troubleshooting.',
                                style: theming.headline4,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Divider(
                              thickness: 1.5,
                            ),
                            ...TroubleshootingContentWidget.getContent(context),
                            // Add an extra container at the bottom to stop the floating
                            // button from obstructing the last item.
                            Container(
                              height: _DEVICE_LIST_SCROLL_PADDING,
                            ),
                          ]);
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
                            selectedGroup: selectedGroup,
                            nicknameMap: nicknames,
                            sleepState: widget.settings.sleepState,
                            showOfflineWarning:
                                widget.settings.groupShowOfflineWarning,
                            onGroupSelected: () {
                              setState(() {
                                if (groups[index].deviceIds.isEmpty) {
                                  clearSelected();
                                  selectedGroup = groups[index].group;
                                  return;
                                }
                                if (LighthouseGroupWidget.isGroupSelected(
                                    groups[index].deviceIds,
                                    this
                                        .selected
                                        .map((e) => e.toString())
                                        .toList())) {
                                  clearSelected();
                                } else {
                                  clearSelected();
                                  selected.addAll(groups[index]
                                      .deviceIds
                                      .map((e) => LHDeviceIdentifier(e)));
                                }
                              });
                            },
                            onSelectedDevice: (LHDeviceIdentifier device) {
                              setState(() {
                                selectedGroup = null;
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
                          selecting: selecting,
                          onSelected: () {
                            setState(() {
                              selectedGroup = null;
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
              if (selecting) {
                actionBarColor = theming.selectedRowColor;
                if (selected.length == 1) {
                  actions.add(_getChangeNicknameAction(
                      context, devices, nicknames, theming));
                }
                if (selected.isNotEmpty) {
                  actions.add(
                      _getChangeGroupAction(context, groups, devices, theming));
                }
                final Group? currentlySelectedGroup =
                    _getSelectedGroupFromSelected(groups);
                if (currentlySelectedGroup != null) {
                  actions.add(_getChangeGroupNameAction(
                      context, currentlySelectedGroup, theming));
                  actions.add(_getDeleteGroupNameAction(
                      context, currentlySelectedGroup, theming));
                }
              }
              final Widget? leading = selecting
                  ? IconButton(
                      tooltip: 'Cancel selection',
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        setState(() {
                          clearSelected();
                        });
                      },
                    )
                  : null;

              return Scaffold(
                appBar: AppBar(
                  title: const Text('Lighthouse PM'),
                  actions: actions,
                  backgroundColor: actionBarColor,
                  leading: leading,
                ),
                floatingActionButton: _ScanFloatingButtonWidget(
                  settings: widget.settings,
                ),
                drawer: MainPageDrawer(
                    Duration(seconds: widget.settings.scanDuration),
                    Duration(seconds: widget.settings.updateInterval)),
                body: body,
              );
            }));
  }

  /// Get the change nickname action, this action is only for a single item.
  IconButton _getChangeNicknameAction(
    BuildContext context,
    List<LighthouseDevice> devices,
    Map<String, String> nicknames,
    Theming theming,
  ) {
    return IconButton(
      tooltip: 'Change nickname',
      icon: SvgPicture.asset('assets/images/nickname-icon.svg',
          color: theming.iconColor),
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
              deviceId: item.toString(),
              deviceName: name,
              nickname: nickname);
          if (newNickname != null) {
            if (newNickname.nickname == null) {
              blocWithoutListen.nicknames
                  .deleteNicknames([newNickname.deviceId]);
            } else {
              blocWithoutListen.nicknames
                  .insertNickname(newNickname.toNickname()!);
            }
            setState(() {
              clearSelected();
            });
          }
        }
      },
    );
  }

  /// Get the action for changing a group.
  IconButton _getChangeGroupAction(
      BuildContext context,
      List<GroupWithEntries> groups,
      List<LighthouseDevice> devices,
      Theming theming) {
    return IconButton(
        tooltip: 'Change group',
        icon: SvgPicture.asset('assets/images/group-add-icon.svg',
            color: theming.iconColor),
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
              // The devices that have been selected.
              final List<LighthouseDevice> selectedDevices =
                  devices.where((device) {
                return selected.contains(device.deviceIdentifier);
              }).toList();

              final int newGroupId = await blocWithoutListen.groups
                  .insertEmptyGroup(
                      GroupsCompanion.insert(name: newGroup.name));
              final insertGroup = Group(id: newGroupId, name: newGroup.name);

              final saveChanges = await _checkDevicesBeforeAddingToAGroup(
                  context, selectedDevices);

              if (saveChanges) {
                await blocWithoutListen.groups.insertGroup(GroupWithEntries(
                    insertGroup, selected.map((e) => e.toString()).toList()));
              }
            } else {
              final foundGroup = groups
                  .firstWhere((element) => element.group.id == newGroup.id);
              final Set<String> items = Set<String>();
              items.addAll(foundGroup.deviceIds);
              items.addAll(selected.map((e) => e.toString()));

              // The devices that have been selected.
              final List<LighthouseDevice> selectedDevices =
                  devices.where((device) {
                return items.contains(device.deviceIdentifier.toString());
              }).toList();

              final saveChanges = await _checkDevicesBeforeAddingToAGroup(
                  context, selectedDevices);
              if (saveChanges) {
                await blocWithoutListen.groups
                    .insertGroup(GroupWithEntries(newGroup, items.toList()));
              }
            }
            setState(() {
              clearSelected();
            });
          }
        });
  }

  /// Get the change name action for a group.
  IconButton _getChangeGroupNameAction(
      BuildContext context, Group group, Theming theming) {
    return IconButton(
        tooltip: 'Rename group',
        icon: SvgPicture.asset('assets/images/group-edit-icon.svg',
            color: theming.iconColor),
        onPressed: () async {
          final newName = await ChangeGroupNameAlertWidget.showCustomDialog(
              context,
              initialGroupName: group.name);
          if (newName != null) {
            await blocWithoutListen.groups
                .insertJustGroup(Group(id: group.id, name: newName));
            setState(() {
              clearSelected();
            });
          }
        });
  }

  /// Get the action for deleting a group.
  IconButton _getDeleteGroupNameAction(
      BuildContext context, Group group, Theming theming) {
    return IconButton(
        tooltip: 'Delete group',
        icon: SvgPicture.asset('assets/images/group-delete-icon.svg',
            color: theming.iconColor),
        onPressed: () async {
          if (await DeleteGroupAlertWidget.showCustomDialog(context,
              group: group)) {
            await blocWithoutListen.groups.deleteGroup(group.id);
            setState(() {
              clearSelected();
            });
          }
        });
  }

  /// Check if the devices to be added to a group have some compatibility error
  /// This will show a dialog if this is the case.
  Future<bool> _checkDevicesBeforeAddingToAGroup(
      BuildContext context, List<LighthouseDevice> devicesToBeInAGroup) async {
    // check channel.
    if (!_checkDevicesHaveUniqueChannel(devicesToBeInAGroup)) {
      if (!await DifferentGroupItemChannelAlertWidget.showCustomDialog(
          context)) {
        return false;
      }
    }
    // Check device type
    if (!_allSameDeviceType(devicesToBeInAGroup)) {
      if (!await DifferentGroupItemTypesAlertWidget.showCustomDialog(context)) {
        return false;
      }
    }
    return true;
  }

  bool _checkDevicesHaveUniqueChannel(
      List<LighthouseDevice> devicesToBeInAGroup) {
    final Set<String> knownChannels = Set<String>();
    for (final device in devicesToBeInAGroup) {
      String? channel = device.otherMetadata['Channel'];
      if (channel != null) {
        channel = '${device.runtimeType.toString()}+$channel';
        if (!knownChannels.contains(channel)) {
          knownChannels.add(channel);
        } else {
          return false;
        }
      }
    }
    return true;
  }

  /// Check if all the devices in the selected group are of the same type.
  /// If they aren't we should show a warning.
  bool _allSameDeviceType(List<LighthouseDevice> devicesToBeInAGroup) {
    final foundTypes = Set<String>();
    for (final device in devicesToBeInAGroup) {
      foundTypes.add(device.runtimeType.toString());
      if (foundTypes.length > 1) {
        return false;
      }
    }
    return foundTypes.length <= 1;
  }

  /// Get the group in common between all the selected groups. If not all the
  /// devices are in the same group or no devices are selected then it will
  /// return `null`.
  Group? _getGroupFromSelected(List<GroupWithEntries> groups) {
    Group? firstGroup;
    for (final selectedDevice in selected) {
      bool found = false;
      for (final group in groups) {
        if (group.deviceIds.contains(selectedDevice.toString())) {
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

  /// Get the currently selected group if a group is selected.
  /// A group is selected if all it's devices are selected, or if it doesn't
  /// have any devices it is the current [selectedGroup].
  Group? _getSelectedGroupFromSelected(List<GroupWithEntries> groups) {
    if (selected.isEmpty) {
      return selectedGroup;
    }
    selectedGroup = null;
    for (final group in groups) {
      if (LighthouseGroupWidget.isGroupSelected(
          group.deviceIds, selected.map((e) => e.toString()).toList())) {
        return group.group;
      }
    }

    return null;
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
            updateInterval: Duration(seconds: widget.settings.updateInterval),
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

  final BluetoothAdapterState? state;
  final MainPageSettings settings;

  Widget _toSettingsButton(BuildContext context, Theming theming) {
    if (LocalPlatform.isAndroid && state == BluetoothAdapterState.off) {
      return ElevatedButton(
          onPressed: () async {
            await EnableBluetoothDialogFlow.showEnableBluetoothDialogFlow(
                context);
          },
          child: Text(
            'Enable Bluetooth.',
            style: theming.bodyText?.copyWith(color: Colors.black),
          ));
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    final theming = Theming.of(context);
    final stateName = state != null
        ? BluetoothAdapterStateFunctions.stateToString(state!)
        : 'not available';

    var subText = const [
      TextSpan(
          text: 'Bluetooth needs to be enabled to talk to the lighthouses.')
    ];
    if (LocalPlatform.isWeb) {
      if (!FlutterWebBluetooth.instance.isBluetoothApiSupported) {
        final browser = Browser.detectOrNull();

        subText = [
          const TextSpan(
              text: "Your browser doesn't support the bluetooth web API."
                  " It may need to be enabled behind a flag, try going to "
                  "about:flags in your browser bar."),
          if (browser?.browserAgent == BrowserAgent.Chrome)
            const TextSpan(
                text: '\nFor Chrome (or chrome like browsers) you will need to '
                    'enable the "enable-experimental-web-platform-features" flag.')
          else if (browser?.browserAgent == BrowserAgent.Firefox ||
              browser?.browserAgent == BrowserAgent.Safari)
            TextSpan(
                text:
                    '\n${browser?.browser} does not support Bluetooth web yet.')
          else if (browser?.browserAgent == BrowserAgent.Explorer)
            const TextSpan(
                text: "\nWhat are you doing trying this in Internet Explorer!? "
                    "Of course it doesn't support it!")
          else if (browser?.browserAgent == BrowserAgent.Edge)
            const TextSpan(
                text: "\nTry switching to the new Chrome based Edge browser.")
        ];
      } else {
        subText = const [
          TextSpan(
              text: "Try enabling Bluetooth on your device or "
                  "stick in a USB Bluetooth adapter.")
        ];
      }
    }

    return Scaffold(
      backgroundColor: Colors.lightBlue,
      drawer: MainPageDrawer(Duration(seconds: settings.scanDuration),
          Duration(seconds: settings.updateInterval)),
      appBar: AppBar(
        title: const Text('Lighthouse PM'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.bluetooth_disabled,
              size: 200.0,
              color: Colors.white54,
            ),
            Text(
              'Bluetooth is $stateName.',
              style: theming.headline6?.copyWith(color: Colors.white),
            ),
            RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: theming.subtitle?.copyWith(color: Colors.white),
                  children: subText,
                )),
            _toSettingsButton(context, theming)
          ],
        ),
      ),
    );
  }
}
