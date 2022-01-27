import 'package:lighthouse_provider/device_extensions/shortcut_extension.dart';
import 'package:shared_platform/shared_platform_io.dart';
import 'package:test/test.dart';

void main() {
  tearDown(() {
    SharedPlatform.overridePlatform = null;
  });

  test('Should be able to create shortcut extension', () async {
    final extension = ShortcutExtension("00:00:00:00:00:00", () {
      return "DEVICE_NAME";
    }, (mac, name) {});

    expect(extension.toolTip, 'Create shortcut');
    expect(extension.updateListAfter, false);
  });

  test('Should be able to create shortcut', () async {
    SharedPlatform.overridePlatform = PlatformOverride.android;

    String? receivedMac;
    String? receivedName;

    final extension = ShortcutExtension("00:00:00:00:00:00", () {
      return "DEVICE_NAME";
    }, (mac, name) {
      receivedMac = mac;
      receivedName = name;
    });

    await extension.onTap();

    expect(receivedMac, '00:00:00:00:00:00');
    expect(receivedName, "DEVICE_NAME");
  });
}
