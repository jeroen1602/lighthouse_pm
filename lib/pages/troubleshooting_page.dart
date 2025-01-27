import 'package:community_material_icon/community_material_icon.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:lighthouse_pm/bloc.dart';
import 'package:lighthouse_pm/dialogs/enable_bluetooth_dialog_flow.dart';
import 'package:lighthouse_pm/dialogs/location_permission_dialog_flow.dart';
import 'package:lighthouse_provider/lighthouse_provider.dart';
import 'package:lighthouse_pm/permissions_helper/ble_permissions_helper.dart';
import 'package:lighthouse_pm/theming.dart';
import 'package:lighthouse_pm/widgets/content_container_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_platform/shared_platform.dart';

import 'base_page.dart';

const double _troubleshootingScrollPadding = 20;

///
/// A widget showing the a material scaffold with the troubleshooting widget.
///
class TroubleshootingPage extends BasePage {
  const TroubleshootingPage({super.key});

  @override
  Widget buildPage(final BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Troubleshooting')),
        body: const ContentContainerListView(
          children: [
            TroubleshootingContentWidget(),
          ],
        ));
  }
}

///
/// A widget with a list of some troubleshooting steps the user might take.
/// It also has a few platform specific troubleshooting steps like location
/// permissions for Android.
///
class TroubleshootingContentWidget extends StatelessWidget
    with WithBlocStateless {
  const TroubleshootingContentWidget({super.key});

  static List<Widget> getContent(final BuildContext context) {
    return [
      Container(
        height: _troubleshootingScrollPadding,
      ),
      if (SharedPlatform.isAndroid) ...[
        _TroubleshootingItemWithAction(
          leadingIcon: Icons.location_off,
          leadingColor: Colors.green,
          title: const Text('Enable location services'),
          subtitle: const Text(
              'On Android 6.0 or higher it is required to enable location services. Or no devices will show up.'),
          actionIcon: Icons.settings,
          onTap: () async {
            await BLEPermissionsHelper.openLocationSettings();
          },
        ),
        const Divider(),
        FutureBuilder<PermissionStatus>(
          future: BLEPermissionsHelper.hasBLEPermissions(),
          builder: (final context, final snapshot) {
            final permissionState = snapshot.data;
            if (permissionState == PermissionStatus.granted) {
              return Container();
            }
            return FutureBuilder<AndroidDeviceInfo>(
                future: DeviceInfoPlugin().androidInfo,
                builder: (final context, final snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  } else {
                    final sdkInt = snapshot.requireData.version.sdkInt;
                    return Column(
                      children: [
                        if (sdkInt >= 31)
                          _TroubleshootingItemWithAction(
                            leadingIcon: Icons.lock,
                            leadingColor: Colors.red,
                            title: const Text('Allow Bluetooth permission'),
                            subtitle: const Text(
                                'Bluetooth permission is required to scan for devices'),
                            actionIcon: Icons.bluetooth,
                            onTap: () async {
                              await LocationPermissionDialogFlow
                                  .showLocationPermissionDialogFlow(context);
                            },
                          )
                        else
                          _TroubleshootingItemWithAction(
                            leadingIcon: Icons.lock,
                            leadingColor: Colors.red,
                            title: const Text('Allow Location permissions'),
                            subtitle: const Text(
                                'On Android you need to allow location permissions to scan for devices'),
                            actionIcon: Icons.location_on,
                            onTap: () async {
                              await LocationPermissionDialogFlow
                                  .showLocationPermissionDialogFlow(context);
                            },
                          ),
                        const Divider(),
                      ],
                    );
                  }
                });
          },
        ),
        // FlutterBlue doesn't like it when you have two of the same streams
        // open at once, so for now convert it into a future.
        //StreamBuilder<BluetoothState>(
        //  stream: FlutterBlue.instance.state,
        FutureBuilder<BluetoothAdapterState>(
          future: LighthouseProvider.instance.state.first,
          initialData: BluetoothAdapterState.unknown,
          builder: (final context, final snapshot) {
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
                        title: const Text('Enable Bluetooth'),
                        subtitle: const Text(
                            'Bluetooth needs to be enabled to scan for devices'),
                        actionIcon: Icons.settings_bluetooth,
                        onTap: () async {
                          await EnableBluetoothDialogFlow
                              .showEnableBluetoothDialogFlow(context);
                        }),
                    const Divider(),
                  ],
                );
            }
          },
        ),
      ],
      if (SharedPlatform.isIOS) ...[
        FutureBuilder<PermissionStatus>(
          future: BLEPermissionsHelper.hasBLEPermissions(),
          builder: (final context, final snapshot) {
            final permissionState = snapshot.data;
            if (permissionState == PermissionStatus.granted) {
              return Container();
            }
            return Column(
              children: [
                _TroubleshootingItemWithAction(
                  leadingIcon: Icons.lock,
                  leadingColor: Colors.red,
                  title: const Text('Allow Bluetooth permission'),
                  subtitle: const Text(
                      'Bluetooth permission is required to scan for devices'),
                  actionIcon: Icons.bluetooth,
                  onTap: () async {
                    await LocationPermissionDialogFlow
                        .showLocationPermissionDialogFlow(context);
                  },
                ),
                const Divider(),
              ],
            );
          },
        ),
        FutureBuilder<BluetoothAdapterState>(
          future: LighthouseProvider.instance.state.first,
          initialData: BluetoothAdapterState.unknown,
          builder: (final context, final snapshot) {
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
                        title: const Text('Enable Bluetooth'),
                        subtitle: const Text(
                            'Bluetooth needs to be enabled to scan for devices'),
                        actionIcon: Icons.settings_bluetooth,
                        onTap: () async {
                          await EnableBluetoothDialogFlow
                              .showEnableBluetoothDialogFlow(context);
                        }),
                    const Divider(),
                  ],
                );
            }
          },
        ),
      ],
      if (LighthouseProvider.instance.getPairBackEnds().isNotEmpty) ...const [
        ListTile(
            title: Text("Make sure you have paired with the lighthouse"),
            leading: Icon(
              Icons.bluetooth_connected,
              color: Colors.lightBlue,
            )),
        Divider()
      ],
      const ListTile(
        title: Text('Make sure the lighthouse is plugged in'),
        leading: Icon(Icons.power, color: Colors.blue),
      ),
      const Divider(),
      const ListTile(
          title: Text('You might be out of range'),
          subtitle: Text('Try moving closer to the lighthouses.'),
          leading: Icon(Icons.signal_cellular_null, color: Colors.orange)),
      const Divider(),
      const ListTile(
          title: Text(
              'Your lighthouse may be running an older unsupported software version'),
          subtitle:
              Text('Check to see if there is an update for your lighthouse.'),
          leading: Icon(Icons.update, color: Colors.cyan)),
      const Divider(),
      const ListTile(
          title:
              Text('Sometimes a lighthouse reports it\'s own state as booting'),
          subtitle: Text(
              'Sometimes a lighthouse may report it\'s own state as booting even though it\'s already on.\nJust click on the gray power-button and select "I\'m sure" in the popup at the bottom.'),
          leading: Icon(CommunityMaterialIcons.ray_start, color: Colors.pink)),
      const Divider(),
      if (SharedPlatform.isWeb)
        const ListTile(
            title: Text('Sometimes the page needs to be reloaded'),
            subtitle: Text('Try to reload the web page and connect again'),
            leading: Icon(Icons.replay, color: Colors.deepOrange))
      else
        const ListTile(
            title: Text('Sometimes the app needs a restart'),
            subtitle: Text(
                'The app is a work in progress and sometimes it needs a restart in order to working perfectly.'),
            leading: Icon(Icons.replay, color: Colors.deepOrange)),
      const Divider(),
      if (SharedPlatform.isWeb)
        const ListTile(
            title: Text(
                'Make sure no other tab is communicating with the lighthouse'),
            subtitle: Text(
                'The site cannot find the lighthouse if another program is already communicating with it.'),
            leading: Icon(Icons.apps, color: Colors.greenAccent))
      else
        const ListTile(
            title: Text(
                'Make sure no other app is communicating with the lighthouse'),
            subtitle: Text(
                'The app cannot find the lighthouse if another app is already communicating with it.'),
            leading: Icon(Icons.apps, color: Colors.greenAccent)),
      const Divider(),
      Container(
        height: _troubleshootingScrollPadding,
      ),
    ];
  }

  @override
  Widget build(final BuildContext context) {
    final List<Widget> children = getContent(context);

    return Column(children: children);
  }
}

///
/// A simple widget to show a troubleshooting item with an action next to it.
/// For example 'location service should be enabled' with the action go to settings.
///
class _TroubleshootingItemWithAction extends StatelessWidget {
  const _TroubleshootingItemWithAction(
      {required this.leadingIcon,
      required this.leadingColor,
      required this.actionIcon,
      required this.onTap,
      required this.title,
      this.subtitle});

  final IconData leadingIcon;
  final Color leadingColor;
  final IconData actionIcon;
  final VoidCallback onTap;
  final Widget title;
  final Widget? subtitle;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final theming = Theming.fromTheme(theme);

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
            fillColor: theming.buttonColor,
            padding: const EdgeInsets.all(8.0),
            shape: const CircleBorder(),
            child: Icon(
              actionIcon,
              color: theme.colorScheme.onPrimary,
              size: 24.0,
            )),
      ],
    );
  }
}
