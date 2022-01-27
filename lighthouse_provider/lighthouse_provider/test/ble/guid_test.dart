import 'dart:typed_data';

import 'package:lighthouse_provider/lighthouse_provider.dart';
import 'package:test/test.dart';

// Tests for the guid.dart
void main() {
  const guidString = "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA";

  test('Should be able to create empty GUID', () {
    final guid = LighthouseGuid.empty();

    final data = guid.getByteData();
    for (var i = 0; i < data.lengthInBytes; i++) {
      expect(data.getUint8(i), 0, reason: 'data at index $i should be "0"');
    }
  });

  test('Should be able to create GUID from string', () {
    final guid = LighthouseGuid.fromString(guidString);

    expect(guid.toString(), guidString);
  });

  test('Should only except legal characters', () {
    expect(
        () => LighthouseGuid.fromString(
            'Z${guidString.substring(1, guidString.length)}'),
        throwsA(isA<FormatException>()));
  });

  test('Should only expect legal string length', () {
    expect(() {
      LighthouseGuid.fromString('${guidString}00');
    }, throwsA(isA<FormatException>()));
  });

  // region Guid32
  test('Should be able to create empty GUID32', () {
    final guid = Guid32.empty();

    final data = guid.getByteData();
    for (var i = 0; i < data.lengthInBytes; i++) {
      expect(data.getUint8(i), 0, reason: 'data at index $i should be "0"');
    }
  });

  test('Should create from int32', () {
    final guid = Guid32.fromInt32(0xAABBCCDD);

    expect(guid.isEqualToInt32(0xAABBCCDD), true);
  });

  test('Should be able to compare GUID32', () {
    final pair1_1 = Guid32.fromInt32(0xAAAAAAAA);
    final pair1_2 =
        Guid32.fromLighthouseGuid(LighthouseGuid.fromString(guidString));

    expect(pair1_1 == pair1_2, true);

    final pair2_1 = Guid32.fromInt32(0xAAAAAAAB);
    final pair2_2 =
        Guid32.fromLighthouseGuid(LighthouseGuid.fromString(guidString));

    expect(pair2_1 == pair2_2, false);
  });

  test('Should be able to compare GUID32 to LighthouseGuid', () {
    final pair1_1 = Guid32.fromInt32(0xAAAAAAAA);
    final pair1_2 = LighthouseGuid.fromString(guidString);

    expect(pair1_1.isEqualToGuid(pair1_2), true);

    final pair2_1 = Guid32.fromInt32(0xAAAAAAAB);
    final pair2_2 = LighthouseGuid.fromString(guidString);

    expect(pair2_1.isEqualToGuid(pair2_2), false);
  });

  test('Should be able to convert LighthouseGuid to Guid32', () {
    final originalGuid = LighthouseGuid.fromString(guidString);
    final guid = Guid32.fromLighthouseGuid(originalGuid);

    expect(originalGuid.getByteData().lengthInBytes, 16,
        reason: 'Original Guid should be 16 bytes long');
    expect(guid.getByteData().getUint32(0, Endian.big),
        originalGuid.getByteData().getUint32(0, Endian.big));
    expect(guid.getByteData().lengthInBytes, 4,
        reason: 'Guid32 should be 4 bytes long');
  });

  test('Should convert GUID32 to string', () {
    final first = Guid32.fromInt32(0xFF);
    expect(first.toString(), "000000FF");

    final second = Guid32.fromInt32(0xAABBCCDD);
    expect(second.toString(), "AABBCCDD");
  });
  // endregion
}
