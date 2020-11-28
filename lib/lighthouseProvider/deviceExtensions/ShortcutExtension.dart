
import 'package:flutter/material.dart';
import 'package:lighthouse_pm/platformSpecific/android/Shortcut.dart';

import './DeviceExtension.dart';

typedef GetDeviceNickname = String Function();

///
/// Extension for adding a button so the the user can add a shortcut
///
class ShortcutExtension extends DeviceExtension {
  ShortcutExtension(String macAddress, GetDeviceNickname getDeviceNickname) :super(
    toolTip: 'Create shortcut',
    icon: Icon(Icons.add),
    updateListAfter: false,
    onTap: () async {
      await Shortcut.instance.requestShortcutLighthouse(macAddress, getDeviceNickname());
    }
  );

}
