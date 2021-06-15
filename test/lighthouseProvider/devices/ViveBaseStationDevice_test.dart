import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/lighthouseProvider/LighthousePowerState.dart';
import 'package:lighthouse_pm/lighthouseProvider/backEnd/fake/FakeBluetoothDevice.dart';
import 'package:lighthouse_pm/lighthouseProvider/deviceExtensions/ClearIdExtension.dart';
import 'package:lighthouse_pm/lighthouseProvider/deviceExtensions/OnExtension.dart';
import 'package:lighthouse_pm/lighthouseProvider/deviceExtensions/SleepExtension.dart';
import 'package:lighthouse_pm/lighthouseProvider/devices/ViveBaseStationDevice.dart';
import 'package:lighthouse_pm/platformSpecific/mobile/LocalPlatform.dart';
import 'package:rxdart/rxdart.dart';

import '../../helpers/FailingBLEDevice.dart';
import '../../helpers/FakeBloc.dart';

void main() {
  test("Firmware should be unknown if verify hasn't run, ViveBaseStationDevice",
      () {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final bloc = FakeBloc.normal();
    final device = ViveBaseStationDevice(FakeViveBaseStationDevice(0, 0), bloc);

    expect(device.firmwareVersion, "UNKNOWN");

    LocalPlatform.overridePlatform = null;
  });

  test("Firmware should be known if verify hasn't run, ViveBaseStationDevice",
      () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final bloc = FakeBloc.normal();
    final device = ViveBaseStationDevice(FakeViveBaseStationDevice(0, 0), bloc);

    final valid = await device.isValid();
    expect(valid, true);

    expect(device.firmwareVersion, "FAKE_DEVICE");

    LocalPlatform.overridePlatform = null;
  });

  test("Setting deviceId should set metadata", () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final bloc = FakeBloc.normal();

    bloc.viveBaseStation.idsStream = BehaviorSubject.seeded([]);

    final device = ViveBaseStationDevice(FakeViveBaseStationDevice(0, 0), bloc);
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
    final bloc = FakeBloc.normal();

    final device = ViveBaseStationDevice(FakeViveBaseStationDevice(0, 0), bloc);
    final valid = await device.isValid();
    expect(valid, true);

    expect(device.deviceIdEndHint, 0x0000);

    LocalPlatform.overridePlatform = null;
  });

  test("Should not fail if name is not parsable", () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final bloc = FakeBloc.normal();

    final device =
        ViveBaseStationDevice(ViveBaseStationWithIncorrectName(), bloc);

    expect(device.name, "HTC BS 0000GH");

    final valid = await device.isValid();
    expect(valid, true);

    expect(device.deviceIdEndHint, isNull);

    LocalPlatform.overridePlatform = null;
  });

  test("Should not fail if bloc is not set", () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;

    final device = ViveBaseStationDevice(FakeViveBaseStationDevice(0, 0), null);

    final valid = await device.isValid();
    expect(valid, true);

    expect(device.bloc, isNull);

    LocalPlatform.overridePlatform = null;
  });

  test("Should handle connection timeout, ViveBaseStationDevice", () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final bloc = FakeBloc.normal();
    final lowLevelDevice = FailingBLEDeviceOnConnect();
    final device = ViveBaseStationDevice(lowLevelDevice, bloc);

    final valid = await device.isValid();
    expect(valid, false,
        reason: "Device should not be valid if no connection can take place");

    LocalPlatform.overridePlatform = null;
  });

  test("Should handle connection error, ViveBaseStationDevice", () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final bloc = FakeBloc.normal();
    final lowLevelDevice = FailingBLEDeviceOnConnect();
    lowLevelDevice.useTimeoutException = false;

    final device = ViveBaseStationDevice(lowLevelDevice, bloc);

    final valid = await device.isValid();
    expect(valid, false,
        reason: "Device should not be valid if no connection can take place");

    LocalPlatform.overridePlatform = null;
  });

  test("Should have otherMetadata, ViveBaseStationDevice", () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final bloc = FakeBloc.normal();
    final device = ViveBaseStationDevice(FakeViveBaseStationDevice(0, 0), bloc);

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
    final bloc = FakeBloc.normal();
    final device = ViveBaseStationDevice(
        FailingViveBaseStationDeviceOnSpecificCharacteristics(), bloc);

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
    final bloc = FakeBloc.normal();
    final lowDevice = CountingFakeLighthouseV2Device();
    final device = ViveBaseStationDevice(lowDevice, bloc);

    final valid = await device.isValid();
    expect(valid, false);

    expect(lowDevice.disconnectCount, 1);

    LocalPlatform.overridePlatform = null;
  });

  test("Should add correct extensions, ViveBaseStationDevice", () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final bloc = FakeBloc.normal();
    final device = ViveBaseStationDevice(FakeViveBaseStationDevice(0, 0), bloc);

    final valid = await device.isValid();
    expect(valid, true);
    device.afterIsValid();

    await Future.delayed(Duration(milliseconds: 10));

    expect(device.deviceExtensions, contains(TypeMatcher<SleepExtension>()));
    expect(device.deviceExtensions, contains(TypeMatcher<OnExtension>()));
    expect(device.deviceExtensions, contains(TypeMatcher<ClearIdExtension>()));

    LocalPlatform.overridePlatform = null;
  });

  testWidgets("Should not show extra info dialog if id is set",
      (widgetTester) async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final bloc = FakeBloc.normal();

    bloc.viveBaseStation.idsStream = BehaviorSubject.seeded([]);

    final device = ViveBaseStationDevice(FakeViveBaseStationDevice(0, 0), bloc);
    bloc.viveBaseStation
        .insertId(device.deviceIdentifier.toString(), 0x12345678);

    final valid = await device.isValid();
    expect(valid, true);

    Future<bool>? future;
    await widgetTester.pumpWidget(_buildTestApp((context) {
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

  testWidgets("Should show extra info dialog if id is set",
      (widgetTester) async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final bloc = FakeBloc.normal();

    bloc.viveBaseStation.idsStream = BehaviorSubject.seeded([]);

    final device = ViveBaseStationDevice(FakeViveBaseStationDevice(0, 0), bloc);

    final valid = await device.isValid();
    expect(valid, true);

    Future<bool>? future;
    await widgetTester.pumpWidget(_buildTestApp((context) {
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

    bloc.viveBaseStation.idsStream = BehaviorSubject.seeded([]);

    final device =
        ViveBaseStationDevice(ViveBaseStationWithIncorrectName(), bloc);

    final valid = await device.isValid();
    expect(valid, true);

    Future<bool>? future;
    await widgetTester.pumpWidget(_buildTestApp((context) {
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

    bloc.viveBaseStation.idsStream = BehaviorSubject.seeded([]);

    final device = ViveBaseStationDevice(FakeViveBaseStationDevice(0, 0), bloc);

    final valid = await device.isValid();
    expect(valid, true);

    Future<bool>? future;
    await widgetTester.pumpWidget(_buildTestApp((context) {
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

    bloc.viveBaseStation.idsStream = BehaviorSubject.seeded([]);

    final device = ViveBaseStationDevice(FakeViveBaseStationDevice(0, 0), bloc);
    bloc.viveBaseStation
        .insertId(device.deviceIdentifier.toString(), 0x12345678);

    device.testingOverwriteMinUpdateInterval = Duration(milliseconds: 10);
    device.setUpdateInterval(Duration(milliseconds: 10));

    final valid = await device.isValid();
    expect(valid, true);

    //First turn off the device
    await device.changeState(LighthousePowerState.SLEEP);
    final currentState = await device.powerStateEnum
        .firstWhere((element) => element == LighthousePowerState.UNKNOWN)
        .timeout(Duration(seconds: 3));

    expect(currentState, LighthousePowerState.UNKNOWN);

    //Now turn it on
    await device.changeState(LighthousePowerState.ON);

    final nextState = await device.powerStateEnum
        .firstWhere((element) => element == LighthousePowerState.UNKNOWN)
        .timeout(Duration(seconds: 3));

    expect(nextState, LighthousePowerState.UNKNOWN);
    expect(device.transactionMutex.isLocked, false,
        reason: "Transaction mutex should have been released");

    LocalPlatform.overridePlatform = null;
  });

  test("Should be able to go from on to sleep", () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final bloc = FakeBloc.normal();

    bloc.viveBaseStation.idsStream = BehaviorSubject.seeded([]);

    final device = ViveBaseStationDevice(FakeViveBaseStationDevice(0, 0), bloc);
    bloc.viveBaseStation
        .insertId(device.deviceIdentifier.toString(), 0x12345678);

    device.testingOverwriteMinUpdateInterval = Duration(milliseconds: 10);
    device.setUpdateInterval(Duration(milliseconds: 10));

    final valid = await device.isValid();
    expect(valid, true);

    //First turn on the device
    await device.changeState(LighthousePowerState.ON);
    final currentState = await device.powerStateEnum
        .firstWhere((element) => element == LighthousePowerState.UNKNOWN)
        .timeout(Duration(seconds: 3));

    expect(currentState, LighthousePowerState.UNKNOWN);

    //Now set it to sleep
    await device.changeState(LighthousePowerState.SLEEP);

    final nextState = await device.powerStateEnum
        .firstWhere((element) => element == LighthousePowerState.UNKNOWN)
        .timeout(Duration(seconds: 3));

    expect(nextState, LighthousePowerState.UNKNOWN);
    expect(device.transactionMutex.isLocked, false,
        reason: "Transaction mutex should have been released");

    LocalPlatform.overridePlatform = null;
  });

  test("Should not go to standby, ViveBaseStationDevice", () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final bloc = FakeBloc.normal();

    bloc.viveBaseStation.idsStream = BehaviorSubject.seeded([]);

    final device = ViveBaseStationDevice(FakeViveBaseStationDevice(0, 0), bloc);
    bloc.viveBaseStation
        .insertId(device.deviceIdentifier.toString(), 0x12345678);

    device.testingOverwriteMinUpdateInterval = Duration(milliseconds: 10);
    device.setUpdateInterval(Duration(milliseconds: 10));

    final valid = await device.isValid();
    expect(valid, true);

    //First turn on the device
    try {
      await device.changeState(LighthousePowerState.STANDBY);
      fail("Should have thrown UnsupportedError");
    } catch (e) {
      expect(e, isA<UnsupportedError>());
    }
    expect(device.transactionMutex.isLocked, false,
        reason: "Transaction mutex should have been released");

    LocalPlatform.overridePlatform = null;
  });

  test("Should not go to staten if id is not set, ViveBaseStationDevice", () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final bloc = FakeBloc.normal();

    bloc.viveBaseStation.idsStream = BehaviorSubject.seeded([]);

    final device = ViveBaseStationDevice(FakeViveBaseStationDevice(0, 0), bloc);

    device.testingOverwriteMinUpdateInterval = Duration(milliseconds: 10);
    device.setUpdateInterval(Duration(milliseconds: 10));

    final valid = await device.isValid();
    expect(valid, true);

    final start = await device.powerState.firstWhere((element) => element != 0xFF).timeout(Duration(seconds: 2));

    await device.changeState(LighthousePowerState.ON);

    final next = await device.powerState.first;
    expect(next, start);
    expect(device.transactionMutex.isLocked, false,
        reason: "Transaction mutex should have been released");

    LocalPlatform.overridePlatform = null;
  });
}

typedef ButtonCallback = void Function(BuildContext context);

MaterialApp _buildTestApp(ButtonCallback onPressed) {
  return MaterialApp(
    home: Material(
      child: Builder(
        builder: (context) {
          return Center(
            child: ElevatedButton(
              child: const Text('X'),
              onPressed: () {
                return onPressed(context);
              },
            ),
          );
        },
      ),
    ),
  );
}
