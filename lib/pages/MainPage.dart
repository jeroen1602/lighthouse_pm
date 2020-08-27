import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:lighthouse_pm/lighthouseProvider/LighthouseDevice.dart';
import 'package:lighthouse_pm/lighthouseProvider/LighthouseProvider.dart';
import 'package:lighthouse_pm/lighthouseProvider/widgets/LighthouseWidget.dart';
import 'package:lighthouse_pm/permissionsHelper/BLEPermissionsHelper.dart';
import 'package:lighthouse_pm/widgets/EnableBluetoothAlertWidget.dart';
import 'package:lighthouse_pm/widgets/PermanentPermissionDeniedAlertWidget.dart';
import 'package:lighthouse_pm/widgets/PermissionsAlertWidget.dart';
import 'package:permission_handler/permission_handler.dart';

class MainPage extends StatelessWidget {
  Future<bool> _onWillPop() async {
    // A little workaround for issue https://github.com/pauldemarco/flutter_blue/issues/649
    if (Platform.isAndroid) {
      if (await FlutterBlue.instance.isScanning.first) {
        await LighthouseProvider.instance.stopScan();
        await LighthouseProvider.instance.cleanUp();
        await Future.delayed(Duration(milliseconds: 100));
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: StreamBuilder(
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
                        style: TextStyle(color: Colors.black, fontSize: 24))),
                ListTile(
                  leading: Icon(Icons.info),
                  title: Text('About'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/about');
                  },
                )
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
            onPressed: () => LighthouseProvider.instance.stopScan(),
            backgroundColor: Colors.red,
          );
        } else {
          return FloatingActionButton(
            child: Icon(Icons.search),
            onPressed: () async {
              switch (await BLEPermissionsHelper.hasBLEPermissions()) {
                case PermissionStatus.denied:
                case PermissionStatus.undetermined:
                case PermissionStatus.restricted:
                  // expression can be `null`
                  if (await PermissionsAlertWidget.showCustomDialog(context) !=
                      true) {
                    return;
                  }
                  switch (await BLEPermissionsHelper.requestBLEPermissions()) {
                    case PermissionStatus.permanentlyDenied:
                      continue permanentlyDenied;
                    case PermissionStatus.granted:
                      continue granted;
                    default:
                      return;
                  }
                  break;
                granted:
                case PermissionStatus.granted:
                  LighthouseProvider.instance
                      .startScan(timeout: Duration(seconds: 4));
                  break;
                permanentlyDenied:
                case PermissionStatus.permanentlyDenied:
                  // expression can be `null`
                  if (await PermanentPermissionDeniedAlertWidget
                          .showCustomDialog(context) ==
                      true) {
                    openAppSettings();
                  }
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
    BLEPermissionsHelper.hasBLEPermissions().then((state) {
      if (state == PermissionStatus.granted) {
        LighthouseProvider.instance.startScan(timeout: Duration(seconds: 4));
      } else {
        debugPrint(
            "Could not start scan because the permission has not been granted");
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<LighthouseDevice>>(
      stream: LighthouseProvider.instance.lighthouseDevices,
      initialData: [],
      builder: (c, snapshot) {
        final list = snapshot.data;
        return ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            if (index == list.length) {
              // Add an extra container at the bottom to stop the floating
              // button from obstructing the last item.
              return Container(
                height: 80,
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
        LighthouseProvider.instance.stopScan();
        LighthouseProvider.instance.cleanUp();
        break;
      case AppLifecycleState.resumed:
        BLEPermissionsHelper.hasBLEPermissions().then((status) {
          if (status == PermissionStatus.granted) {
            LighthouseProvider.instance
                .startScan(timeout: Duration(seconds: 4));
          } else {
            debugPrint(
                "Could not start scan because the permission has not been granted on resume");
          }
        });

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
            // Expression can be `null`
            if (await EnableBluetoothAlertWidget.showCustomDialog(context) ==
                true) {
              if (!await BLEPermissionsHelper.enableBLE()) {
                print("Could not enable Bluetooth.");
              }
            }
          },
          child: Text(
            'Enable Bluetooth.',
            style: Theme.of(context)
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
              'Bluetooth is ${state != null ? state.toString().substring(15) : 'not available'}.',
              style: Theme.of(context)
                  .primaryTextTheme
                  .headline6
                  .copyWith(color: Colors.white),
            ),
            Text('Bluetooth needs to be enabled to talk to the lighthouses',
                style: Theme.of(context)
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
