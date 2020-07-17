import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'LighthouseWidget.dart';
import 'lighthouseProvider/LighthouseDevice.dart';
import 'lighthouseProvider/LighthouseProvider.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Lighthouse PM',
        theme: ThemeData(
            primarySwatch: Colors.grey,
            visualDensity: VisualDensity.adaptivePlatformDensity),
        home: StreamBuilder<BluetoothState>(
            stream: FlutterBlue.instance.state,
            initialData: BluetoothState.unknown,
            builder: (c, snapshot) {
              final state = snapshot.data;
              if (state == BluetoothState.on) {
                return ScanDevicesScreen();
              }
              return BluetoothOffScreen(state: state);
            }));
  }
}

class ScanDevicesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lighthouse PM'),
      ),
      backgroundColor: Colors.white,
      body: RefreshIndicator(
          onRefresh: () => LighthouseProvider.instance
              .startScan(timeout: Duration(seconds: 4)),
          // The list of visible devices.
          child: SingleChildScrollView(
              child: Column(children: <Widget>[
            StreamBuilder<List<LighthouseDevice>>(
                stream: LighthouseProvider.instance.lighthouseDevices,
                initialData: [],
                builder: (c, snapshot) {
                  if (!snapshot.hasData) {
                    //TODO: add better error handling.
                    return Text('E');
                  }
                  return Column(
                      children: snapshot.data
                          .map((d) => LighthouseWidget(d))
                          .toList());
                })
          ]))),
      // The button for starting and stopping scanning.
      floatingActionButton: StreamBuilder<bool>(
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
                onPressed: () => LighthouseProvider.instance
                    .startScan(timeout: Duration(seconds: 4)),
              );
            }
          }),
    );
  }
}

// TODO: change this design so it isn't the same as the example app of [FlutterBlue].
class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({Key key, this.state}) : super(key: key);

  final BluetoothState state;

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
              'Bluetooth Adapter is ${state != null ? state.toString().substring(15) : 'not available'}.',
              style: Theme.of(context)
                  .primaryTextTheme
                  .headline6
                  .copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
