import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:lighthouse_pm/bloc.dart';
import 'package:lighthouse_pm/data/Database.dart';
import 'package:lighthouse_pm/data/local/MainPageSettings.dart';
import 'package:lighthouse_pm/dialogs/EnableBluetoothDialogFlow.dart';
import 'package:lighthouse_pm/dialogs/LocationPermissonDialogFlow.dart';
import 'package:lighthouse_pm/lighthouseProvider/LighthouseDevice.dart';
import 'package:lighthouse_pm/lighthouseProvider/LighthouseProvider.dart';
import 'package:lighthouse_pm/lighthouseProvider/ble/DeviceIdentifier.dart';
import 'package:lighthouse_pm/lighthouseProvider/deviceProviders/ViveBaseStationDeviceProvider.dart';
import 'package:lighthouse_pm/lighthouseProvider/widgets/LighthouseWidget.dart';
import 'package:lighthouse_pm/pages/TroubleshootingPage.dart';
import 'package:lighthouse_pm/permissionsHelper/BLEPermissionsHelper.dart';
import 'package:lighthouse_pm/widgets/MainPageDrawer.dart';
import 'package:lighthouse_pm/widgets/NicknameAlertWidget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

const double _DEVICE_LIST_SCROLL_PADDING = 80.0;

Future _startScan(Duration scanDuration) async {
  await LighthouseProvider.instance.startScan(timeout: scanDuration);
}

Future _startScanWithCheck(Duration scanDuration,
    {String failMessage = ""}) async {
  if (await BLEPermissionsHelper.hasBLEPermissions() ==
      PermissionStatus.granted) {
    await _startScan(scanDuration);
  } else if (failMessage != null && failMessage.isNotEmpty && !kReleaseMode) {
    debugPrint(failMessage);
  }
}

Future _stopScan() async => await LighthouseProvider.instance.stopScan();

Future _cleanUp() async => await LighthouseProvider.instance.cleanUp();

Future<bool> _hasConnectedDevices() async =>
    ((await LighthouseProvider.instance.lighthouseDevices.first).length > 0);

Stream<Tuple2<List<Nickname>, List<LighthouseDevice>>>
    _mergeNicknameAndLighthouseDevice(LighthousePMBloc bloc) {
  final nicknames = List<Nickname>();
  final lighthouseDevices = List<LighthouseDevice>();

  return MergeStream<List<dynamic>>([
    bloc.watchSavedNicknames,
    LighthouseProvider.instance.lighthouseDevices
  ]).map((event) {
    if (event is List<Nickname>) {
      nicknames.clear();
      nicknames.addAll(event);
    } else if (event is List<LighthouseDevice>) {
      lighthouseDevices.clear();
      lighthouseDevices.addAll(event);
    }
    return Tuple2(nicknames, lighthouseDevices);
  });
}

class MainPage extends StatelessWidget {
  LighthousePMBloc _bloc(BuildContext context) =>
      Provider.of<LighthousePMBloc>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MainPageSettings>(
      stream: MainPageSettings.mainPageSettingsStream(_bloc(context)),
      initialData: MainPageSettings.DEFAULT_MAIN_PAGE_SETTINGS,
      builder:
          (BuildContext c, AsyncSnapshot<MainPageSettings> settingsSnapshot) {
        if (settingsSnapshot.hasData) {
          if (settingsSnapshot.data.viveBaseStationsEnabled) {
            LighthouseProvider.instance
                .addProvider(ViveBaseStationDeviceProvider.instance);
          } else {
            LighthouseProvider.instance
                .removeProvider(ViveBaseStationDeviceProvider.instance);
          }
        }

        return StreamBuilder<BluetoothState>(
            stream: FlutterBlue.instance.state,
            initialData: BluetoothState.unknown,
            builder:
                (BuildContext context, AsyncSnapshot<BluetoothState> snapshot) {
              final state = snapshot.data;
              return state == BluetoothState.on
                  ? ScanDevicesPage(
                      settings: settingsSnapshot.data,
                    )
                  : BluetoothOffScreen(
                      state: state,
                      settings: settingsSnapshot.data,
                    );
            });
      },
    );
  }
}

