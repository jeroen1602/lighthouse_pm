import 'dart:typed_data';

import 'package:lighthouse_pm/lighthouseProvider/ble/Guid.dart';
import 'package:test/test.dart';

// Tests for the Guid.dart
void main() {
  const GUID_STRING = "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA";

  test('Should be able to create empty GUID', () {
    final guid = LighthouseGuid.empty();

    final data = guid.getByteData();
    for (var i = 0; i < data.lengthInBytes; i++) {
      expect(data.getUint8(i), 0, reason: 'data at index $i should be "0"');
    }
  });

  test('Should be able to create GUID from string', () {
    final guid = LighthouseGuid.fromString(GUID_STRING);

    expect(guid.toString(), GUID_STRING);
  });

  test('Should only except legal characters', () {
    expect(
        () => LighthouseGuid.fromString(
            'Z${GUID_STRING.substring(1, GUID_STRING.length)}'),
        throwsA(TypeMatcher<FormatException>()));
  });

  // region Guid32
  test('Should be able to create empty GUID32', () {
    final guid = Guid32.empty();

    final data = guid.getByteData();
    for (var i = 0; i < data.lengthInBytes; i++) {
      expect(data.getUint8(i), 0, reason: 'data at index $i should be "0"');
    }
  });

  test('Should be able to convert LighthouseGuid to Guid32', () {
    final originalGuid = LighthouseGuid.fromString(GUID_STRING);
    final guid = Guid32.fromLighthouseGuid(originalGuid);

    expect(originalGuid.getByteData().lengthInBytes, 16,
        reason: 'Original Guid should be 16 bytes long');
    expect(guid.getByteData().getUint32(0, Endian.big),
        originalGuid.getByteData().getUint32(0, Endian.big));
    expect(guid.getByteData().lengthInBytes, 4,
        reason: 'Guid32 should be 4 bytes long');
  });
  // endregion
}
