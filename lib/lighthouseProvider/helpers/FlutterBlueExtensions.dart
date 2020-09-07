///
/// Extensions for the flutter blue classes.
///

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_blue/flutter_blue.dart';
import 'package:lighthouse_pm/lighthouseProvider/ble/Guid.dart';

const int _BYTES_IN_INT_32 = 32 ~/ 8;

extension BluetoothCharacteristicFunctions on BluetoothCharacteristic {
  Future<ByteData> readByteData() async {
    final data = await read();
    final output = ByteData(data.length);
    for (var i = 0; i < data.length; i++) {
      output.setUint8(i, data[i]);
    }
    return output;
  }

  Future<String> readString() async {
    final list = await read();
    return Utf8Decoder().convert(list);
  }

  Future<int> readUint32() async {
    final data = await readByteData();
    return data.getUint32(0);
  }

  Future<Null> writeByteData(ByteData value,
      {bool withoutResponse = false}) async {
    final list = List<int>(value.lengthInBytes);
    for (var i = 0; i < value.lengthInBytes; i++) {
      list.add(value.getUint8(i));
    }
    return await write(list, withoutResponse: withoutResponse);
  }
}

extension GuidByteData on Guid {
  ByteData toByteData() {
    final list = toByteArray();
    final output = ByteData(list.length);
    for (var i = 0; i < list.length; i++) {
      output.setUint8(i, list[i]);
    }
    return output;
  }

  int getFirstAsUInt32() {
    final list = toByteArray();
    final data = ByteData(_BYTES_IN_INT_32);
    for (var i = 0; i < _BYTES_IN_INT_32; i++) {
      data.setUint8(i, list[i]);
    }
    return data.getUint32(0, Endian.big);
  }

  bool checkFirstPart(int expected) {
    return getFirstAsUInt32() == expected;
  }

  LighthouseGuid toLighthouseGuid() {
    return LighthouseGuid.fromBytes(this.toByteData());
  }

  Guid32 toGuid32() {
    final bytes = this.toByteData();
    return Guid32.fromInt32(bytes.getUint32(0, Endian.big));
  }
}
