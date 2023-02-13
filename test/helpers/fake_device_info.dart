// ignore_for_file: depend_on_referenced_packages

import 'package:device_info_plus_platform_interface/device_info_plus_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_platform/shared_platform.dart';

class FakeAndroidDeviceInfo extends BaseDeviceInfo {
  FakeAndroidDeviceInfo({final int? sdkInt})
      : super({
          'version': {
            'baseOS': null,
            'codename': 'UNIT_TEST',
            'incremental': 'no?',
            'previewSdkInt': null,
            'release': 'no',
            'sdkInt': sdkInt ?? -1,
            'securityPatch': 'Never',
          },
          'board': 'BOARD',
          'bootloader': 'UNIT_TEST_LOADER',
          'brand': 'UNIT_TEST_BRAND',
          'device': 'UNIT_TEST',
          'display': 'NO_DISPLAY',
          'fingerprint': 'FINGERS_PRINTING',
          'hardware': 'THE_CURRENTLY_RUNNING_COMPUTER',
          'host': 'localhost',
          'id': 'IDENTIFICATION',
          'manufacturer': 'SOMEONE_PROBABLY',
          'model': 'UNIT_TEST_MODEL',
          'product': 'UNIT_TEST',
          'supported32BitAbis': ['Probably'],
          'supported64BitAbis': ['Probably'],
          'supportedAbis': ['Probably'],
          'tags': 'UNIT_TEST_TAGS',
          'type': 'UNIT_TEST_TYPE',
          'isPhysicalDevice': false,
          'systemFeatures': ['SomeFeatures'],
          'displayMetrics': {
            'widthPx': 0.0,
            'heightPx': 0.0,
            'xDpi': 0.0,
            'yDpi': 0.0
          },
          'serialNumber': 'SERIAL_NUMBER',
        });

  void setSdkInt(final int sdkInt) {
    data['version']['sdkInt'] = sdkInt;
  }
}

class FakeIOSDeviceInfo extends BaseDeviceInfo {
  FakeIOSDeviceInfo({final String? systemVersion})
      : super({
          'name': 'phone with an i somewhere',
          'systemName': 'Darwin?',
          'systemVersion': systemVersion ?? '0.0',
          'model': 'phone with an i somewhere',
          'localizedModel': 'phone with an i somewhere',
          'identifierForVendor': null,
          'isPhysicalDevice': 'false',
          'utsname': {
            'sysname': 'THIS_PC',
            'nodename': 'localhost',
            'release': '0.0',
            'version': '-1.0',
            'machine': 'THIS_MACHINE'
          }
        });

  set systemVersion(final String version) {
    data['systemVersion'] = version;
  }
}

class FakePlatformVersions extends Fake
    with MockPlatformInterfaceMixin
    implements DeviceInfoPlatform {
  FakeAndroidDeviceInfo androidDeviceInfo = FakeAndroidDeviceInfo();

  FakeIOSDeviceInfo iosDeviceInfo = FakeIOSDeviceInfo();

  @override
  Future<BaseDeviceInfo> deviceInfo() async {
    if (SharedPlatform.isAndroid) {
      return androidDeviceInfo;
    } else if (SharedPlatform.isIOS) {
      return iosDeviceInfo;
    }
    throw UnimplementedError(
        'deviceInfo() has not been implemented on this platform.');
  }
}
