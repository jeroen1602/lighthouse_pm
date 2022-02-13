import 'package:fake_back_end/fake_back_end.dart';
import 'package:lighthouse_provider/lighthouse_provider.dart';
import 'package:lighthouse_test_helper/lighthouse_test_helper.dart';
import 'package:shared_platform/shared_platform_io.dart';
import 'package:test/test.dart';

void main() {
  setUp(() {
    SharedPlatform.overridePlatform = PlatformOverride.android;
  });

  tearDown(() {
    SharedPlatform.overridePlatform = null;
  });

  test('Should set nickname', () {
    final device = FakeHighLevelDevice(FakeLighthouseV2Device(0, 0));

    expect(device.nicknameInternal, isNull);

    device.nickname = "Test Nickname";

    expect(device.nicknameInternal, "Test Nickname");
  });

  test('Update interval should not be less than the minimum', () {
    final device = FakeHighLevelDevice(FakeLighthouseV2Device(0, 0));

    device.setUpdateInterval(Duration(milliseconds: 1000));
    expect(device.getUpdateInterval(), Duration(milliseconds: 1000));

    device.setUpdateInterval(
        device.getMinUpdateInterval() - Duration(milliseconds: 50));
    expect(device.getUpdateInterval(), Duration(milliseconds: 1000));

    device.setUpdateInterval(
        device.getMinUpdateInterval() + Duration(milliseconds: 50));
    expect(device.getUpdateInterval(), Duration(milliseconds: 1050));
  });

  test('Default showExtraInfoWidget should just return', () async {
    final device = FakeHighLevelDevice(FakeLighthouseV2Device(0, 0));

    final result = await device.requestExtraInfo();

    expect(result, isTrue);
  });

  test('Should not change state to illegal states', () async {
    final device = FakeHighLevelDevice(FakeLighthouseV2Device(0, 0));

    await device.changeState(LighthousePowerState.unknown);
    expect(device.changeStateCalled, 0,
        reason: "Should not have called internalChangeState");

    await device.changeState(LighthousePowerState.booting);
    expect(device.changeStateCalled, 0,
        reason: "Should not have called internalChangeState");
  });

  test('Should release mutex even on error', () async {
    final device = FakeHighLevelDevice(FakeLighthouseV2Device(0, 0));

    device.errorOnInternalChangeState = true;

    try {
      await device.changeState(LighthousePowerState.on);
      fail("Change state did not throw!");
    } catch (e) {
      expect(e, isA<StateError>(),
          reason: "Test device should error on stateChange");
    }
    expect(device.changeStateCalled, 1,
        reason: "Change state should have been called");
    expect(device.transactionMutex.isLocked, false,
        reason: "Mutex should have been released");
  });

  test('Should disconnect if could not get current state', () async {
    final device = FakeHighLevelDevice(FakeLighthouseV2Device(0, 0));
    device.openConnection = true;

    try {
      await device.getCurrentState();
      fail('Should throw an error');
    } catch (e) {
      expect(e, isA<UnimplementedError>());
    }
    final state = await device.powerState.first;
    expect(state, 0xFF);

    await Future.delayed(Duration(milliseconds: 100));

    expect(device.disconnectCalled, 1,
        reason: 'Should have called disconnect.');
  });

  test('Should clean up if there is no open connection', () async {
    final device = FakeHighLevelDevice(FakeLighthouseV2Device(0, 0));
    device.openConnection = false;

    try {
      await device.getCurrentState();
      fail('Should throw an error');
    } catch (e) {
      expect(e, isA<UnimplementedError>());
    }
    final state = await device.powerState.first;
    expect(state, 0xFF);

    await Future.delayed(Duration(milliseconds: 100));

    expect(device.disconnectCalled, 1,
        reason: 'Should have called disconnect.');
  });
}
