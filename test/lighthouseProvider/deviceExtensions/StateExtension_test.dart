import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/lighthouseProvider/LighthousePowerState.dart';
import 'package:lighthouse_pm/lighthouseProvider/backEnd/fake/FakeBluetoothDevice.dart';
import 'package:lighthouse_pm/lighthouseProvider/deviceExtensions/OnExtension.dart';
import 'package:lighthouse_pm/lighthouseProvider/deviceExtensions/SleepExtension.dart';
import 'package:lighthouse_pm/lighthouseProvider/deviceExtensions/StandbyExtension.dart';
import 'package:lighthouse_pm/lighthouseProvider/deviceExtensions/StateExtension.dart';
import 'package:lighthouse_pm/lighthouseProvider/deviceProviders/LighthouseV2DeviceProvider.dart';
import 'package:lighthouse_pm/lighthouseProvider/deviceProviders/ViveBaseStationDeviceProvider.dart';
import 'package:lighthouse_pm/platformSpecific/io/LocalPlatform.dart';
import 'package:rxdart/rxdart.dart';

import '../../helpers/FakeBloc.dart';

///
/// A state that shouldn't exist
///
class TestBootingStateExtension extends StateExtension {
  TestBootingStateExtension()
      : super(
            toolTip: "Booting",
            icon: Icon(Icons.highlight_off, size: 24),
            changeState: (newState) async {},
            powerStateStream: Stream.value(LighthousePowerState.ON),
            toState: LighthousePowerState.BOOTING);
}

///
/// A state that shouldn't exist
///
class TestUnknownStateExtension extends StateExtension {
  TestUnknownStateExtension()
      : super(
            toolTip: "Unknown",
            icon: Icon(Icons.highlight_off, size: 24),
            changeState: (newState) async {},
            powerStateStream: Stream.value(LighthousePowerState.ON),
            toState: LighthousePowerState.UNKNOWN);
}

void main() {
  test('Should not create booting state extension', () {
    expect(() => TestBootingStateExtension(),
        throwsA(TypeMatcher<AssertionError>()));
  });

  test('Should not create unknown state extension', () {
    expect(() => TestUnknownStateExtension(),
        throwsA(TypeMatcher<AssertionError>()));
  });

  test('Should create on state extension', () async {
    BehaviorSubject<LighthousePowerState> powerState =
        BehaviorSubject.seeded(LighthousePowerState.STANDBY);

    final extension = OnExtension(
        changeState: (newState) async {
          powerState.add(newState);
        },
        powerStateStream: powerState.stream);

    expect(extension.icon, TypeMatcher<Icon>());
    expect(extension.toolTip, "On");
    expect(extension.updateListAfter, false);

    await powerState.close();
  });

  test('Should change enabled for on state extension', () async {
    BehaviorSubject<LighthousePowerState> powerState =
        BehaviorSubject.seeded(LighthousePowerState.STANDBY);

    final extension = OnExtension(
        changeState: (newState) async {
          powerState.add(newState);
        },
        powerStateStream: powerState.stream);

    expect(await extension.enabledStream.first, true);
    powerState.add(LighthousePowerState.ON);
    expect(await extension.enabledStream.first, false);

    await powerState.close();
  });

  test('Should create sleep state extension', () async {
    BehaviorSubject<LighthousePowerState> powerState =
        BehaviorSubject.seeded(LighthousePowerState.ON);

    final extension = SleepExtension(
        changeState: (newState) async {
          powerState.add(newState);
        },
        powerStateStream: powerState.stream);

    expect(extension.icon, TypeMatcher<Icon>());
    expect(extension.toolTip, "Sleep");
    expect(extension.updateListAfter, false);

    await powerState.close();
  });

  test('Should change enabled for sleep state extension', () async {
    BehaviorSubject<LighthousePowerState> powerState =
        BehaviorSubject.seeded(LighthousePowerState.ON);

    final extension = SleepExtension(
        changeState: (newState) async {
          powerState.add(newState);
        },
        powerStateStream: powerState.stream);

    expect(await extension.enabledStream.first, true);
    powerState.add(LighthousePowerState.SLEEP);
    expect(await extension.enabledStream.first, false);

    await powerState.close();
  });

  test('Should create standby state extension', () async {
    BehaviorSubject<LighthousePowerState> powerState =
        BehaviorSubject.seeded(LighthousePowerState.ON);

    final extension = StandbyExtension(
        changeState: (newState) async {
          powerState.add(newState);
        },
        powerStateStream: powerState.stream);

    expect(extension.icon, TypeMatcher<Icon>());
    expect(extension.toolTip, "Standby");
    expect(extension.updateListAfter, false);

    await powerState.close();
  });

  test('Should change enabled for standby state extension', () async {
    BehaviorSubject<LighthousePowerState> powerState =
        BehaviorSubject.seeded(LighthousePowerState.ON);

    final extension = StandbyExtension(
        changeState: (newState) async {
          powerState.add(newState);
        },
        powerStateStream: powerState.stream);

    expect(await extension.enabledStream.first, true);
    powerState.add(LighthousePowerState.STANDBY);
    expect(await extension.enabledStream.first, false);

    await powerState.close();
  });

  test('Some devices should have standby extension', () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final bloc = FakeBloc.normal();

    final v2Provider = LighthouseV2DeviceProvider.instance;
    v2Provider.setBloc(bloc);
    final v2Device = await v2Provider.getDevice(FakeLighthouseV2Device(0, 0));

    expect(v2Device, isNotNull);
    expect(v2Device!.deviceIdentifier.toString(), "00:00:00:00:00:00");

    final viveProvider = ViveBaseStationDeviceProvider.instance;
    viveProvider.setBloc(bloc);
    final viveDevice =
        await viveProvider.getDevice(FakeViveBaseStationDevice(1, 1));

    expect(viveDevice, isNotNull);
    expect(viveDevice!.deviceIdentifier.toString(), "00:00:00:00:00:01");

    expect(v2Device.hasStandbyExtension, true,
        reason: "V2 lighthouse should have standby extension");
    expect(viveDevice.hasStandbyExtension, false,
        reason: "Vive base station should not have standby extension");

    LocalPlatform.overridePlatform = null;
  });
}
