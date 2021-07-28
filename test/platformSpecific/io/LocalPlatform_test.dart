import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/platformSpecific/io/LocalPlatform.dart';

void main() {
  test('Should get correct platform', () {
    final platform = LocalPlatform.current;

    expect(platform, isNot("UNKNOWN"));

    expect(LocalPlatform.isAndroid, platform == "Android");
    expect(LocalPlatform.isIOS, platform == "IOS");
    expect(LocalPlatform.isLinux, platform == "Linux");
    expect(LocalPlatform.isWindows, platform == "Windows");
    expect(LocalPlatform.isWeb, platform == "web");
  });

  test('Should overwrite platform to Android', () {
    LocalPlatform.overridePlatform = PlatformOverride.android;

    expect(LocalPlatform.current, "Android");

    expect(LocalPlatform.isAndroid, isTrue);
    expect(LocalPlatform.isIOS, isFalse);
    expect(LocalPlatform.isLinux, isFalse);
    expect(LocalPlatform.isWindows, isFalse);
    expect(LocalPlatform.isWeb, isFalse);
  });

  test('Should overwrite platform to IOS', () {
    LocalPlatform.overridePlatform = PlatformOverride.ios;

    expect(LocalPlatform.current, "IOS");

    expect(LocalPlatform.isAndroid, isFalse);
    expect(LocalPlatform.isIOS, isTrue);
    expect(LocalPlatform.isLinux, isFalse);
    expect(LocalPlatform.isWindows, isFalse);
    expect(LocalPlatform.isWeb, isFalse);
  });

  test('Should overwrite platform to Linux', () {
    LocalPlatform.overridePlatform = PlatformOverride.linux;

    expect(LocalPlatform.current, "Linux");

    expect(LocalPlatform.isAndroid, isFalse);
    expect(LocalPlatform.isIOS, isFalse);
    expect(LocalPlatform.isLinux, isTrue);
    expect(LocalPlatform.isWindows, isFalse);
    expect(LocalPlatform.isWeb, isFalse);
  });

  test('Should overwrite platform to Windows', () {
    LocalPlatform.overridePlatform = PlatformOverride.windows;

    expect(LocalPlatform.current, "Windows");

    expect(LocalPlatform.isAndroid, isFalse);
    expect(LocalPlatform.isIOS, isFalse);
    expect(LocalPlatform.isLinux, isFalse);
    expect(LocalPlatform.isWindows, isTrue);
    expect(LocalPlatform.isWeb, isFalse);
  });

  test('Should overwrite platform to web', () {
    LocalPlatform.overridePlatform = PlatformOverride.web;

    expect(LocalPlatform.current, "web");

    expect(LocalPlatform.isAndroid, isFalse);
    expect(LocalPlatform.isIOS, isFalse);
    expect(LocalPlatform.isLinux, isFalse);
    expect(LocalPlatform.isWindows, isFalse);
    expect(LocalPlatform.isWeb, isTrue);
  });

  test('Should overwrite platform to unsupported', () {
    LocalPlatform.overridePlatform = PlatformOverride.unsupported;

    expect(LocalPlatform.current, "UNKNOWN");

    expect(LocalPlatform.isAndroid, isFalse);
    expect(LocalPlatform.isIOS, isFalse);
    expect(LocalPlatform.isLinux, isFalse);
    expect(LocalPlatform.isWindows, isFalse);
    expect(LocalPlatform.isWeb, isFalse);
  });
}
