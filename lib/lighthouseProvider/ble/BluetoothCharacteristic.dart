import 'dart:convert';
import 'dart:typed_data';

import 'Guid.dart';

/// An abstract class for bluetooth characteristic.
///
/// Any bluetooth characteristic should at least be able to do this.
abstract class LHBluetoothCharacteristic {
  LighthouseGuid get uuid;

  // region read
  Future<List<int>> read();

  Future<String> readString() async {
    final list = await read();
    return Utf8Decoder().convert(list);
  }

  Future<int> readUint32([Endian endian = Endian.big]) async {
    final data = await readByteData();
    switch (data.lengthInBytes) {
      case 0:
        return 0;
      case 1:
        return data.getUint8(0);
      case 2:
      case 3:
        return data.getUint16(0, endian);
      default:
        return data.getUint32(0, endian);
    }
  }

  Future<ByteData> readByteData() async {
    final data = await read();
    final output = ByteData(data.length);
    for (var i = 0; i < data.length; i++) {
      output.setUint8(i, data[i]);
    }
    return output;
  }

  // endregion

  // region write
  Future<void> write(List<int> data, {bool withoutResponse = false});

  Future<void> writeByteData(ByteData value,
      {bool withoutResponse = false}) async {
    final list = List<int>.filled(value.lengthInBytes, 0);
    for (var i = 0; i < value.lengthInBytes; i++) {
      list[i] = value.getUint8(i);
    }
    return await write(list, withoutResponse: withoutResponse);
  }
//end region

}
