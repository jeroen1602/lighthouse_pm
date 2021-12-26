import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/lighthouse_back_ends/fake/fake_back_end.dart';
import 'package:lighthouse_pm/lighthouse_provider/device_extensions/on_extension.dart';
import 'package:lighthouse_pm/lighthouse_provider/device_extensions/sleep_extension.dart';
import 'package:lighthouse_pm/lighthouse_provider/device_extensions/standby_extension.dart';
import 'package:lighthouse_pm/lighthouse_provider/device_extensions/state_extension.dart';
import 'package:lighthouse_pm/lighthouse_provider/lighthouse_provider.dart';
import 'package:lighthouse_pm/lighthouse_providers/lighthouse_v2_device_provider.dart';
import 'package:lighthouse_pm/lighthouse_providers/vive_base_station_device_provider.dart';
import 'package:lighthouse_pm/platform_specific/mobile/local_platform.dart';
import 'package:rxdart/rxdart.dart';

import '../../helpers/fake_bloc.dart';

///
/// A state that shouldn't exist
///
class TestBootingStateExtension extends StateExtension {
  TestBootingStateExtension()
      : super(
            toolTip: "Booting",
            icon: Icon(Icons.highlight_off, size: 24),
            changeState: (newState) async {},
            powerStateStream: Stream.value(LighthousePowerState.on),
            toState: LighthousePowerState.booting);
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
            powerStateStream: Stream.value(LighthousePowerState.on),
            toState: LighthousePowerState.unknown);
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
        BehaviorSubject.seeded(LighthousePowerState.standby);

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
        BehaviorSubject.seeded(LighthousePowerState.standby);

    final extension = OnExtension(
        changeState: (newState) async {
          powerState.add(newState);
        },
        powerStateStream: powerState.stream);

    expect(await extension.enabledStream.first, true);
    powerState.add(LighthousePowerState.on);
    expect(await extension.enabledStream.first, false);

    await powerState.close();
  });

  test('Should create sleep state extension', () async {
    BehaviorSubject<LighthousePowerState> powerState =
        BehaviorSubject.seeded(LighthousePowerState.on);

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
        BehaviorSubject.seeded(LighthousePowerState.on);

    final extension = SleepExtension(
        changeState: (newState) async {
          powerState.add(newState);
        },
        powerStateStream: powerState.stream);

    expect(await extension.enabledStream.first, true);
    powerState.add(LighthousePowerState.sleep);
    expect(await extension.enabledStream.first, false);

    await powerState.close();
  });

  test('Should create standby state extension', () async {
    BehaviorSubject<LighthousePowerState> powerState =
        BehaviorSubject.seeded(LighthousePowerState.on);

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
        BehaviorSubject.seeded(LighthousePowerState.on);

    final extension = StandbyExtension(
        changeState: (newState) async {
          powerState.add(newState);
        },
        powerStateStream: powerState.stream);

    expect(await extension.enabledStream.first, true);
    powerState.add(LighthousePowerState.standby);
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
