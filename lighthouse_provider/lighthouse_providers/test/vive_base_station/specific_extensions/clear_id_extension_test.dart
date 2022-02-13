import 'package:lighthouse_provider/lighthouse_provider.dart';
import 'package:lighthouse_providers/vive_base_station_device_provider.dart';
import 'package:lighthouse_test_helper/lighthouse_test_helper.dart';
import 'package:test/test.dart';

void main() {
  test('Should be able to create clear id extension', () {
    final persistence = FakeViveBaseStationBloc();

    final extension = ClearIdExtension(
        persistence: persistence,
        deviceId: LHDeviceIdentifier("12345678901234567"),
        clearId: () {});

    expect(extension.toolTip, 'Clear id');
    expect(extension.updateListAfter, true);
  });

  test('Should be able to clear id with extension', () async {
    final persistence = FakeViveBaseStationBloc();

    var clicked = false;
    persistence.startViveBaseStationIdsStream([
      ViveBaseStationStorage(LHDeviceIdentifier("12345678901234567"), 0xFF)
    ]);

    final extension = ClearIdExtension(
        persistence: persistence,
        deviceId: LHDeviceIdentifier("12345678901234567"),
        clearId: () {
          clicked = true;
        });

    await extension.onTap();
    expect(clicked, true, reason: "Button should have been clicked.");
    final index = persistence.idsStream!.valueOrNull!.indexWhere(
        (final element) => element.deviceId.toString() == "12345678901234567");
    expect(index < 0, true, reason: 'Expect the item to be removed');
  });

  test('Should be able to change enabled', () async {
    final persistence = FakeViveBaseStationBloc();
    persistence.startViveBaseStationIdsStream();

    final extension = ClearIdExtension(
        persistence: persistence,
        deviceId: LHDeviceIdentifier("12345678901234567"),
        clearId: () {});

    expect(await extension.enabledStream.first, false);

    persistence.insertId(LHDeviceIdentifier("12345678901234567"), 0xFFEE);
    expect(await extension.enabledStream.first, true);
  });
}
