import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/bloc/vive_base_station_bloc.dart';
import 'package:lighthouse_pm/lighthouse_provider/device_extensions/device_extension.dart';
import 'package:lighthouse_pm/lighthouse_provider/device_extensions/shortcut_extension.dart';
import 'package:lighthouse_pm/lighthouse_provider/lighthouse_provider.dart';
import 'package:lighthouse_pm/lighthouse_providers/lighthouse_v2_device_provider.dart';
import 'package:lighthouse_pm/lighthouse_providers/vive_base_station_device_provider.dart';

import '../../helpers/fake_bloc.dart';

class DefaultEnabledDeviceExtension extends DeviceExtension {
  DefaultEnabledDeviceExtension()
      : super(
            toolTip: 'Default enabled',
            icon: Text('Default enabled'),
            onTap: () async {});
}

void main() {
  test('Device extension should use default enabled stream', () async {
    final extension = DefaultEnabledDeviceExtension();

    expect(await extension.enabledStream.first, true);
    expect(
        await extension.enabledStream.last.timeout(Duration(seconds: 5)), true);
  });

  test('Device extension equality should work', () {
    final persistence = ViveBaseStationBloc(FakeBloc.normal());

    final extensions = [
      ClearIdExtension(
          persistence: persistence,
          deviceId: LHDeviceIdentifier("12345678901234567"),
          clearId: () {}),
      ShortcutExtension("00:00:00:00:00:00", () => "Device 1"),
      OnExtension(
          changeState: (newState) async {},
          powerStateStream: () => Stream.value(LighthousePowerState.on)),
      SleepExtension(
          changeState: (newState) async {},
          powerStateStream: () => Stream.value(LighthousePowerState.sleep)),
      StandbyExtension(
          changeState: (newState) async {},
          powerStateStream: () => Stream.value(LighthousePowerState.standby)),
      IdentifyDeviceExtension(onTap: () async {}),
    ];

    final extensions2 = [
      ClearIdExtension(
          persistence: persistence,
          deviceId: LHDeviceIdentifier("12345678901234568"),
          clearId: () {}),
      ShortcutExtension("00:00:00:00:00:01", () => "Device 2"),
      OnExtension(
          changeState: (newState) async {},
          powerStateStream: () => Stream.value(LighthousePowerState.on)),
      SleepExtension(
          changeState: (newState) async {},
          powerStateStream: () => Stream.value(LighthousePowerState.sleep)),
      StandbyExtension(
          changeState: (newState) async {},
          powerStateStream: () => Stream.value(LighthousePowerState.standby)),
      IdentifyDeviceExtension(onTap: () async {}),
    ];

    for (int i = 0; i < extensions.length; i++) {
      for (int j = 0; j < extensions2.length; j++) {
        if (i == j) {
          expect(extensions[i] == extensions2[j], true,
              reason: "Same extension should equal to the same thing");
        } else {
          expect(extensions[i] == extensions2[j], false,
              reason: "Different extension types should be different");
        }
      }
    }
  });
}
