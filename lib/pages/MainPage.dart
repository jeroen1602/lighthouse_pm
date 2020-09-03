import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:lighthouse_pm/dialogs/EnableBluetoothDialogFlow.dart';
import 'package:lighthouse_pm/dialogs/LocationPermissonDialogFlow.dart';
import 'package:lighthouse_pm/lighthouseProvider/LighthouseDevice.dart';
import 'package:lighthouse_pm/lighthouseProvider/LighthouseProvider.dart';
import 'package:lighthouse_pm/lighthouseProvider/widgets/LighthouseWidget.dart';
import 'package:lighthouse_pm/pages/TroubleshootingPage.dart';
import 'package:lighthouse_pm/permissionsHelper/BLEPermissionsHelper.dart';
import 'package:permission_handler/permission_handler.dart';

const double _DEVICE_LIST_SCROLL_PADDING = 80.0;
const Duration _SCAN_DURATION = Duration(seconds: 4);

Future _startScan() async {
  await LighthouseProvider.instance.startScan(timeout: _SCAN_DURATION);
}

Future _startScanWithCheck({String failMessage = ""}) async {
  if (await BLEPermissionsHelper.hasBLEPermissions() ==
      PermissionStatus.granted) {
    await _startScan();
  } else if (failMessage != null && failMessage.isNotEmpty && !kReleaseMode) {
    debugPrint(failMessage);
  }
}

Future _stopScan() async => await LighthouseProvider.instance.stopScan();

Future _cleanUp() async => await LighthouseProvider.instance.cleanUp();

Future<bool> _hasConnectedDevices() async =>
    ((await LighthouseProvider.instance.lighthouseDevices.first).length > 0);

class MainPage extends StatelessWidget {
  Future<bool> _onWillPop() async {
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
      child: StreamBuilder<BluetoothState>(
        stream: FlutterBlue.instance.state,
        initialData: BluetoothState.unknown,
        builder:
            (BuildContext context, AsyncSnapshot<BluetoothState> snapshot) {
          final state = snapshot.data;
          final Widget floatingButton =
          state == BluetoothState.on ? _ScanFloatingButtonWidget() : null;
          final Widget body = state == BluetoothState.on
              ? ScanDevicesPage()
              : BluetoothOffScreen(state: state);

          return Scaffold(
            appBar: AppBar(
              title: Text('Lighthouse PM'),
            ),
            floatingActionButton: floatingButton,
            drawer: Drawer(
                child: ListView(
                  children: <Widget>[
                    DrawerHeader(
                        decoration: BoxDecoration(color: Colors.grey),
                        child: Text('Lighthouse PM',
                            style: TextStyle(
                                color: Colors.black, fontSize: 24))),
                    ListTile(
                      leading: Icon(Icons.info),
                      title: Text('About'),
                      onTap: () async {
                        Navigator.pop(context);
                        _cleanUp();
                        await Navigator.pushNamed(context, '/about');
                        _startScanWithCheck(
                            failMessage:
                            "Could not start scan because permission has not been granted. On navigator pop");
                      },
                    ),
                    ListTile(
                        leading: Icon(Icons.report),
                        title: Text('Troubleshooting'),
                        onTap: () async {
                          Navigator.pop(context);
                          _cleanUp();
                          await Navigator.pushNamed(
                              context, '/troubleshooting');
                          _startScanWithCheck(
                              failMessage:
                              "Could not start scan because permission has not been granted. On navigator pop");
                        }),
                  ],
                )),
            body: body,
          );
        },
      ),
    );
  }
}

class _ScanFloatingButtonWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // The button for starting and stopping scanning.
    return StreamBuilder<bool>(
      stream: FlutterBlue.instance.isScanning,
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
                await _startScan();
              }
            },
          );
        }
      },
    );
  }
}

class ScanDevicesPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ScanDevicesPage();
  }
}

class _ScanDevicesPage extends State<ScanDevicesPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startScanWithCheck(
        failMessage:
        "Could not start scan because the permission has not been granted");
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  var updates = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<LighthouseDevice>>(
      stream: LighthouseProvider.instance.lighthouseDevices,
      initialData: [],
      builder: (c, snapshot) {
        updates++;
        final list = snapshot.data;
        if (list.isEmpty && updates > 2) {
          return StreamBuilder<bool>(
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
                        style: Theme
                            .of(context)
                            .primaryTextTheme
                            .headline4
                            .copyWith(color: Colors.black),
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
          );
        }

        return ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            if (index == list.length) {
              // Add an extra container at the bottom to stop the floating
              // button from obstructing the last item.
              return Container(
                height: _DEVICE_LIST_SCROLL_PADDING,
              );
            }
            return LighthouseWidget(list[index]);
          },
          itemCount: list.length + 1,
        );
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        _cleanUp();
        break;
      case AppLifecycleState.resumed:
        _startScanWithCheck(
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
  const BluetoothOffScreen({Key key, this.state}) : super(key: key);

  final BluetoothState state;

  Widget _toSettingsButton(BuildContext context) {
    if (Platform.isAndroid && state == BluetoothState.off) {
      return RaisedButton(
          onPressed: () async {
            await EnableBluetoothDialogFlow.showEnableBluetoothDialogFlow(
                context);
          },
          child: Text(
            'Enable Bluetooth.',
            style: Theme
                .of(context)
                .primaryTextTheme
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
              'Bluetooth is ${state != null
                  ? state.toString().substring(15)
                  : 'not available'}.',
              style: Theme
                  .of(context)
                  .primaryTextTheme
                  .headline6
                  .copyWith(color: Colors.white),
            ),
            Text('Bluetooth needs to be enabled to talk to the lighthouses',
                style: Theme
                    .of(context)
                    .primaryTextTheme
                    .subtitle1
                    .copyWith(color: Colors.white)),
            _toSettingsButton(context)
          ],
        ),
      ),
    );
  }
}
