import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/bloc/vive_base_station_bloc.dart';
import 'package:lighthouse_pm/lighthouse_back_ends/fake/fake_back_end.dart';
import 'package:lighthouse_pm/lighthouse_provider/device_extensions/device_extension.dart';
import 'package:lighthouse_pm/lighthouse_provider/lighthouse_provider.dart';
import 'package:lighthouse_pm/lighthouse_providers/vive_base_station_device_provider.dart';
import 'package:lighthouse_pm/platform_specific/mobile/local_platform.dart';
import 'package:rxdart/rxdart.dart';

import '../../helpers/failing_ble_device.dart';
import '../../helpers/fake_bloc.dart';
import '../../helpers/widget_helpers.dart';

void main() {
  test("Firmware should be unknown if verify hasn't run, ViveBaseStationDevice",
      () {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final persistence = ViveBaseStationBloc(FakeBloc.normal());
    final device =
        ViveBaseStationDevice(FakeViveBaseStationDevice(0, 0), persistence);

    expect(device.firmwareVersion, "UNKNOWN");

    LocalPlatform.overridePlatform = null;
  });

  test("Firmware should be known if verify has run, ViveBaseStationDevice",
      () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final persistence = ViveBaseStationBloc(FakeBloc.normal());
    final device =
        ViveBaseStationDevice(FakeViveBaseStationDevice(0, 0), persistence);

    final valid = await device.isValid();
    expect(valid, true);

    expect(device.firmwareVersion, "FAKE_DEVICE");

    LocalPlatform.overridePlatform = null;
  });

  test("Setting deviceId should set metadata", () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final bloc = FakeBloc.normal();
    final persistence = ViveBaseStationBloc(bloc);

    bloc.viveBaseStation.idsStream = BehaviorSubject.seeded([]);

    final device =
        ViveBaseStationDevice(FakeViveBaseStationDevice(0, 0), persistence);
    bloc.viveBaseStation
        .insertId(device.deviceIdentifier.toString(), 0x12345678);

    final valid = await device.isValid();
    expect(valid, true);

    final storedId = device.otherMetadata['Id'];
    expect(storedId, '0x12345678', reason: "Should store id in metadata map");

    LocalPlatform.overridePlatform = null;
  });

  test("Should be able to parse device name", () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final persistence = ViveBaseStationBloc(FakeBloc.normal());

    final device =
        ViveBaseStationDevice(FakeViveBaseStationDevice(0, 0), persistence);
    final valid = await device.isValid();
    expect(valid, true);

    expect(device.pairIdEndHint, 0x0000);

    LocalPlatform.overridePlatform = null;
  });

  test("Should not fail if name is not parsable", () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final persistence = ViveBaseStationBloc(FakeBloc.normal());

    final device =
        ViveBaseStationDevice(ViveBaseStationWithIncorrectName(), persistence);

    expect(device.name, "HTC BS 0000GH");

    final valid = await device.isValid();
    expect(valid, true);

    expect(device.pairIdEndHint, isNull);

    LocalPlatform.overridePlatform = null;
  });

  test("Should not fail if bloc is not set", () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;

    final device = ViveBaseStationDevice(FakeViveBaseStationDevice(0, 0), null);

    final valid = await device.isValid();
    expect(valid, true);

    expect(device.persistence, isNull);

    LocalPlatform.overridePlatform = null;
  });

  test("Should handle connection timeout, ViveBaseStationDevice", () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final persistence = ViveBaseStationBloc(FakeBloc.normal());
    final lowLevelDevice = FailingBLEDeviceOnConnect();
    final device = ViveBaseStationDevice(lowLevelDevice, persistence);

    final valid = await device.isValid();
    expect(valid, false,
        reason: "Device should not be valid if no connection can take place");

    LocalPlatform.overridePlatform = null;
  });

  test("Should handle connection error, ViveBaseStationDevice", () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final persistence = ViveBaseStationBloc(FakeBloc.normal());
    final lowLevelDevice = FailingBLEDeviceOnConnect();
    lowLevelDevice.useTimeoutException = false;

    final device = ViveBaseStationDevice(lowLevelDevice, persistence);

    final valid = await device.isValid();
    expect(valid, false,
        reason: "Device should not be valid if no connection can take place");

    LocalPlatform.overridePlatform = null;
  });

  test("Should have otherMetadata, ViveBaseStationDevice", () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final persistence = ViveBaseStationBloc(FakeBloc.normal());
    final device =
        ViveBaseStationDevice(FakeViveBaseStationDevice(0, 0), persistence);

    final valid = await device.isValid();
    expect(valid, true);

    final otherMetadata = device.otherMetadata;

    expect(otherMetadata['Model number'], "255");
    expect(otherMetadata['Serial number'], "255");
    expect(otherMetadata['Hardware revision'], "FAKE_REVISION");
    expect(otherMetadata['Manufacturer name'], "LIGHTHOUSE PM By Jeroen1602");

    LocalPlatform.overridePlatform = null;
  });

  test(
      "Should not crash when some secondary characteristics fail, ViveBaseStationDevice",
      () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final persistence = ViveBaseStationBloc(FakeBloc.normal());
    final device = ViveBaseStationDevice(
        FailingViveBaseStationDeviceOnSpecificCharacteristics(), persistence);

    final valid = await device.isValid();
    expect(valid, true);

    final otherMetadata = device.otherMetadata;

    expect(otherMetadata, isNot(contains('Model number')));
    expect(otherMetadata, isNot(contains('Serial number')));
    expect(otherMetadata, isNot(contains('Hardware revision')));
    expect(otherMetadata, isNot(contains('Manufacturer name')));

    expect(device.firmwareVersion, "UNKNOWN");

    LocalPlatform.overridePlatform = null;
  });

  test("Should not return valid if device isn't valid, ViveBaseStationDevice",
      () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final persistence = ViveBaseStationBloc(FakeBloc.normal());
    final lowDevice = CountingFakeLighthouseV2Device();
    final device = ViveBaseStationDevice(lowDevice, persistence);

    final valid = await device.isValid();
    expect(valid, false);

    expect(lowDevice.disconnectCount, 1);

    LocalPlatform.overridePlatform = null;
  });

  test("Should add correct extensions, ViveBaseStationDevice", () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final persistence = ViveBaseStationBloc(FakeBloc.normal());
    final device =
        ViveBaseStationDevice(FakeViveBaseStationDevice(0, 0), persistence);

    final valid = await device.isValid();
    expect(valid, true);
    device.afterIsValid();

    await Future.delayed(Duration(milliseconds: 10));

    expect(device.deviceExtensions, contains(isA<SleepExtension>()));
    expect(device.deviceExtensions, contains(isA<OnExtension>()));
    expect(device.deviceExtensions, contains(isA<ClearIdExtension>()));

    LocalPlatform.overridePlatform = null;
  });

  testWidgets("Should not show extra info dialog if id is set",
      (widgetTester) async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final bloc = FakeBloc.normal();
    final persistence = ViveBaseStationBloc(bloc);

    bloc.viveBaseStation.idsStream = BehaviorSubject.seeded([]);

    final device =
        ViveBaseStationDevice(FakeViveBaseStationDevice(0, 0), persistence);
    bloc.viveBaseStation
        .insertId(device.deviceIdentifier.toString(), 0x12345678);

    final valid = await device.isValid();
    expect(valid, true);

    Future<bool>? future;
    await widgetTester.pumpWidget(buildTestAppForWidgets((context) {
      future = device.showExtraInfoWidget(context);
    }));

    // Wait for the progress indicator to stop
    await widgetTester.tap(find.text('X'));
    await widgetTester.pumpAndSettle();
    expect(future, isNotNull);
    final value = await future!;
    expect(value, true);

    LocalPlatform.overridePlatform = null;
  });

  testWidgets("Should show extra info dialog if id is not set",
      (widgetTester) async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final bloc = FakeBloc.normal();
    final persistence = ViveBaseStationBloc(bloc);

    bloc.viveBaseStation.idsStream = BehaviorSubject.seeded([]);

    final device =
        ViveBaseStationDevice(FakeViveBaseStationDevice(0, 0), persistence);

    final valid = await device.isValid();
    expect(valid, true);

    Future<bool>? future;
    await widgetTester.pumpWidget(buildTestAppForWidgets((context) {
      future = device.showExtraInfoWidget(context);
    }));

    // Wait for the progress indicator to stop
    await widgetTester.tap(find.text('X'));
    await widgetTester.pumpAndSettle();
    expect(future, isNotNull);

    final richText = (widgetTester.widgetList<RichText>(find.descendant(
            of: find.byType(Dialog), matching: find.byType(RichText))))
        .first;
    final text = richText.text.toPlainText();
    expect(text, contains('Base station id required.'));
    expect(text, contains('0000'), reason: "Find device id ending");

    await widgetTester.tap(find.text('Cancel'));
    await widgetTester.pumpAndSettle();
    final value = await future!;
    expect(value, false, reason: "Dialog is canceled so we can't continue");

    LocalPlatform.overridePlatform = null;
  });

  testWidgets("Should show extra info dialog if id is set, no end hint",
      (widgetTester) async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final bloc = FakeBloc.normal();
    final persistence = ViveBaseStationBloc(bloc);

    bloc.viveBaseStation.idsStream = BehaviorSubject.seeded([]);

    final device =
        ViveBaseStationDevice(ViveBaseStationWithIncorrectName(), persistence);

    final valid = await device.isValid();
    expect(valid, true);

    Future<bool>? future;
    await widgetTester.pumpWidget(buildTestAppForWidgets((context) {
      future = device.showExtraInfoWidget(context);
    }));

    // Wait for the progress indicator to stop
    await widgetTester.tap(find.text('X'));
    await widgetTester.pumpAndSettle();
    expect(future, isNotNull);

    final richText = (widgetTester.widgetList<RichText>(find.descendant(
            of: find.byType(Dialog), matching: find.byType(RichText))))
        .first;
    final text = richText.text.toPlainText();
    expect(text, contains('Base station id required.'));
    expect(text, contains('The id is found on the back.'),
        reason: "hint is not set");

    await widgetTester.tap(find.text('Cancel'));
    await widgetTester.pumpAndSettle();
    final value = await future!;
    expect(value, false, reason: "Dialog is canceled so we can't continue");

    LocalPlatform.overridePlatform = null;
  });

  testWidgets("Should be able to finish dialog",
      (WidgetTester widgetTester) async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final bloc = FakeBloc.normal();
    final persistence = ViveBaseStationBloc(bloc);

    bloc.viveBaseStation.idsStream = BehaviorSubject.seeded([]);

    final device =
        ViveBaseStationDevice(FakeViveBaseStationDevice(0, 0), persistence);

    final valid = await device.isValid();
    expect(valid, true);

    Future<bool>? future;
    await widgetTester.pumpWidget(buildTestAppForWidgets((context) {
      future = device.showExtraInfoWidget(context);
    }));

    // Wait for the progress indicator to stop
    await widgetTester.tap(find.text('X'));
    await widgetTester.pumpAndSettle();
    expect(future, isNotNull);

    final richText = (widgetTester.widgetList<RichText>(find.descendant(
            of: find.byType(Dialog), matching: find.byType(RichText))))
        .first;
    final text = richText.text.toPlainText();
    expect(text, contains('Base station id required.'));
    expect(text, contains('0000'), reason: "Find device id ending");

    final TextFormField textField =
        widgetTester.widget<TextFormField>(find.byType(TextFormField));
    await widgetTester.enterText(find.byWidget(textField), "1234");

    await widgetTester.pumpAndSettle();

    await widgetTester.tap(find.text('Set'));
    await widgetTester.pumpAndSettle();
    final value = await future!;
    expect(value, true, reason: "Dialog should be finished");

    LocalPlatform.overridePlatform = null;
  });

  test("Should be able to go from sleep to on", () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final bloc = FakeBloc.normal();
    final persistence = ViveBaseStationBloc(bloc);

    bloc.viveBaseStation.idsStream = BehaviorSubject.seeded([]);

    final device =
        ViveBaseStationDevice(FakeViveBaseStationDevice(0, 0), persistence);
    bloc.viveBaseStation
        .insertId(device.deviceIdentifier.toString(), 0x12345678);

    device.testingOverwriteMinUpdateInterval = Duration(milliseconds: 10);
    device.setUpdateInterval(Duration(milliseconds: 10));

    final valid = await device.isValid();
    expect(valid, true);

    //First turn off the device
    await device.changeState(LighthousePowerState.sleep);
    final currentState = await device.powerStateEnum
        .firstWhere((element) => element == LighthousePowerState.unknown)
        .timeout(Duration(seconds: 3));

    expect(currentState, LighthousePowerState.unknown);

    //Now turn it on
    await device.changeState(LighthousePowerState.on);

    final nextState = await device.powerStateEnum
        .firstWhere((element) => element == LighthousePowerState.unknown)
        .timeout(Duration(seconds: 3));

    expect(nextState, LighthousePowerState.unknown);
    expect(device.transactionMutex.isLocked, false,
        reason: "Transaction mutex should have been released");

    LocalPlatform.overridePlatform = null;
  });

  test("Should be able to go from on to sleep", () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final bloc = FakeBloc.normal();
    final persistence = ViveBaseStationBloc(bloc);

    bloc.viveBaseStation.idsStream = BehaviorSubject.seeded([]);

    final device =
        ViveBaseStationDevice(FakeViveBaseStationDevice(0, 0), persistence);
    bloc.viveBaseStation
        .insertId(device.deviceIdentifier.toString(), 0x12345678);

    device.testingOverwriteMinUpdateInterval = Duration(milliseconds: 10);
    device.setUpdateInterval(Duration(milliseconds: 10));

    final valid = await device.isValid();
    expect(valid, true);

    //First turn on the device
    await device.changeState(LighthousePowerState.on);
    final currentState = await device.powerStateEnum
        .firstWhere((element) => element == LighthousePowerState.unknown)
        .timeout(Duration(seconds: 3));

    expect(currentState, LighthousePowerState.unknown);

    //Now set it to sleep
    await device.changeState(LighthousePowerState.sleep);

    final nextState = await device.powerStateEnum
        .firstWhere((element) => element == LighthousePowerState.unknown)
        .timeout(Duration(seconds: 3));

    expect(nextState, LighthousePowerState.unknown);
    expect(device.transactionMutex.isLocked, false,
        reason: "Transaction mutex should have been released");

    LocalPlatform.overridePlatform = null;
  });

  test("Should not go to standby, ViveBaseStationDevice", () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final bloc = FakeBloc.normal();
    final persistence = ViveBaseStationBloc(bloc);

    bloc.viveBaseStation.idsStream = BehaviorSubject.seeded([]);

    final device =
        ViveBaseStationDevice(FakeViveBaseStationDevice(0, 0), persistence);
    bloc.viveBaseStation
        .insertId(device.deviceIdentifier.toString(), 0x12345678);

    device.testingOverwriteMinUpdateInterval = Duration(milliseconds: 10);
    device.setUpdateInterval(Duration(milliseconds: 10));

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

    LocalPlatform.overridePlatform = null;
  });

  test("Should not go to staten if id is not set, ViveBaseStationDevice",
      () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final bloc = FakeBloc.normal();
    final persistence = ViveBaseStationBloc(bloc);

    bloc.viveBaseStation.idsStream = BehaviorSubject.seeded([]);

    final device =
        ViveBaseStationDevice(FakeViveBaseStationDevice(0, 0), persistence);

    device.testingOverwriteMinUpdateInterval = Duration(milliseconds: 10);
    device.setUpdateInterval(Duration(milliseconds: 10));

    final valid = await device.isValid();
    expect(valid, true);

    final start = await device.powerState
        .firstWhere((element) => element != 0xFF)
        .timeout(Duration(seconds: 2));

    await device.changeState(LighthousePowerState.on);

    final next = await device.powerState.first;
    expect(next, start);
    expect(device.transactionMutex.isLocked, false,
        reason: "Transaction mutex should have been released");

    LocalPlatform.overridePlatform = null;
  });
}
