import 'package:lighthouse_pm/platform_specific/mobile/android/android_launcher_shortcut/android_launcher_shortcut.dart';

import 'device_extension.dart';

typedef GetDeviceNickname = String Function();

///
/// Extension for adding a button so the the user can add a shortcut
///
class ShortcutExtension extends DeviceExtension {
  ShortcutExtension(String macAddress, GetDeviceNickname getDeviceNickname)
      : super(
            toolTip: 'Create shortcut',
            updateListAfter: false,
            onTap: () async {
              await AndroidLauncherShortcut.instance
                  .requestShortcutLighthouse(macAddress, getDeviceNickname());
            });
}
