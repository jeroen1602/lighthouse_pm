import 'dart:typed_data';

import 'package:fake_back_end/fake_back_end.dart';
import 'package:test/test.dart';

import 'test_characteristic.dart';

void main() {
  test('Should read as a string', () async {
    final characteristic =
        TestReadCharacteristic(intListFromString("SAMPLE_TEXT"));

    expect(await characteristic.readString(), "SAMPLE_TEXT");
  });

  test('Should read byteData', () async {
    final characteristic = TestReadCharacteristic([0xFF]);

    var data = await characteristic.readByteData();
    expect(data.lengthInBytes, 1);
    expect(data.getUint8(0), 0xFF);

    characteristic.data.add(0xBB);

    data = await characteristic.readByteData();
    expect(data.lengthInBytes, 2);
    expect(data.getUint8(0), 0xFF);
    expect(data.getUint8(1), 0xBB);

    characteristic.data.add(0xDD);

    data = await characteristic.readByteData();
    expect(data.lengthInBytes, 3);
    expect(data.getUint8(0), 0xFF);
    expect(data.getUint8(1), 0xBB);
    expect(data.getUint8(2), 0xDD);
  });

  test('Should read uint32', () async {
    final characteristic = TestReadCharacteristic([0xff]);

    //Read uInt8
    expect(await characteristic.readUint32(), 0xFF,
        reason: "Should read uInt8");

    characteristic.data.clear();
    characteristic.data.addAll([0xAA, 0xEE]);

    //Read uInt16
    expect(await characteristic.readUint32(), 0xAAEE,
        reason: "Should read uInt16");

    characteristic.data.clear();
    characteristic.data.addAll([0xAA, 0xEE, 0xBB]);

    //Read uInt16
    expect(await characteristic.readUint32(), 0xAAEE,
        reason: "Should read 3 bytes as uInt16");

    characteristic.data.clear();
    characteristic.data.addAll([0xAA, 0xEE, 0xBB, 0xCC]);

    //Read uInt32
    expect(await characteristic.readUint32(), 0xAAEEBBCC,
        reason: "Should read uInt32");
  });

  test('Should writeByteData', () async {
    final characteristic = TestReadWriteCharacteristic();

    final data = ByteData(8);
    data.setUint8(0, 0xAA);
    data.setUint8(1, 0x11);
    data.setUint8(2, 0xBB);
    data.setUint8(3, 0x66);
    data.setUint8(4, 0xEE);
    data.setUint8(5, 0xCC);
    data.setUint8(6, 0x33);
    data.setUint8(7, 0x99);

    await characteristic.writeByteData(data);

    final returnData = await characteristic.readByteData();

    expect(returnData.lengthInBytes, data.lengthInBytes);
    for (int i = 0; i < returnData.lengthInBytes; i++) {
      expect(returnData.getUint8(i), data.getUint8(i),
          reason: 'Returned data should be the same at index $i');
    }
  });
}
