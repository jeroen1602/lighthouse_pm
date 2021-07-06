import 'package:flutter_test/flutter_test.dart';

import '../../ble/TestCharacteristic.dart';

void main() {
  test('Should be able to read data from FakeReadOnlyCharacteristic', () async {
    final characteristic = TestReadCharacteristic([0xFF, 0xEE]);

    expect(await characteristic.read(), [0xFF, 0xEE]);
  });

  test('Should throw error when trying to write', () async {
    final characteristic = TestReadCharacteristic([0xFF, 0xEE]);

    expect(() async {
      characteristic.write([0xEE, 0xFF]);
    }, throwsA(TypeMatcher<UnimplementedError>()));
  });
}
