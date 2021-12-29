import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/lighthouse_provider/device_extensions/shortcut_extension.dart';
import 'package:lighthouse_pm/platform_specific/mobile/local_platform.dart';
import 'package:lighthouse_pm/platform_specific/mobile/android/android_launcher_shortcut/android_launcher_shortcut_io.dart';

void main() {
  test('Should be able to create shortcut extension', () async {
    final extension = ShortcutExtension("00:00:00:00:00:00", () {
      return "DEVICE_NAME";
    });

    expect(extension.icon, isA<Icon>());
    expect(extension.toolTip, 'Create shortcut');
    expect(extension.updateListAfter, false);
  });

  test('Should be able to create shortcut', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final extension = ShortcutExtension("00:00:00:00:00:00", () {
      return "DEVICE_NAME";
    });

    String? receivedMac;

    AndroidLauncherShortcut.channel.setMockMethodCallHandler((call) async {
      if (call.method == "requestShortcut") {
        receivedMac = (call.arguments as Map)['action'];
        return true;
      }
    });

    await extension.onTap();

    expect(receivedMac, 'mac/00:00:00:00:00:00');

    LocalPlatform.overridePlatform = null;
    AndroidLauncherShortcut.channel.setMockMethodCallHandler(null);
  });
}
