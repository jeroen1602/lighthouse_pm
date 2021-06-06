import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/lighthouseProvider/backEnd/fake/FakeBluetoothDevice.dart';
import 'package:lighthouse_pm/lighthouseProvider/ble/Guid.dart';

class TestReadCharacteristic extends FakeReadOnlyCharacteristic {
  TestReadCharacteristic(List<int> data)
      : super(data,
            LighthouseGuid.fromString('FFFFFFFF-0000-0000-0000-000000000000'));
}

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
