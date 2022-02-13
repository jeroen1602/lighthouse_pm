import 'dart:async';

import 'device_extension.dart';

typedef GetDeviceNickname = String Function();
typedef CreateShortcutCallback = FutureOr<void> Function(
    String macAddress, String name);

///
/// Extension for adding a button so the the user can add a shortcut
///
class ShortcutExtension extends DeviceExtension {
  ShortcutExtension(
      final String macAddress,
      final GetDeviceNickname getDeviceNickname,
      final CreateShortcutCallback createShortcut)
      : super(
            toolTip: 'Create shortcut',
            updateListAfter: false,
            onTap: () async {
              await createShortcut(macAddress, getDeviceNickname());
            });
}
