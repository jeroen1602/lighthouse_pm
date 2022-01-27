import 'package:fake_back_end/fake_back_end.dart';
import 'package:lighthouse_provider/lighthouse_provider.dart';
import 'package:test/test.dart';

import '../helpers/device_helpers.dart';

void main() {
  test('ble device metadata should be able to convert string', () async {
    final device = await createValidLighthouseV2Device(0, 0);

    final characteristics = [
      DefaultCharacteristics(0x000000FF, String, "element")
    ];

    final characteristic = Characteristic();

    final Map<String, String?> results = {};

    await device.checkCharacteristicForDefaultValue(
        characteristics, characteristic, results);

    expect(results.isNotEmpty, isTrue,
        reason: "Should have added extra data to the map");
    expect(results.containsKey("element"), isTrue,
        reason: "Should have added extra data to the map");
    expect(results["element"], isNotNull, reason: "Element should not be null");
    expect(results["element"]!, "A", reason: "Element should match A");
  });

  test('ble device metadata should be able to convert int', () async {
    final device = await createValidLighthouseV2Device(0, 0);

    final characteristics = [
      DefaultCharacteristics(0x000000FF, int, "element")
    ];

    final characteristic = Characteristic();

    final Map<String, String?> results = {};

    await device.checkCharacteristicForDefaultValue(
        characteristics, characteristic, results);

    expect(results.isNotEmpty, isTrue,
        reason: "Should have added extra data to the map");
    expect(results.containsKey("element"), isTrue,
        reason: "Should have added extra data to the map");
    expect(results["element"], isNotNull, reason: "Element should not be null");
    expect(results["element"]!, (0x41).toRadixString(10),
        reason: "Element should match 0x41");
  });

  test('ble device metadata should not be able to convert unsupported type',
      () async {
    final device = await createValidLighthouseV2Device(0, 0);

    final characteristics = [
      DefaultCharacteristics(0x000000FF, double, "element")
    ];

    final characteristic = Characteristic();

    final Map<String, String?> results = {};

    await device.checkCharacteristicForDefaultValue(
        characteristics, characteristic, results);

    expect(results.isEmpty, isTrue,
        reason: "Should not have added extra data to the map");
  });
}

class Characteristic extends FakeReadOnlyCharacteristic {
  Characteristic() : super([0x41], Guid32.fromInt32(0x000000FF));
}
