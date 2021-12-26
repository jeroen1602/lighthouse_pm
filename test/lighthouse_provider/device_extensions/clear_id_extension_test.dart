import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/data/database.dart';
import 'package:lighthouse_pm/lighthouse_providers/vive_base_station_device_provider.dart';
import 'package:rxdart/rxdart.dart';

import '../../helpers/fake_bloc.dart';

void main() {
  test('Should be able to create clear id extension', () {
    final fakeBloc = FakeBloc.normal();

    final extension = ClearIdExtension(
        viveDao: fakeBloc.viveBaseStation,
        deviceId: "12345678901234567",
        clearId: () {});

    expect(extension.icon, TypeMatcher<Text>());
    expect(extension.toolTip, 'Clear id');
    expect(extension.updateListAfter, true);
  });

  test('Should be able to clear id with extension', () async {
    final fakeBloc = FakeBloc.normal();

    var clicked = false;
    fakeBloc.viveBaseStation.startViveBaseStationIdsStream([
      ViveBaseStationId(deviceId: "12345678901234567", baseStationId: 0xFF)
    ]);

    final extension = ClearIdExtension(
        viveDao: fakeBloc.viveBaseStation,
        deviceId: "12345678901234567",
        clearId: () {
          clicked = true;
        });

    await extension.onTap();
    expect(clicked, true, reason: "Button should have been clicked.");
    final index = fakeBloc.viveBaseStation.idsStream!.value!
        .indexWhere((element) => element.deviceId == "12345678901234567");
    expect(index < 0, true, reason: 'Expect the item to be removed');
  });

  test('Should be able to change enabled', () async {
    final fakeBloc = FakeBloc.normal();

    final extension = ClearIdExtension(
        viveDao: fakeBloc.viveBaseStation,
        deviceId: "12345678901234567",
        clearId: () {});

    expect(await extension.enabledStream.first, false);

    fakeBloc.viveBaseStation.insertId("12345678901234567", 0xFFEE);
    expect(await extension.enabledStream.first, true);
  });
}
