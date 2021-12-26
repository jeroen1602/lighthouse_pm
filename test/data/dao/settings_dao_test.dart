import 'package:device_info_platform_interface/device_info_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/data/dao/settings_dao.dart';
import 'package:lighthouse_pm/platform_specific/mobile/local_platform.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class FakeAndroidDeviceVersion extends Fake implements AndroidBuildVersion {
  FakeAndroidDeviceVersion();

  @override
  int sdkInt = -1;
}

class FakeAndroidDeviceInfo extends Fake implements AndroidDeviceInfo {
  FakeAndroidDeviceInfo(this.fakeVersion);

  FakeAndroidDeviceVersion fakeVersion;

  @override
  AndroidBuildVersion get version => fakeVersion;
}

class FakeIosDeviceVersion extends Fake implements AndroidBuildVersion {}

class FakeIOSDeviceInfo extends Fake implements IosDeviceInfo {
  @override
  String systemVersion = '';
}

class FakePlatformVersions extends Fake
    with MockPlatformInterfaceMixin
    implements DeviceInfoPlatform {
  FakeAndroidDeviceInfo androidDeviceInfo =
      FakeAndroidDeviceInfo(FakeAndroidDeviceVersion());

  /// Gets the Android device information.
  @override
  Future<AndroidDeviceInfo> androidInfo() async {
    return androidDeviceInfo;
  }

  FakeIOSDeviceInfo iosDeviceInfo = FakeIOSDeviceInfo();

  /// Gets the iOS device information.
  @override
  Future<IosDeviceInfo> iosInfo() async {
    return iosDeviceInfo;
  }
}

void main() {
  test('Should get if system theme is supported', () async {
    LocalPlatform.overridePlatform = PlatformOverride.unsupported;
    expect(await SettingsDao.supportsThemeModeSystem, isFalse);

    LocalPlatform.overridePlatform = PlatformOverride.linux;
    expect(await SettingsDao.supportsThemeModeSystem, isTrue);

    LocalPlatform.overridePlatform = PlatformOverride.web;
    expect(await SettingsDao.supportsThemeModeSystem, isTrue);

    final fakeVersion = FakePlatformVersions();
    DeviceInfoPlatform.instance = fakeVersion;

    fakeVersion.androidDeviceInfo.fakeVersion.sdkInt = 30;

    LocalPlatform.overridePlatform = PlatformOverride.android;
    expect(await SettingsDao.supportsThemeModeSystem, isTrue);

    fakeVersion.iosDeviceInfo.systemVersion = '13.0';

    LocalPlatform.overridePlatform = PlatformOverride.ios;
    expect(await SettingsDao.supportsThemeModeSystem, isTrue);

    LocalPlatform.overridePlatform = null;
  });

  test('Should return system theme based on Android version', () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final fakeVersion = FakePlatformVersions();
    DeviceInfoPlatform.instance = fakeVersion;

    fakeVersion.androidDeviceInfo.fakeVersion.sdkInt = 29;
    expect(await SettingsDao.supportsThemeModeSystem, isTrue);

    fakeVersion.androidDeviceInfo.fakeVersion.sdkInt = 5;
    expect(await SettingsDao.supportsThemeModeSystem, isFalse);

    LocalPlatform.overridePlatform = null;
  });

  test('Should return system theme based on iOS version', () async {
    LocalPlatform.overridePlatform = PlatformOverride.ios;

    final fakeVersion = FakePlatformVersions();
    DeviceInfoPlatform.instance = fakeVersion;

    fakeVersion.iosDeviceInfo.systemVersion = '13.0';
    expect(await SettingsDao.supportsThemeModeSystem, isTrue);

    fakeVersion.iosDeviceInfo.systemVersion = '13.1';
    expect(await SettingsDao.supportsThemeModeSystem, isTrue);

    fakeVersion.iosDeviceInfo.systemVersion = '12.0';
    expect(await SettingsDao.supportsThemeModeSystem, isFalse);

    fakeVersion.iosDeviceInfo.systemVersion = '12.2';
    expect(await SettingsDao.supportsThemeModeSystem, isFalse);

    LocalPlatform.overridePlatform = null;
  });
}
