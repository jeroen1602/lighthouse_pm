import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/lighthouse_provider/lighthouse_provider.dart';

void main() {
  test('Should get the correct item from id', () {
    final lut = LighthousePowerState.values;

    for (var i = 0; i < lut.length; i++) {
      expect(LighthousePowerState.fromId(i), lut[i],
          reason: "Should get state from id: $i");
    }

    expect(() {
      LighthousePowerState.fromId(-1);
    }, throwsA(isA<ArgumentError>()),
        reason: "Should throw an error for negative ids");

    expect(() {
      LighthousePowerState.fromId(lut.length);
    }, throwsA(isA<ArgumentError>()),
        reason: "Should throw an error for ids that are too big");
  });
}
