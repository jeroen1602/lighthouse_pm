import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lighthouse_pm/bloc.dart';
import 'package:lighthouse_pm/dialogs/EnableBluetoothDialogFlow.dart';
import 'package:lighthouse_pm/dialogs/LocationPermissonDialogFlow.dart';
import 'package:lighthouse_pm/lighthouseProvider/LighthouseProvider.dart';
import 'package:lighthouse_pm/lighthouseProvider/adapterState/AdapterState.dart';
import 'package:lighthouse_pm/permissionsHelper/BLEPermissionsHelper.dart';
import 'package:lighthouse_pm/platformSpecific/shared/LocalPlatform.dart';
import 'package:permission_handler/permission_handler.dart';

import 'BasePage.dart';

const double _TROUBLESHOOTING_SCROLL_PADDING = 20;

///
/// A widget showing the a material scaffold with the troubleshooting widget.
///
class TroubleshootingPage extends BasePage {
  @override
  Widget buildPage(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Troubleshooting')),
        body: TroubleshootingContentWidget());
  }
}

///
/// A widget with a list of some troubleshooting steps the user might take.
/// It also has a few platform specific troubleshooting steps like location
/// permissions for Android.
///
class TroubleshootingContentWidget extends StatelessWidget
    with WithBlocStateless {
  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [
      ListTile(
        title: Text('Make sure the lighthouse is plugged in'),
        leading: Icon(Icons.power, color: Colors.blue),
      ),
      Divider(),
      StreamBuilder<bool>(
        initialData: false,
        stream: blocWithoutListen(context)
            .settings
            .getViveBaseStationsEnabledStream(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          final baseStationEnabled = snapshot.data == true;
          return ListTile(
              title: Text(baseStationEnabled
                  ? 'Vive Base station support is still in beta'
                  : 'Make sure that your lighthouses are V2 lighthouses and not V1/Vive'),
              subtitle: Text(baseStationEnabled
                  ? 'The Vive Base station support is still in beta so it might not work correctly.'
                  : 'The Vive Base station support is still in beta and needs to be enabled.'),
              leading: SvgPicture.asset("assets/images/app-icon.svg"));
        },
      ),
      Divider(),
      ListTile(
          title: Text('You might be out of range'),
          subtitle: Text('Try moving closer to the lighthouses.'),
          leading: Icon(Icons.signal_cellular_null, color: Colors.orange)),
      Divider(),
      ListTile(
          title: Text(
              'Your lighthouse may be running an older unsupported software version.'),
          subtitle:
              Text('Check to see if there is an update for your lighthouse.'),
          leading: Icon(Icons.update, color: Colors.cyan)),
      Divider(),
      ListTile(
          title: Text(
              'Sometimes a lighthouse reports it\'s own state as booting.'),
          subtitle: Text(
              'Sometimes a lighthouse may report it\'s own state as booting even though it\'s already on.\nJust click on the gray power-button and select "I\'m sure" in the popup at the bottom.'),
          leading: Icon(MaterialCommunityIcons.ray_start, color: Colors.pink)),
      Divider(),
      ListTile(
          title: Text('Sometimes the app needs a restart.'),
          subtitle: Text(
              'The app is a work in progress and sometimes it needs a restart in order to working perfectly.'),
          leading: Icon(Icons.replay, color: Colors.deepOrange)),
      Divider(),
      ListTile(
          title: Text(
              'Make sure no other app is communicating with the lighthouse.'),
          subtitle: Text(
              'The app cannot find the lighthouse if another app is already communicating with it.'),
          leading: Icon(Icons.apps, color: Colors.greenAccent)),
      Divider(),
    ];

    if (LocalPlatform.isAndroid) {
      children.insert(
          0,
          // FlutterBlue doesn't like it when you have two of the same streams
          // open at once, so for now convert it into a future.
          //StreamBuilder<BluetoothState>(
          //  stream: FlutterBlue.instance.state,
          FutureBuilder<BluetoothAdapterState>(
            future: LighthouseProvider.instance.state.first,
            initialData: BluetoothAdapterState.unknown,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }
              final data = snapshot.data;
              switch (data) {
                case BluetoothAdapterState.on:
                case BluetoothAdapterState.turningOn:
                case BluetoothAdapterState.unknown:
                  return Container();
                default:
                  return Column(
                    children: [
                      _TroubleshootingItemWithAction(
                          leadingIcon: Icons.bluetooth_disabled,
                          leadingColor: Colors.blue,
                          title: Text('Enable Bluetooth'),
                          subtitle: Text(
                              'Bluetooth needs to be enabled to scan for devices'),
                          actionIcon: Icons.settings_bluetooth,
                          onTap: () async {
                            await EnableBluetoothDialogFlow
                                .showEnableBluetoothDialogFlow(context);
                          }),
                      Divider(),
                    ],
                  );
              }
            },
          ));
      children.insert(
          0,
          FutureBuilder<PermissionStatus>(
            future: BLEPermissionsHelper.hasBLEPermissions(),
            builder: (context, snapshot) {
              final permissionState = snapshot.data;
              if (permissionState == PermissionStatus.granted) {
                return Container();
              }
              return Column(
                children: [
                  _TroubleshootingItemWithAction(
                    leadingIcon: Icons.lock,
                    leadingColor: Colors.red,
                    title: Text('Allow Location permissions'),
                    subtitle: Text(
                        'On Android you need to allow location permissions to scan for devices'),
                    actionIcon: Icons.location_on,
                    onTap: () async {
                      await LocationPermissionDialogFlow
                          .showLocationPermissionDialogFlow(context);
                    },
                  ),
                  Divider(),
                ],
              );
            },
          ));
      children.insert(0, Divider());
      children.insert(
          0,
          _TroubleshootingItemWithAction(
            leadingIcon: Icons.location_off,
            leadingColor: Colors.green,
            title: Text('Enable location services'),
            subtitle: Text(
                'On Android 6.0 or higher it is required to enable location services. Or no devices will show up.'),
            actionIcon: Icons.settings,
            onTap: () async {
              await BLEPermissionsHelper.openLocationSettings();
            },
          ));
    }
    // Add a container at the bottom and at the top to add a bit of padding to
    // make it all look a bit nicer.
    children.insert(
        0,
        Container(
          height: _TROUBLESHOOTING_SCROLL_PADDING,
        ));
    children.add(Container(
      height: _TROUBLESHOOTING_SCROLL_PADDING,
    ));

    return ListView(children: children);
  }
}

///
/// A simple widget to show a troubleshooting item with an action next to it.
/// For example 'location service should be enabled' with the action go to settings.
///
class _TroubleshootingItemWithAction extends StatelessWidget {
  _TroubleshootingItemWithAction(
      {Key? key,
      required this.leadingIcon,
      required this.leadingColor,
      required this.actionIcon,
      required this.onTap,
      required this.title,
      this.subtitle})
      : super(key: key);

  final IconData leadingIcon;
  final Color leadingColor;
  final IconData actionIcon;
  final VoidCallback onTap;
  final Widget title;
  final Widget? subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ListTile(
            leading: Icon(leadingIcon, color: leadingColor),
            title: title,
            subtitle: subtitle,
          ),
        ),
        RawMaterialButton(
            onPressed: onTap,
            elevation: 2.0,
            fillColor: Theme.of(context).buttonColor,
            padding: const EdgeInsets.all(8.0),
            shape: CircleBorder(),
            child: Icon(
              actionIcon,
              color: Colors.black,
              size: 24.0,
            )),
      ],
    );
  }
}
