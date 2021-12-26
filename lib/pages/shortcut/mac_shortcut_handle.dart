import 'package:flutter/material.dart';
import 'package:lighthouse_pm/pages/shortcut/states/get_device_state_stream.dart';
import 'package:lighthouse_pm/pages/shortcut/states/get_device_stream.dart';
import 'package:lighthouse_pm/pages/shortcut/states/permission_stream.dart';
import 'package:lighthouse_pm/pages/shortcut/states/settings_stream.dart';
import 'package:lighthouse_pm/widgets/scanning_mixin.dart';
import 'package:lighthouse_pm/widgets/waterfall_widget.dart';

import '../shortcut_handler_page.dart';

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
