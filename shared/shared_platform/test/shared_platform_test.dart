import 'package:shared_platform/shared_platform_io.dart';
import 'package:test/test.dart';

void main() {
  tearDown(() {
    SharedPlatform.overridePlatform = null;
  });

  test('Should get correct platform', () {
    final platform = SharedPlatform.current;

    expect(platform, isNot("UNKNOWN"));

    expect(SharedPlatform.isAndroid, platform == "Android");
    expect(SharedPlatform.isIOS, platform == "IOS");
    expect(SharedPlatform.isLinux, platform == "Linux");
    expect(SharedPlatform.isWeb, platform == "web");
  });

  test('Should overwrite platform to Android', () {
    SharedPlatform.overridePlatform = PlatformOverride.android;

    expect(SharedPlatform.current, "Android");

    expect(SharedPlatform.isAndroid, isTrue);
    expect(SharedPlatform.isIOS, isFalse);
    expect(SharedPlatform.isLinux, isFalse);
    expect(SharedPlatform.isWeb, isFalse);
  });

  test('Should overwrite platform to IOS', () {
    SharedPlatform.overridePlatform = PlatformOverride.ios;

    expect(SharedPlatform.current, "IOS");

    expect(SharedPlatform.isAndroid, isFalse);
    expect(SharedPlatform.isIOS, isTrue);
    expect(SharedPlatform.isLinux, isFalse);
    expect(SharedPlatform.isWeb, isFalse);
  });

  test('Should overwrite platform to Linux', () {
    SharedPlatform.overridePlatform = PlatformOverride.linux;

    expect(SharedPlatform.current, "Linux");

    expect(SharedPlatform.isAndroid, isFalse);
    expect(SharedPlatform.isIOS, isFalse);
    expect(SharedPlatform.isLinux, isTrue);
    expect(SharedPlatform.isWeb, isFalse);
  });

  test('Should overwrite platform to web', () {
    SharedPlatform.overridePlatform = PlatformOverride.web;

    expect(SharedPlatform.current, "web");

    expect(SharedPlatform.isAndroid, isFalse);
    expect(SharedPlatform.isIOS, isFalse);
    expect(SharedPlatform.isLinux, isFalse);
    expect(SharedPlatform.isWeb, isTrue);
  });

  test('Should overwrite platform to unsupported', () {
    SharedPlatform.overridePlatform = PlatformOverride.unsupported;

    expect(SharedPlatform.current, "UNKNOWN");

    expect(SharedPlatform.isAndroid, isFalse);
    expect(SharedPlatform.isIOS, isFalse);
    expect(SharedPlatform.isLinux, isFalse);
    expect(SharedPlatform.isWeb, isFalse);
  });
}
