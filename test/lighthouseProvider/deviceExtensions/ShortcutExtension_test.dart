import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/lighthouseProvider/deviceExtensions/ShortcutExtension.dart';
import 'package:lighthouse_pm/platformSpecific/io/LocalPlatform.dart';
import 'package:lighthouse_pm/platformSpecific/io/android/androidLauncherShortcut/io.dart';

void main() {
  test('Should be able to create shortcut extension', () async {
    final extension = ShortcutExtension("00:00:00:00:00:00", () {
      return "DEVICE_NAME";
    });

    expect(extension.icon, TypeMatcher<Icon>());
    expect(extension.toolTip, 'Create shortcut');
    expect(extension.updateListAfter, false);
  });

  test('Should be able to create shortcut', () async {
    WidgetsFlutterBinding.ensureInitialized();
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
