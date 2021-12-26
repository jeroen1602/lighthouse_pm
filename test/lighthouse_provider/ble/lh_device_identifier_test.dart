import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/lighthouse_provider/ble/device_identifier.dart';

void main() {
  test('Same device identifiers should match', () {
    final pair1_1 = LHDeviceIdentifier("SOME_DEVICE");
    final pair1_2 = LHDeviceIdentifier("SOME_DEVICE");

    final pair2_1 = LHDeviceIdentifier("some_other_device");
    final pair2_2 = LHDeviceIdentifier("some_other_device");

    final pair3_1 = LHDeviceIdentifier("yetAnotherDevice");
    final pair3_2 = LHDeviceIdentifier("yetAnotherDevice");

    expect(pair1_2 == pair1_1, true);
    expect(pair2_2 == pair2_1, true);
    expect(pair3_2 == pair3_1, true);
  });

  test('Capitalization should matter', () {
    final pair1_1 = LHDeviceIdentifier("SOME_DEVICE");
    final pair1_2 = LHDeviceIdentifier("SOME_dEVICE");

    final pair2_1 = LHDeviceIdentifier("some_other_device");
    final pair2_2 = LHDeviceIdentifier("some_Other_device");

    final pair3_1 = LHDeviceIdentifier("yetAnotherDevice");
    final pair3_2 = LHDeviceIdentifier("yetanotherDevice");

    final pair4_1 = LHDeviceIdentifier("a");
    final pair4_2 = LHDeviceIdentifier("A");

    expect(pair1_2 == pair1_1, false);
    expect(pair2_2 == pair2_1, false);
    expect(pair3_2 == pair3_1, false);
    expect(pair4_2 == pair4_1, false);
  });
}