class _ScanFloatingButtonWidget extends StatelessWidget {
  _ScanFloatingButtonWidget({Key key, @required this.settings})
      : super(key: key);

  final MainPageSettings settings;

  @override
  Widget build(BuildContext context) {
    // The button for starting and stopping scanning.
    return StreamBuilder<bool>(
      stream: LighthouseProvider.instance.isScanning,
      initialData: false,
      builder: (c, snapshot) {
        if (snapshot.data) {
          return FloatingActionButton(
            child: Icon(Icons.stop),
            onPressed: () => _stopScan(),
            backgroundColor: Colors.red,
          );
        } else {
          return FloatingActionButton(
            child: Icon(Icons.search),
            onPressed: () async {
              if (await LocationPermissionDialogFlow
                  .showLocationPermissionDialogFlow(context)) {
                await _startScan(Duration(seconds: settings.scanDuration));
              }
            },
          );
        }
      },
    );
  }
}

class ScanDevicesPage extends StatefulWidget {
  ScanDevicesPage({Key key, @required this.settings}) : super(key: key);

  final MainPageSettings settings;

  @override
  State<StatefulWidget> createState() {
    return _ScanDevicesPage();
  }
}

class _ScanDevicesPage extends State<ScanDevicesPage>
    with WidgetsBindingObserver {
  LighthousePMBloc get bloc => Provider.of<LighthousePMBloc>(context);

  final selected = Set<LHDeviceIdentifier>();

  LighthousePMBloc get blocWithoutListen =>
      Provider.of<LighthousePMBloc>(context, listen: false);
  var updates = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startScanWithCheck(Duration(seconds: widget.settings.scanDuration),
        failMessage:
            "Could not start scan because the permission has not been granted");
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (selected.isNotEmpty) {
      setState(() {
        selected.clear();
      });
      return false;
    }
    // A little workaround for issue https://github.com/pauldemarco/flutter_blue/issues/649
    if (Platform.isAndroid) {
      if (await FlutterBlue.instance.isScanning.first ||
          await _hasConnectedDevices()) {
        await _cleanUp();
        await Future.delayed(Duration(milliseconds: 100));
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
        child: StreamBuilder<Tuple2<List<Nickname>, List<LighthouseDevice>>>(
            stream: _mergeNicknameAndLighthouseDevice(bloc),
            initialData: const Tuple2(const [], const []),
            builder: (c, snapshot) {
              updates++;
              final tuple = snapshot.data;
              final list = tuple.item2;
              if (list.isNotEmpty) {
                list.sort((a, b) =>
                    a.deviceIdentifier.id.compareTo(b.deviceIdentifier.id));
              }
              final nicknames = tuple.item1;
              // Make sure a device hasn't left
              final selectedCopy = Set<LHDeviceIdentifier>();
              selectedCopy.addAll(selected);
              selected.clear();

              final Widget body = (list.isEmpty && updates > 2)
                  ? StreamBuilder<bool>(
                      stream: FlutterBlue.instance.isScanning,
                      initialData: true,
                      builder: (context, scanningSnapshot) {
                        final scanning = scanningSnapshot.data;
                        if (scanning) {
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
                        if (index == list.length) {
                          // Add an extra container at the bottom to stop the floating
                          // button from obstructing the last item.
                          return Container(
                            height: _DEVICE_LIST_SCROLL_PADDING,
                          );
                        }
                        final device = list[index];
                        bloc.insertLastSeenDevice(LastSeenDevice(
                            macAddress: device.deviceIdentifier.toString(),
                            lastSeen: null));
                        final nickname = nicknames.singleWhere(
                            (element) =>
                                element.macAddress ==
                                device.deviceIdentifier.toString(),
                            orElse: () => null);
                        if (selectedCopy.contains(device.deviceIdentifier)) {
                          selected.add(device.deviceIdentifier);
                        }
                        return LighthouseWidget(
                          device,
                          selected: selected.contains(device.deviceIdentifier),
                          onLongPress: () {
                            setState(() {
                              if (selected.contains(device.deviceIdentifier)) {
                                selected.remove(device.deviceIdentifier);
                              } else {
                                selected.clear();
                                selected.add(device.deviceIdentifier);
                              }
                            });
                          },
                          nickname: nickname != null ? nickname.nickname : null,
                          sleepState: widget.settings.sleepState,
                        );
                      },
                      itemCount: list.length + 1,
                    );

              final List<Widget> actions = [];
              Color actionBarColor;
              if (selectedCopy.length == 1) {
                actionBarColor = Theme.of(context).selectedRowColor;
                actions.add(IconButton(
                  tooltip: 'Change nickname',
                  icon: Icon(Icons.edit_attributes),
                  onPressed: () async {
                    if (selected.length == 1) {
                      final item = selected.first;
                      final device = list.singleWhere(
                          (element) => element.deviceIdentifier == item,
                          orElse: () => null);
                      if (device == null) {
                        debugPrint(
                            'Could not find a device for the nickname dialog!');
                        return;
                      }
                      final Nickname /* ? */ nickname = nicknames.singleWhere(
                          (element) => element.macAddress == item.toString(),
                          orElse: () => null);

                      final newNickname =
                          await NicknameAlertWidget.showCustomDialog(context,
                              macAddress: device.deviceIdentifier.toString(),
                              deviceName: device.name,
                              nickname:
                                  nickname == null ? null : nickname.nickname);
                      if (newNickname != null) {
                        if (newNickname.nickname == null) {
                          blocWithoutListen
                              .deleteNicknames([newNickname.macAddress]);
                        } else {
                          blocWithoutListen.insertNickname(newNickname);
                        }
                        selected.remove(item);
                      }
                    }
                  },
                ));
              }
              final Widget leading = selectedCopy.isEmpty
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
                  backgroundColor:
                      actionBarColor ?? Theme.of(context).primaryColor,
                  leading: leading,
                ),
                floatingActionButton: _ScanFloatingButtonWidget(
                  settings: widget.settings,
                ),
                drawer: MainPageDrawer(_cleanUp, ({String failMessage}) {
                  return _startScanWithCheck(
                      Duration(seconds: widget.settings.scanDuration),
                      failMessage: failMessage);
                }),
                body: body,
              );
            }));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        setState(() {
          this.updates = 0;
          selected.clear();
        });
        _cleanUp();
        break;
      case AppLifecycleState.resumed:
        _startScanWithCheck(Duration(seconds: widget.settings.scanDuration),
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

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen(
      {Key key, @required this.state, @required this.settings})
      : super(key: key);

  final BluetoothState state;
  final MainPageSettings settings;

  Widget _toSettingsButton(BuildContext context) {
    if (Platform.isAndroid && state == BluetoothState.off) {
      return RaisedButton(
          onPressed: () async {
            await EnableBluetoothDialogFlow.showEnableBluetoothDialogFlow(
                context);
          },
          child: Text(
            'Enable Bluetooth.',
            style: Theme.of(context)
                .textTheme
                .bodyText1
                .copyWith(color: Colors.black),
          ));
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      drawer: MainPageDrawer(_cleanUp, ({String failMessage}) {
        return _startScanWithCheck(Duration(seconds: settings.scanDuration),
            failMessage: failMessage);
      }),
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
                  .headline6
                  .copyWith(color: Colors.white),
            ),
            Text(
              'Bluetooth needs to be enabled to talk to the lighthouses',
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  .copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            _toSettingsButton(context)
          ],
        ),
      ),
    );
  }
}
