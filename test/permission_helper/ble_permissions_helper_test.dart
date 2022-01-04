import 'package:device_info_platform_interface/device_info_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/permissions_helper/ble_permissions_helper.dart';
import 'package:lighthouse_pm/platform_specific/mobile/local_platform.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../helpers/fake_device_info.dart';

class FakePermissionHandlerPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PermissionHandlerPlatform {
  PermissionStatus _status = PermissionStatus.granted;

  PermissionStatus get status => _status;

  set status(PermissionStatus status) {
    _status = status;
    statusMap.clear();
  }

  Map<Permission, PermissionStatus> statusMap = {};

  @override
  Future<PermissionStatus> checkPermissionStatus(Permission permission) async {
    return statusMap[permission] ?? status;
  }

  @override
  Future<Map<Permission, PermissionStatus>> requestPermissions(
      List<Permission> permissions) async {
    var output = <Permission, PermissionStatus>{};
    for (final permission in permissions) {
      output[permission] = statusMap[permission] ?? status;
    }
    return output;
  }
}

void main() {
  test('Should return granted for the correct platforms, hasBLEPermissions',
      () async {
    LocalPlatform.overridePlatform = PlatformOverride.unsupported;
    try {
      await BLEPermissionsHelper.hasBLEPermissions();
      fail('Should throw an error');
    } catch (e) {
      expect(e, isA<UnsupportedError>());
      expect((e as UnsupportedError).message, contains('UNKNOWN'));
    }

    LocalPlatform.overridePlatform = PlatformOverride.web;
    expect(await BLEPermissionsHelper.hasBLEPermissions(),
        PermissionStatus.granted);

    LocalPlatform.overridePlatform = PlatformOverride.linux;
    expect(await BLEPermissionsHelper.hasBLEPermissions(),
        PermissionStatus.granted);

    LocalPlatform.overridePlatform = null;
  });

  test('Should return granted for the correct platforms, requestBLEPermissions',
      () async {
    LocalPlatform.overridePlatform = PlatformOverride.unsupported;
    try {
      await BLEPermissionsHelper.requestBLEPermissions();
      fail('Should throw an error');
    } catch (e) {
      expect(e, isA<UnsupportedError>());
      expect((e as UnsupportedError).message, contains('UNKNOWN'));
    }

    LocalPlatform.overridePlatform = PlatformOverride.web;
    expect(await BLEPermissionsHelper.requestBLEPermissions(),
        PermissionStatus.granted);

    LocalPlatform.overridePlatform = PlatformOverride.linux;
    expect(await BLEPermissionsHelper.requestBLEPermissions(),
        PermissionStatus.granted);

    LocalPlatform.overridePlatform = null;
  });

  test('Should not open BLE settings on platforms that don\'t support it',
      () async {
    LocalPlatform.overridePlatform = PlatformOverride.unsupported;
    try {
      await BLEPermissionsHelper.openBLESettings();
      fail('Should throw an error');
    } catch (e) {
      expect(e, isA<UnsupportedError>());
      expect((e as UnsupportedError).message, contains('UNKNOWN'));
    }

    LocalPlatform.overridePlatform = PlatformOverride.ios;
    expect(await BLEPermissionsHelper.openBLESettings(), isFalse);

    LocalPlatform.overridePlatform = PlatformOverride.web;
    expect(await BLEPermissionsHelper.openBLESettings(), isFalse);

    LocalPlatform.overridePlatform = PlatformOverride.linux;
    expect(await BLEPermissionsHelper.openBLESettings(), isFalse);

    LocalPlatform.overridePlatform = null;
  });

  test(
      'Should not be able to enable BLE settings on platforms that don\'t support it',
      () async {
    LocalPlatform.overridePlatform = PlatformOverride.unsupported;
    try {
      await BLEPermissionsHelper.enableBLE();
      fail('Should throw an error');
    } catch (e) {
      expect(e, isA<UnsupportedError>());
      expect((e as UnsupportedError).message, contains('UNKNOWN'));
    }

    LocalPlatform.overridePlatform = PlatformOverride.ios;
    expect(await BLEPermissionsHelper.enableBLE(), isFalse);

    LocalPlatform.overridePlatform = PlatformOverride.web;
    expect(await BLEPermissionsHelper.enableBLE(), isFalse);

    LocalPlatform.overridePlatform = PlatformOverride.linux;
    expect(await BLEPermissionsHelper.enableBLE(), isFalse);

    LocalPlatform.overridePlatform = null;
  });

  test(
      'Should not be able to go to location settings on platforms that don\'t support it',
      () async {
    LocalPlatform.overridePlatform = PlatformOverride.unsupported;
    try {
      await BLEPermissionsHelper.openLocationSettings();
      fail('Should throw an error');
    } catch (e) {
      expect(e, isA<UnsupportedError>());
      expect((e as UnsupportedError).message, contains('UNKNOWN'));
    }

    LocalPlatform.overridePlatform = PlatformOverride.ios;
    expect(await BLEPermissionsHelper.openLocationSettings(), isFalse);

    LocalPlatform.overridePlatform = PlatformOverride.web;
    expect(await BLEPermissionsHelper.openLocationSettings(), isFalse);

    LocalPlatform.overridePlatform = PlatformOverride.linux;
    expect(await BLEPermissionsHelper.openLocationSettings(), isFalse);

    LocalPlatform.overridePlatform = null;
  });

  test('Should return hasBLEPermission on iOS', () async {
    LocalPlatform.overridePlatform = PlatformOverride.ios;

    final fake = FakePermissionHandlerPlatform();
    PermissionHandlerPlatform.instance = fake;

    fake.status = PermissionStatus.granted;
    expect(await BLEPermissionsHelper.hasBLEPermissions(),
        PermissionStatus.granted);

    fake.status = PermissionStatus.denied;
    expect(await BLEPermissionsHelper.hasBLEPermissions(),
        PermissionStatus.denied);

    fake.status = PermissionStatus.permanentlyDenied;
    expect(await BLEPermissionsHelper.hasBLEPermissions(),
        PermissionStatus.permanentlyDenied);

    LocalPlatform.overridePlatform = null;
  });

  test('Should return correct value with requestBLEPermission on iOS',
      () async {
    LocalPlatform.overridePlatform = PlatformOverride.ios;

    final fake = FakePermissionHandlerPlatform();
    PermissionHandlerPlatform.instance = fake;

    fake.status = PermissionStatus.granted;
    expect(await BLEPermissionsHelper.requestBLEPermissions(),
        PermissionStatus.granted);

    fake.status = PermissionStatus.denied;
    expect(await BLEPermissionsHelper.requestBLEPermissions(),
        PermissionStatus.denied);

    fake.status = PermissionStatus.permanentlyDenied;
    expect(await BLEPermissionsHelper.requestBLEPermissions(),
        PermissionStatus.permanentlyDenied);

    LocalPlatform.overridePlatform = null;
  });

  test('Should return hasBLEPermissions on Android 11', () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;

    final fake = FakePermissionHandlerPlatform();
    PermissionHandlerPlatform.instance = fake;

    final fakeVersion = FakePlatformVersions();
    DeviceInfoPlatform.instance = fakeVersion;

    fakeVersion.androidDeviceInfo.fakeVersion.sdkInt = 30;
    fake.status = PermissionStatus.granted;
    expect(await BLEPermissionsHelper.hasBLEPermissions(),
        PermissionStatus.granted);

    fake.status = PermissionStatus.denied;
    expect(await BLEPermissionsHelper.hasBLEPermissions(),
        PermissionStatus.denied);

    fake.status = PermissionStatus.permanentlyDenied;
    expect(await BLEPermissionsHelper.hasBLEPermissions(),
        PermissionStatus.permanentlyDenied);

    LocalPlatform.overridePlatform = null;
  });

  test('Should return hasBLEPermissions on Android 12', () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;

    final fake = FakePermissionHandlerPlatform();
    PermissionHandlerPlatform.instance = fake;

    final fakeVersion = FakePlatformVersions();
    DeviceInfoPlatform.instance = fakeVersion;

    fakeVersion.androidDeviceInfo.fakeVersion.sdkInt = 31;

    final permissions = [Permission.bluetoothScan, Permission.bluetoothConnect];
    final states = [
      PermissionStatus.granted,
      PermissionStatus.denied,
      PermissionStatus.permanentlyDenied
    ];

    for (final state1 in states) {
      for (final state2 in states) {
        fake.statusMap[permissions[0]] = state1;
        fake.statusMap[permissions[1]] = state2;

        final hasPermission = await BLEPermissionsHelper.hasBLEPermissions();

        final expected = getLowest([state1, state2]);

        expect(hasPermission, equals(expected),
            reason: "${permissions[0].toString()} = "
                "${state1.toString()}, "
                "${permissions[1].toString()}, "
                "${state2.toString()}. "
                "Expected = ${expected.toString()}");
      }
    }

    LocalPlatform.overridePlatform = null;
  });

  test('Should return correct value with requestBLEPermission on Android 11',
      () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;

    final fake = FakePermissionHandlerPlatform();
    PermissionHandlerPlatform.instance = fake;

    final fakeVersion = FakePlatformVersions();
    DeviceInfoPlatform.instance = fakeVersion;

    fakeVersion.androidDeviceInfo.fakeVersion.sdkInt = 30;

    fake.status = PermissionStatus.granted;
    expect(await BLEPermissionsHelper.requestBLEPermissions(),
        PermissionStatus.granted);

    fake.status = PermissionStatus.denied;
    expect(await BLEPermissionsHelper.requestBLEPermissions(),
        PermissionStatus.denied);

    fake.status = PermissionStatus.permanentlyDenied;
    expect(await BLEPermissionsHelper.requestBLEPermissions(),
        PermissionStatus.permanentlyDenied);

    LocalPlatform.overridePlatform = null;
  });

  test('Should return correct with requestBLEPermission on Android 12',
      () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;

    final fake = FakePermissionHandlerPlatform();
    PermissionHandlerPlatform.instance = fake;

    final fakeVersion = FakePlatformVersions();
    DeviceInfoPlatform.instance = fakeVersion;

    fakeVersion.androidDeviceInfo.fakeVersion.sdkInt = 31;

    final permissions = [Permission.bluetoothScan, Permission.bluetoothConnect];
    final states = [
      PermissionStatus.granted,
      PermissionStatus.denied,
      PermissionStatus.permanentlyDenied
    ];

    for (final state1 in states) {
      for (final state2 in states) {
        fake.statusMap[permissions[0]] = state1;
        fake.statusMap[permissions[1]] = state2;

        final hasPermission =
            await BLEPermissionsHelper.requestBLEPermissions();

        final expected = getLowest([state1, state2]);

        expect(hasPermission, equals(expected),
            reason: "${permissions[0].toString()} = "
                "${state1.toString()}, "
                "${permissions[1].toString()}, "
                "${state2.toString()}. "
                "Expected = ${expected.toString()}");
      }
    }

    LocalPlatform.overridePlatform = null;
  });

  test('Should open BLE settings on Android', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    LocalPlatform.overridePlatform = PlatformOverride.android;

    BLEPermissionsHelper.channel.setMockMethodCallHandler((call) async {
      if (call.method == "openBLESettings") {
        return true;
      }
    });

    expect(await BLEPermissionsHelper.openBLESettings(), isTrue);

    BLEPermissionsHelper.channel.setMockMethodCallHandler((call) async {
      if (call.method == "openBLESettings") {
        return false;
      }
    });

    expect(await BLEPermissionsHelper.openBLESettings(), isFalse);

    BLEPermissionsHelper.channel.setMockMethodCallHandler((call) async {
      if (call.method == "openBLESettings") {
        return 'other';
      }
    });

    try {
      await BLEPermissionsHelper.openBLESettings();
      fail('Should throw an error');
    } catch (e) {
      expect(e, isA<TypeError>());
    }

    BLEPermissionsHelper.channel.setMockMethodCallHandler(null);

    LocalPlatform.overridePlatform = null;
  });

  test('Should enable BLE on Android', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    LocalPlatform.overridePlatform = PlatformOverride.android;

    BLEPermissionsHelper.channel.setMockMethodCallHandler((call) async {
      if (call.method == "enableBluetooth") {
        return true;
      }
    });

    expect(await BLEPermissionsHelper.enableBLE(), isTrue);

    BLEPermissionsHelper.channel.setMockMethodCallHandler((call) async {
      if (call.method == "enableBluetooth") {
        return false;
      }
    });

    expect(await BLEPermissionsHelper.enableBLE(), isFalse);

    BLEPermissionsHelper.channel.setMockMethodCallHandler((call) async {
      if (call.method == "enableBluetooth") {
        return 'other';
      }
    });

    try {
      await BLEPermissionsHelper.enableBLE();
      fail('Should throw an error');
    } catch (e) {
      expect(e, isA<TypeError>());
    }

    BLEPermissionsHelper.channel.setMockMethodCallHandler(null);

    LocalPlatform.overridePlatform = null;
  });

  test('Should enable BLE on Android', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    LocalPlatform.overridePlatform = PlatformOverride.android;

    BLEPermissionsHelper.channel.setMockMethodCallHandler((call) async {
      if (call.method == "openLocationSettings") {
        return true;
      }
    });

    expect(await BLEPermissionsHelper.openLocationSettings(), isTrue);

    BLEPermissionsHelper.channel.setMockMethodCallHandler((call) async {
      if (call.method == "openLocationSettings") {
        return false;
      }
    });

    expect(await BLEPermissionsHelper.openLocationSettings(), isFalse);

    BLEPermissionsHelper.channel.setMockMethodCallHandler((call) async {
      if (call.method == "openLocationSettings") {
        return 'other';
      }
    });

    try {
      await BLEPermissionsHelper.openLocationSettings();
      fail('Should throw an error');
    } catch (e) {
      expect(e, isA<TypeError>());
    }

    BLEPermissionsHelper.channel.setMockMethodCallHandler(null);

    LocalPlatform.overridePlatform = null;
  });
}

///
/// Get the first non granted permission from the list.
/// Wil return [PermissionStatus.granted] if all of them are granted.
///
PermissionStatus getLowest(List<PermissionStatus> states) {
  for (final state in states) {
    if (!(state.isGranted)) {
      return state;
    }
  }
  return states.last;
}
