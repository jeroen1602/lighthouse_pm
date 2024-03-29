import 'dart:typed_data';

import 'package:lighthouse_back_end/lighthouse_back_end.dart';
import 'package:test/test.dart';

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

    expect(byteData.calculateHashCode(), 0x152F5903);

    byteData.setUint32(0, 0xAABBCCDD);
    expect(byteData.calculateHashCode(), 0x4E26782D);
  });
}
