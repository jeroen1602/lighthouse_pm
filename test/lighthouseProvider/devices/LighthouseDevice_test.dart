import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/lighthouseProvider/LighthousePowerState.dart';
import 'package:lighthouse_pm/lighthouseProvider/backEnd/fake/FakeBluetoothDevice.dart';
import 'package:lighthouse_pm/platformSpecific/mobile/LocalPlatform.dart';

import '../../helpers/FakeHighLevelDevice.dart';
import '../../helpers/WidgetHelpers.dart';

void main() {
  test('Should set nickname', () {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final device = FakeHighLevelDevice(FakeLighthouseV2Device(0, 0));

    expect(device.nicknameInternal, isNull);

    device.nickname = "Test Nickname";

    expect(device.nicknameInternal, "Test Nickname");

    LocalPlatform.overridePlatform = null;
  });

  test('Update interval should not be less than the minimum', () {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final device = FakeHighLevelDevice(FakeLighthouseV2Device(0, 0));

    device.setUpdateInterval(Duration(milliseconds: 1000));
    expect(device.getUpdateInterval(), Duration(milliseconds: 1000));

    device.setUpdateInterval(
        device.getMinUpdateInterval() - Duration(milliseconds: 50));
    expect(device.getUpdateInterval(), Duration(milliseconds: 1000));

    device.setUpdateInterval(
        device.getMinUpdateInterval() + Duration(milliseconds: 50));
    expect(device.getUpdateInterval(), Duration(milliseconds: 1050));

    LocalPlatform.overridePlatform = null;
  });

  testWidgets('Default showExtraInfoWidget should just return',
      (widgetTester) async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final device = FakeHighLevelDevice(FakeLighthouseV2Device(0, 0));

    final progressIndicator = find.byWidget(CircularProgressIndicator());
    final doneText = find.text("true");
    final incorrectText = find.text("false");

    await widgetTester.pumpWidget(buildTestApp(
      (context) {
        return FutureBuilder(
            future: device.showExtraInfoWidget(context),
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              }
              if (snapshot.hasData) {
                return Text(snapshot.requireData.toString());
              }
              return CircularProgressIndicator();
            });
      },
    ));

    // Wait for the progress indicator to stop
    await widgetTester.pumpAndSettle();

    expect(progressIndicator, findsNothing);
    expect(doneText, findsOneWidget);
    expect(incorrectText, findsNothing);

    LocalPlatform.overridePlatform = null;
  });

  test('Should not change state to illegal states', () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final device = FakeHighLevelDevice(FakeLighthouseV2Device(0, 0));

    await device.changeState(LighthousePowerState.UNKNOWN);
    expect(device.changeStateCalled, 0,
        reason: "Should not have called internalChangeState");

    await device.changeState(LighthousePowerState.BOOTING);
    expect(device.changeStateCalled, 0,
        reason: "Should not have called internalChangeState");

    LocalPlatform.overridePlatform = null;
  });

  test('Should release mutex even on error', () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final device = FakeHighLevelDevice(FakeLighthouseV2Device(0, 0));

    device.errorOnInternalChangeState = true;

    try {
      await device.changeState(LighthousePowerState.ON);
      fail("Change state did not throw!");
    } catch (e) {
      expect(e, isInstanceOf<StateError>(),
          reason: "Test device should error on stateChange");
    }
    expect(device.changeStateCalled, 1,
        reason: "Change state should have been called");
    expect(device.transactionMutex.isLocked, false,
        reason: "Mutex should have been released");

    LocalPlatform.overridePlatform = null;
  });

  test('Should disconnect if could not get current state', () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final device = FakeHighLevelDevice(FakeLighthouseV2Device(0, 0));
    device.openConnection = true;

    try {
      await device.getCurrentState();
      fail('Should throw an error');
    } catch (e) {
      expect(e, TypeMatcher<UnimplementedError>());
    }
    final state = await device.powerState.first;
    expect(state, 0xFF);

    await Future.delayed(Duration(milliseconds: 100));

    expect(device.disconnectCalled, 1,
        reason: 'Should have called disconnect.');

    LocalPlatform.overridePlatform = null;
  });

  test('Should clean up if there is no open connection', () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final device = FakeHighLevelDevice(FakeLighthouseV2Device(0, 0));
    device.openConnection = false;

    try {
      await device.getCurrentState();
      fail('Should throw an error');
    } catch (e) {
      expect(e, TypeMatcher<UnimplementedError>());
    }
    final state = await device.powerState.first;
    expect(state, 0xFF);

    await Future.delayed(Duration(milliseconds: 100));

    expect(device.disconnectCalled, 1,
        reason: 'Should have called disconnect.');

    LocalPlatform.overridePlatform = null;
  });
}
