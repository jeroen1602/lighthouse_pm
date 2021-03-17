import 'package:flutter/material.dart';
import 'package:lighthouse_pm/pages/shortcut/states/GetDeviceStateStream.dart';
import 'package:lighthouse_pm/pages/shortcut/states/GetDeviceStream.dart';
import 'package:lighthouse_pm/pages/shortcut/states/PermissionStream.dart';
import 'package:lighthouse_pm/pages/shortcut/states/SettingsStream.dart';
import 'package:lighthouse_pm/widgets/ScanningMixin.dart';
import 'package:lighthouse_pm/widgets/WaterfallWidget.dart';

import '../ShortcutHandlerPage.dart';

/*
These are the steps that the page will go through.
Settings -> Stream
Permissions -> Future
GetDevice (with timeout) -> Stream
GetDeviceState (with timeout) -> Stream
ChangeState -> Future
CloseApp -> Future
 */

class ShortcutHandleMacState extends State<ShortcutHandlerWidget>
    with WidgetsBindingObserver, ScanningMixin {
  @override
  Widget build(BuildContext context) {
    return WaterfallWidgetContainer(stream: [
      SettingsStream.createBuilder(),
      PermissionsStream.createBuilder(),
      GetDeviceStream.createBuilder(widget.shortcutHandle.data, 0),
      GetDeviceStateStream.createBuilder(0),
    ]);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        cleanUp();
        break;
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        // Do nothing.
        break;
    }
  }
}
