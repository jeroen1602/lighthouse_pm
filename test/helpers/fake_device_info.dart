import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:device_info_platform_interface/device_info_platform_interface.dart';

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
