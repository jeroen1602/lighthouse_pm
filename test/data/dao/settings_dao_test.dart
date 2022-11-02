// ignore: depend_on_referenced_packages
import 'package:device_info_plus_platform_interface/device_info_plus_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/data/dao/settings_dao.dart';
import 'package:shared_platform/shared_platform_io.dart';

import '../../helpers/fake_device_info.dart';

void main() {
  tearDown(() {
    SharedPlatform.overridePlatform = null;
  });

  test('Should get if system theme is supported', () async {
    SharedPlatform.overridePlatform = PlatformOverride.unsupported;
    expect(await SettingsDao.supportsThemeModeSystem, isFalse);

    SharedPlatform.overridePlatform = PlatformOverride.linux;
    expect(await SettingsDao.supportsThemeModeSystem, isTrue);

    SharedPlatform.overridePlatform = PlatformOverride.web;
    expect(await SettingsDao.supportsThemeModeSystem, isTrue);

    final fakeVersion = FakePlatformVersions();
    DeviceInfoPlatform.instance = fakeVersion;

    fakeVersion.androidDeviceInfo.setSdkInt(30);

    SharedPlatform.overridePlatform = PlatformOverride.android;
    expect(await SettingsDao.supportsThemeModeSystem, isTrue);

    fakeVersion.iosDeviceInfo.systemVersion = '13.0';

    SharedPlatform.overridePlatform = PlatformOverride.ios;
    expect(await SettingsDao.supportsThemeModeSystem, isTrue);
  });

  test('Should return system theme based on Android version', () async {
    SharedPlatform.overridePlatform = PlatformOverride.android;
    final fakeVersion = FakePlatformVersions();
    DeviceInfoPlatform.instance = fakeVersion;

    fakeVersion.androidDeviceInfo.setSdkInt(29);
    expect(await SettingsDao.supportsThemeModeSystem, isTrue);

    fakeVersion.androidDeviceInfo.setSdkInt(5);
    expect(await SettingsDao.supportsThemeModeSystem, isFalse);
  });

  test('Should return system theme based on iOS version', () async {
    SharedPlatform.overridePlatform = PlatformOverride.ios;

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
  });
}
