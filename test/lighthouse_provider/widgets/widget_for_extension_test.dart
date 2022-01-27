import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/bloc/vive_base_station_bloc.dart';
import 'package:lighthouse_pm/lighthouse_provider/widgets/widget_for_extension.dart';
import 'package:lighthouse_provider/device_extensions/device_extension.dart';
import 'package:lighthouse_provider/device_extensions/shortcut_extension.dart';
import 'package:lighthouse_provider/lighthouse_provider.dart';
import 'package:lighthouse_providers/lighthouse_v2_device_provider.dart';
import 'package:lighthouse_providers/vive_base_station_device_provider.dart';

import '../../helpers/fake_bloc.dart';

class DefaultEnabledDeviceExtension extends DeviceExtension {
  DefaultEnabledDeviceExtension()
      : super(toolTip: 'Default enabled', onTap: () async {});
}

void main() {
  test('Device extension should return Text widget by default', () {
    final extension = DefaultEnabledDeviceExtension();

    final widget = getWidgetFromDeviceExtension(extension);

    expect(widget, isA<Text>());
  });

  test('Should get correct widget for shortcut type', () {
    final persistence = ViveBaseStationBloc(FakeBloc.normal());

    final lut = {
      ShortcutExtension: isA<Icon>(),
      OnExtension: isA<Icon>(),
      SleepExtension: isA<Icon>(),
      StandbyExtension: isA<Icon>(),
      IdentifyDeviceExtension: isA<SvgPicture>(),
      ClearIdExtension: isA<Text>()
    };

    final extensions = [
      ShortcutExtension("00:00:00:00:00:00", () {
        return "DEVICE_NAME";
      }, (final mac, final name) {}),
      OnExtension(
          changeState: (final newState) async {},
          powerStateStream: () => const Stream.empty()),
      SleepExtension(
          changeState: (final newState) async {},
          powerStateStream: () => const Stream.empty()),
      StandbyExtension(
          changeState: (final newState) async {},
          powerStateStream: () => const Stream.empty()),
      IdentifyDeviceExtension(onTap: () async {}),
      ClearIdExtension(
          persistence: persistence,
          deviceId: const LHDeviceIdentifier("12345678901234567"),
          clearId: () {})
    ];

    for (final extension in extensions) {
      final widget = getWidgetFromDeviceExtension(extension);

      expect(lut[extension.runtimeType], isNotNull);
      final type = lut[extension.runtimeType];
      expect(widget, type);
    }
  });
}
