import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/lighthouseProvider/helpers/ByteDataExtensions.dart';

void main() {
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
