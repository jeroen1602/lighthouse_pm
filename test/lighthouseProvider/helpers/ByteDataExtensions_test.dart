import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/lighthouseProvider/helpers/ByteDataExtensions.dart';

void main() {
  test('Should create empty ReadOnlyByteDate', () {
    final readOnly = ReadOnlyByteData(4);

    expect(readOnly.lengthInBytes, 4);
    expect(readOnly.getUint8(0), 0x00);
    expect(readOnly.getUint8(1), 0x00);
    expect(readOnly.getUint8(2), 0x00);
    expect(readOnly.getUint8(3), 0x00);
  });

  test('Should not be able to write to ReadOnlyByteDate', () {
    final original = ByteData(1);
    original.setUint8(0, 0xAB);

    final readOnly = ReadOnlyByteData.fromByteData(original);

    expect(readOnly.getUint8(0), 0xAB,
        reason: "Should still hold the same data");
    expect(readOnly.lengthInBytes, original.lengthInBytes);
    expect(readOnly.offsetInBytes, original.offsetInBytes);
    expect(readOnly.elementSizeInBytes, original.elementSizeInBytes);

    // No write functions should work
    expect(() => readOnly.setUint8(0, 0xCC),
        throwsA(TypeMatcher<UnsupportedError>()),
        reason: "Should not be able to write a uInt8");
    expect(() => readOnly.setUint16(0, 0xCC),
        throwsA(TypeMatcher<UnsupportedError>()),
        reason: "Should not be able to write a uInt16");
    expect(() => readOnly.setUint32(0, 0xCC),
        throwsA(TypeMatcher<UnsupportedError>()),
        reason: "Should not be able to write a uInt32");
    expect(() => readOnly.setUint64(0, 0xCC),
        throwsA(TypeMatcher<UnsupportedError>()),
        reason: "Should not be able to write a uInt64");
    expect(() => readOnly.setInt8(0, 0xCC),
        throwsA(TypeMatcher<UnsupportedError>()),
        reason: "Should not be able to write an int8");
    expect(() => readOnly.setInt16(0, 0xCC),
        throwsA(TypeMatcher<UnsupportedError>()),
        reason: "Should not be able to write an int16");
    expect(() => readOnly.setInt32(0, 0xCC),
        throwsA(TypeMatcher<UnsupportedError>()),
        reason: "Should not be able to write an int32");
    expect(() => readOnly.setInt64(0, 0xCC),
        throwsA(TypeMatcher<UnsupportedError>()),
        reason: "Should not be able to write an int64");

    expect(() => readOnly.setFloat32(0, 100.0),
        throwsA(TypeMatcher<UnsupportedError>()),
        reason: "Should not be able to write an float32");
    expect(() => readOnly.setFloat64(0, 100.0),
        throwsA(TypeMatcher<UnsupportedError>()),
        reason: "Should not be able to write an float64");
  });

  test('Should be able to read from ReadOnlyByteDate', () {
    final original = ByteData(64);
    original.setUint64(0, 0x1122334455667788, Endian.big);

    final readOnly = ReadOnlyByteData.fromByteData(original);

    expect(readOnly.lengthInBytes, original.lengthInBytes);
    expect(readOnly.offsetInBytes, original.offsetInBytes);
    expect(readOnly.elementSizeInBytes, original.elementSizeInBytes);
    expect(readOnly.buffer.lengthInBytes, original.buffer.lengthInBytes);

    expect(readOnly.getUint8(0), 0x11,
        reason: "Should be able to read a uInt8");
    expect(readOnly.getUint16(0), 0x1122,
        reason: "Should be able to read a uInt16");
    expect(readOnly.getUint32(0), 0x11223344,
        reason: "Should be able to read a uInt32");
    expect(readOnly.getUint64(0), 0x1122334455667788,
        reason: "Should be able to read a uInt64");

    expect(readOnly.getInt8(0), 0x11, reason: "Should be able to read an int8");
    expect(readOnly.getInt16(0), 0x1122,
        reason: "Should be able to read an int16");
    expect(readOnly.getInt32(0), 0x11223344,
        reason: "Should be able to read an int32");
    expect(readOnly.getInt64(0), 0x1122334455667788,
        reason: "Should be able to read an int64");

    original.setFloat32(0, 100.0);
    expect(readOnly.getFloat32(0), 100.0,
        reason: "Should be able to read float32");
    original.setFloat64(0, 14587e32);
    expect(readOnly.getFloat64(0), 14587e32,
        reason: "Should be able to read float64");
  });

  test('Should convert to uInt8 list', () {
    final ByteData byteData = ByteData(4);
    byteData.setUint32(0, 0xAABBCCDD);

    expect(byteData.toUint8List(), [0xAA, 0xBB, 0xCC, 0xDD]);
  });

  test('Should convert to int8 list', () {
    final ByteData byteData = ByteData(4);
    byteData.setInt32(0, -0xAABBCCDD);

    expect(byteData.toInt8List(), [0x55, 0x44, 0x33, 0x23]);
  });

  test('Should generate hash code', () {
    final ByteData byteData = ByteData(4);
    byteData.setInt32(0, -0xAABBCCDD);

    expect(byteData.calculateHashCode(), 0x1BA2655F);

    byteData.setUint32(0, 0xAABBCCDD);
    expect(byteData.calculateHashCode(), 0x38280336);
  });
}
