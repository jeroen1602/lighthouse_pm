import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:lighthouse_pm/lighthouseProvider/LighthouseDevice.dart';
import 'package:lighthouse_pm/lighthouseProvider/LighthouseProvider.dart';
import 'package:lighthouse_pm/lighthouseProvider/widgets/LighthouseWidget.dart';
import 'package:lighthouse_pm/pages/AboutPage.dart';

import '../main.dart';

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FlutterBlue.instance.state,
      initialData: BluetoothState.unknown,
      builder: (BuildContext context, AsyncSnapshot<BluetoothState> snapshot) {
        final state = snapshot.data;
        if (state == BluetoothState.on) {
          return ScanDevicesPage();
        }
        return BluetoothOffScreen(state: state);
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
    LighthouseProvider.instance.startScan(timeout: Duration(seconds: 4));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lighthouse PM'),
      ),
      body: StreamBuilder<List<LighthouseDevice>>(
        stream: LighthouseProvider.instance.lighthouseDevices,
        initialData: [],
        builder: (c, snapshot) {
          final list = snapshot.data;
          return ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              return LighthouseWidget(list[index]);
            },
            itemCount: list.length,
          );
        },
      ),
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
        },
      ),
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
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AboutPage()));
            },
          )
        ],
      )),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        LighthouseProvider.instance.cleanUp();
        break;
      case AppLifecycleState.resumed:
        LighthouseProvider.instance.startScan(timeout: Duration(seconds: 4));
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        // Do nothing.
        break;
    }
  }
}
