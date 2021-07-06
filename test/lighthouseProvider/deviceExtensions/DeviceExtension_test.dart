import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/lighthouseProvider/LighthousePowerState.dart';
import 'package:lighthouse_pm/lighthouseProvider/deviceExtensions/ClearIdExtension.dart';
import 'package:lighthouse_pm/lighthouseProvider/deviceExtensions/DeviceExtension.dart';
import 'package:lighthouse_pm/lighthouseProvider/deviceExtensions/IdentifyDeviceExtension.dart';
import 'package:lighthouse_pm/lighthouseProvider/deviceExtensions/OnExtension.dart';
import 'package:lighthouse_pm/lighthouseProvider/deviceExtensions/ShortcutExtension.dart';
import 'package:lighthouse_pm/lighthouseProvider/deviceExtensions/SleepExtension.dart';
import 'package:lighthouse_pm/lighthouseProvider/deviceExtensions/StandbyExtension.dart';

import '../../helpers/FakeBloc.dart';

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
    final fakeBloc = FakeBloc.normal();

    final extensions = [
      ClearIdExtension(
          viveDao: fakeBloc.viveBaseStation,
          deviceId: "12345678901234567",
          clearId: () {}),
      ShortcutExtension("00:00:00:00:00:00", () => "Device 1"),
      OnExtension(
          changeState: (newState) async {},
          powerStateStream: Stream.value(LighthousePowerState.ON)),
      SleepExtension(
          changeState: (newState) async {},
          powerStateStream: Stream.value(LighthousePowerState.SLEEP)),
      StandbyExtension(
          changeState: (newState) async {},
          powerStateStream: Stream.value(LighthousePowerState.STANDBY)),
      IdentifyDeviceExtension(onTap: () async {}),
    ];

    final extensions2 = [
      ClearIdExtension(
          viveDao: fakeBloc.viveBaseStation,
          deviceId: "12345678901234568",
          clearId: () {}),
      ShortcutExtension("00:00:00:00:00:01", () => "Device 2"),
      OnExtension(
          changeState: (newState) async {},
          powerStateStream: Stream.value(LighthousePowerState.ON)),
      SleepExtension(
          changeState: (newState) async {},
          powerStateStream: Stream.value(LighthousePowerState.SLEEP)),
      StandbyExtension(
          changeState: (newState) async {},
          powerStateStream: Stream.value(LighthousePowerState.STANDBY)),
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
