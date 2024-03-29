import 'package:fake_back_end/fake_back_end.dart';
import 'package:lighthouse_provider/device_extensions/device_extension.dart';
import 'package:lighthouse_provider/lighthouse_provider.dart';
import 'package:lighthouse_providers/vive_base_station_device_provider.dart';
import 'package:lighthouse_test_helper/lighthouse_test_helper.dart';
import 'package:shared_platform/shared_platform_io.dart';
import 'package:test/test.dart';

void main() {
  setUp(() {
    SharedPlatform.overridePlatform = PlatformOverride.android;
  });

  tearDown(() {
    SharedPlatform.overridePlatform = null;
  });

  test("Firmware should be unknown if verify hasn't run, ViveBaseStationDevice",
      () {
    final persistence = FakeViveBaseStationBloc();
    final device = ViveBaseStationDevice(
        FakeViveBaseStationDevice(0, 0), persistence, null);

    expect(device.firmwareVersion, "UNKNOWN");
  });

  test("Firmware should be known if verify has run, ViveBaseStationDevice",
      () async {
    final persistence = FakeViveBaseStationBloc();
    final device = ViveBaseStationDevice(
        FakeViveBaseStationDevice(0, 0), persistence, null);

    final valid = await device.isValid();
    expect(valid, true);

    expect(device.firmwareVersion, "FAKE_DEVICE");
  });

  test("Setting deviceId should set metadata", () async {
    final persistence = FakeViveBaseStationBloc();

    persistence.startViveBaseStationIdsStream();

    final device =
        ViveBaseStationDevice(FakeViveBaseStationDevice(0, 0), persistence,
            (final _, final __) async {
      return null;
    });
    persistence.insertId(device.deviceIdentifier, 0x12345678);

    final valid = await device.isValid();
    expect(valid, true);

    final storedId = device.otherMetadata['Id'];
    expect(storedId, '0x12345678', reason: "Should store id in metadata map");
  });

  test("Should be able to parse device name", () async {
    final persistence = FakeViveBaseStationBloc();

    final device = ViveBaseStationDevice(
        FakeViveBaseStationDevice(0, 0), persistence, null);
    final valid = await device.isValid();
    expect(valid, true);

    expect(device.pairIdEndHint, 0x0000);
  });

  test("Should not fail if name is not parsable", () async {
    final persistence = FakeViveBaseStationBloc();

    final device = ViveBaseStationDevice(
        ViveBaseStationWithIncorrectName(), persistence, null);

    expect(device.name, "HTC BS 0000GH");

    final valid = await device.isValid();
    expect(valid, true);

    expect(device.pairIdEndHint, isNull);
  });

  test("Should not fail if bloc is not set", () async {
    final device =
        ViveBaseStationDevice(FakeViveBaseStationDevice(0, 0), null, null);

    final valid = await device.isValid();
    expect(valid, true);

    expect(device.persistence, isNull);
  });

  test("Should handle connection timeout, ViveBaseStationDevice", () async {
    final persistence = FakeViveBaseStationBloc();
    final lowLevelDevice = FailingBLEDeviceOnConnect();
    final device = ViveBaseStationDevice(lowLevelDevice, persistence, null);

    final valid = await device.isValid();
    expect(valid, false,
        reason: "Device should not be valid if no connection can take place");
  });

  test("Should handle connection error, ViveBaseStationDevice", () async {
    final persistence = FakeViveBaseStationBloc();
    final lowLevelDevice = FailingBLEDeviceOnConnect();
    lowLevelDevice.useTimeoutException = false;

    final device = ViveBaseStationDevice(lowLevelDevice, persistence, null);

    final valid = await device.isValid();
    expect(valid, false,
        reason: "Device should not be valid if no connection can take place");
  });

  test("Should have otherMetadata, ViveBaseStationDevice", () async {
    final persistence = FakeViveBaseStationBloc();
    final device = ViveBaseStationDevice(
        FakeViveBaseStationDevice(0, 0), persistence, null);

    final valid = await device.isValid();
    expect(valid, true);

    final otherMetadata = device.otherMetadata;

    expect(otherMetadata['Model number'], "255");
    expect(otherMetadata['Serial number'], "255");
    expect(otherMetadata['Hardware revision'], "FAKE_REVISION");
    expect(otherMetadata['Manufacturer name'], "LIGHTHOUSE PM By Jeroen1602");
  });

  test(
      "Should not crash when some secondary characteristics fail, ViveBaseStationDevice",
      () async {
    final persistence = FakeViveBaseStationBloc();
    final device = ViveBaseStationDevice(
        FailingViveBaseStationDeviceOnSpecificCharacteristics(),
        persistence,
        null);

    final valid = await device.isValid();
    expect(valid, true);

    final otherMetadata = device.otherMetadata;

    expect(otherMetadata, isNot(contains('Model number')));
    expect(otherMetadata, isNot(contains('Serial number')));
    expect(otherMetadata, isNot(contains('Hardware revision')));
    expect(otherMetadata, isNot(contains('Manufacturer name')));

    expect(device.firmwareVersion, "UNKNOWN");
  });

  test("Should not return valid if device isn't valid, ViveBaseStationDevice",
      () async {
    final persistence = FakeViveBaseStationBloc();
    final lowDevice = CountingFakeLighthouseV2Device();
    final device = ViveBaseStationDevice(lowDevice, persistence, null);

    final valid = await device.isValid();
    expect(valid, false);

    expect(lowDevice.disconnectCount, 1);
  });

  test("Should add correct extensions, ViveBaseStationDevice", () async {
    final persistence = FakeViveBaseStationBloc();
    final device = ViveBaseStationDevice(
        FakeViveBaseStationDevice(0, 0), persistence, null);

    final valid = await device.isValid();
    expect(valid, true);
    device.afterIsValid();

    await Future.delayed(Duration(milliseconds: 10));

    expect(device.deviceExtensions, contains(isA<SleepExtension>()));
    expect(device.deviceExtensions, contains(isA<OnExtension>()));
    expect(device.deviceExtensions, contains(isA<ClearIdExtension>()));
  });

  test("Should not show extra info dialog if id is set", () async {
    final persistence = FakeViveBaseStationBloc();

    persistence.startViveBaseStationIdsStream();

    final device = ViveBaseStationDevice(
        FakeViveBaseStationDevice(0, 0), persistence, null);
    persistence.insertId(device.deviceIdentifier, 0x12345678);

    final valid = await device.isValid();
    expect(valid, true);

    final value = await device.requestExtraInfo();

    expect(value, true);
  });

  test("Should not change state if id is null", () async {
    final persistence = FakeViveBaseStationBloc();

    persistence.startViveBaseStationIdsStream();

    final device = ViveBaseStationDevice(
        FakeViveBaseStationDevice(0, 0), persistence, null);

    final valid = await device.isValid();
    expect(valid, true);

    try {
      await device.internalChangeState(LighthousePowerState.on);
      fail("Should have failed");
    } catch (e) {
      expect(e, isA<AssertionError>());
    }
  });

  test("Should throw if request extra info is null", () async {
    final persistence = FakeViveBaseStationBloc();
    persistence.startViveBaseStationIdsStream();

    final device = ViveBaseStationDevice(
        FakeViveBaseStationDevice(0, 0), persistence, null);

    final valid = await device.isValid();
    expect(valid, isTrue);

    try {
      await device.requestExtraInfo(null);
      fail('Should throw');
    } catch (e) {
      expect(e, isA<StateError>());
      expect((e as StateError).message,
          contains("Request pair id has not been set"));
    }

    expect(device.pairId, isNull, reason: "Nothing should have been stored");
  });

  test("Should request extra info if id is not set", () async {
    final persistence = FakeViveBaseStationBloc();
    persistence.startViveBaseStationIdsStream();

    bool requested = false;

    final device =
        ViveBaseStationDevice(FakeViveBaseStationDevice(0, 0), persistence,
            (final _, final hint) async {
      expect(hint, isNotNull);
      expect(hint, equals(0x0000));
      requested = true;
      return null;
    });

    final valid = await device.isValid();
    expect(valid, isTrue);

    final mayContinue = await device.requestExtraInfo(null);

    expect(requested, isTrue, reason: "Should have requested new device info");
    expect(mayContinue, isFalse, reason: "Should not have saved any new info");
    expect(device.pairId, isNull, reason: "Nothing should have been stored");
  });

  test("Should not store pair ids if storage is null", () async {
    bool requested = false;

    final device = ViveBaseStationDevice(FakeViveBaseStationDevice(0, 0), null,
        (final _, final hint) async {
      expect(hint, isNotNull);
      expect(hint, equals(0x0000));
      requested = true;
      return "1234";
    });

    final valid = await device.isValid();
    expect(valid, isTrue);

    final mayContinue = await device.requestExtraInfo(null);

    expect(requested, isTrue, reason: "Should have requested new device info");
    expect(mayContinue, isTrue,
        reason: "Storage is null so it can't be stored");
    expect(device.pairId, isNotNull,
        reason: "Pair id should still be stored in memory");
  });

  test("Should not store pair id if input cannot be converted to a number",
      () async {
    final persistence = FakeViveBaseStationBloc();
    persistence.startViveBaseStationIdsStream();

    bool requested = false;

    final device =
        ViveBaseStationDevice(FakeViveBaseStationDevice(0, 0), persistence,
            (final _, final hint) async {
      expect(hint, isNotNull);
      expect(hint, equals(0x0000));
      requested = true;
      return "defg";
    });

    final valid = await device.isValid();
    expect(valid, true);

    final mayContinue = await device.requestExtraInfo(null);

    expect(requested, isTrue, reason: "Should have requested new device info");
    expect(mayContinue, isFalse,
        reason: "Returned value is invalid so it can't continue");
    expect(device.pairId, isNull, reason: "Pair id should nto be stored");
  });

  test("Should show extra info dialog if id is not set, no end hint", () async {
    final persistence = FakeViveBaseStationBloc();
    persistence.startViveBaseStationIdsStream();

    bool requested = false;

    final device =
        ViveBaseStationDevice(FakeViveBaseStationDevice(0, 0), persistence,
            (final _, final hint) async {
      expect(hint, isNull);
      requested = true;
      return null;
    });

    final valid = await device.isValid();
    expect(valid, true);

    device.pairIdEndHint = null;

    final mayContinue = await device.requestExtraInfo(null);

    expect(requested, isTrue, reason: "Should have requested new device info");
    expect(mayContinue, isFalse,
        reason: "Returned null so no reason to continue.");
    expect(device.pairId, isNull, reason: "Pair id should nto be stored");
  });

  test("Should be able to store id if everything goes well", () async {
    final persistence = FakeViveBaseStationBloc();
    persistence.startViveBaseStationIdsStream();

    bool requested = false;

    final device =
        ViveBaseStationDevice(FakeViveBaseStationDevice(0, 0), persistence,
            (final _, final hint) async {
      expect(hint, isNotNull);
      expect(hint, equals(0x0000));
      requested = true;
      return "1234";
    });

    final valid = await device.isValid();
    expect(valid, true);

    final mayContinue = await device.requestExtraInfo(null);

    expect(requested, isTrue, reason: "Should have requested new device info");
    expect(mayContinue, isTrue, reason: "Everything should have gone well");
    expect(device.pairId, isNotNull,
        reason: "Pair id should still be stored in memory");
    expect(device.pairId, equals(0x12340000),
        reason: "Pair id should still be stored in memory");
  });

  test("Should be able to go from sleep to on", () async {
    final persistence = FakeViveBaseStationBloc();
    persistence.startViveBaseStationIdsStream();

    final device = ViveBaseStationDevice(
        FakeViveBaseStationDevice(0, 0), persistence, null);
    persistence.insertId(device.deviceIdentifier, 0x12345678);

    final valid = await device.isValid();
    expect(valid, true);

    //First turn off the device
    await device.changeState(LighthousePowerState.sleep);

    //Now turn it on
    await device.changeState(LighthousePowerState.on);

    expect(device.transactionMutex.isLocked, false,
        reason: "Transaction mutex should have been released");
  });

  test("Should be able to go from on to sleep", () async {
    final persistence = FakeViveBaseStationBloc();
    persistence.startViveBaseStationIdsStream();

    final device = ViveBaseStationDevice(
        FakeViveBaseStationDevice(0, 0), persistence, null);
    persistence.insertId(device.deviceIdentifier, 0x12345678);

    final valid = await device.isValid();
    expect(valid, true);

    //First turn on the device
    await device.changeState(LighthousePowerState.on);

    //Now set it to sleep
    await device.changeState(LighthousePowerState.sleep);

    expect(device.transactionMutex.isLocked, false,
        reason: "Transaction mutex should have been released");
  });

  test("Should not go to standby, ViveBaseStationDevice", () async {
    final persistence = FakeViveBaseStationBloc();
    persistence.startViveBaseStationIdsStream();

    final device = ViveBaseStationDevice(
        FakeViveBaseStationDevice(0, 0), persistence, null);
    persistence.insertId(device.deviceIdentifier, 0x12345678);

    final valid = await device.isValid();
    expect(valid, true);

    //First turn on the device
    try {
      await device.changeState(LighthousePowerState.standby);
      fail("Should have thrown UnsupportedError");
    } catch (e) {
      expect(e, isA<UnsupportedError>());
    }
    expect(device.transactionMutex.isLocked, false,
        reason: "Transaction mutex should have been released");
  });

  test("Should not go to state if id is not set, ViveBaseStationDevice",
      () async {
    final persistence = FakeViveBaseStationBloc();
    persistence.startViveBaseStationIdsStream();

    final device =
        ViveBaseStationDevice(FakeViveBaseStationDevice(0, 0), persistence,
            (final _, final hint) async {
      expect(hint, isNotNull);
      expect(hint, equals(0x0000));
      return null;
    });

    final valid = await device.isValid();
    expect(valid, true);

    await device.changeState(LighthousePowerState.on);

    expect(device.transactionMutex.isLocked, false,
        reason: "Transaction mutex should have been released");
  });

  test("Should be able to clear the id via the extension", () async {
    final persistence = FakeViveBaseStationBloc();
    persistence.startViveBaseStationIdsStream([
      ViveBaseStationStorage(LHDeviceIdentifier("00:00:00:00:00:00"), 0xFF0134)
    ]);

    final device = await createValidViveDevice(0, 0, persistence);

    expect(device.pairId, 0xFF0134, reason: "Pair id should be set");

    final clear = device.deviceExtensions
        .cast<DeviceExtension?>()
        .whereType<ClearIdExtension>()
        .first;

    expect(clear, isNotNull, reason: "Should have a clear id extension!");

    await clear.onTap();

    expect(device.pairId, isNull, reason: "Pair id should not be set");
  });
}
