import 'dart:typed_data';

import 'package:collection/collection.dart';

///
/// Extension functions for [ByteData]
///
extension ByteDataFunctions on ByteData {
  List<int> toUint8List() {
    return this.buffer.asUint8List();
  }

  List<int> toInt8List() {
    return this.buffer.asInt8List();
  }

  int calculateHashCode() {
    const equality = const ListEquality<int>();
    return equality.hash(this.toUint8List());
  }
}

///
/// A simple read only wrapper for [ByteData].
///
class ReadOnlyByteData implements ByteData {
  final ByteData _byteData;

  ReadOnlyByteData(int length) : _byteData = ByteData(length);

  ReadOnlyByteData.fromByteData(ByteData byteData) : _byteData = byteData;

  @override
  ByteBuffer get buffer => _byteData.buffer;

  @override
  int get elementSizeInBytes => _byteData.elementSizeInBytes;

  @override
  double getFloat32(int byteOffset, [Endian endian = Endian.big]) {
    return _byteData.getFloat32(byteOffset, endian);
  }

  @override
  double getFloat64(int byteOffset, [Endian endian = Endian.big]) {
    return _byteData.getFloat64(byteOffset, endian);
  }

  @override
  int getInt16(int byteOffset, [Endian endian = Endian.big]) {
    return _byteData.getInt16(byteOffset, endian);
  }

  @override
  int getInt32(int byteOffset, [Endian endian = Endian.big]) {
    return _byteData.getInt32(byteOffset, endian);
  }

  @override
  int getInt64(int byteOffset, [Endian endian = Endian.big]) {
    return _byteData.getInt64(byteOffset, endian);
  }

  @override
  int getInt8(int byteOffset) {
    return _byteData.getInt8(byteOffset);
  }

  @override
  int getUint16(int byteOffset, [Endian endian = Endian.big]) {
    return _byteData.getUint16(byteOffset, endian);
  }

  @override
  int getUint32(int byteOffset, [Endian endian = Endian.big]) {
    return _byteData.getUint32(byteOffset, endian);
  }

  @override
  int getUint64(int byteOffset, [Endian endian = Endian.big]) {
    return _byteData.getUint64(byteOffset, endian);
  }

  @override
  int getUint8(int byteOffset) {
    return _byteData.getUint8(byteOffset);
  }

  @override
  int get lengthInBytes => _byteData.lengthInBytes;

  @override
  int get offsetInBytes => _byteData.offsetInBytes;

  /// Will always throw [UnsupportedError]!
  @override
  void setFloat32(int byteOffset, double value, [Endian endian = Endian.big]) {
    throw UnsupportedError("Unable to change data in read only ByteData");
  }

  /// Will always throw [UnsupportedError]!
  @override
  void setFloat64(int byteOffset, double value, [Endian endian = Endian.big]) {
    throw UnsupportedError("Unable to change data in read only ByteData");
  }

  /// Will always throw [UnsupportedError]!
  @override
  void setInt16(int byteOffset, int value, [Endian endian = Endian.big]) {
    throw UnsupportedError("Unable to change data in read only ByteData");
  }

  /// Will always throw [UnsupportedError]!
  @override
  void setInt32(int byteOffset, int value, [Endian endian = Endian.big]) {
    throw UnsupportedError("Unable to change data in read only ByteData");
  }

  /// Will always throw [UnsupportedError]!
  @override
  void setInt64(int byteOffset, int value, [Endian endian = Endian.big]) {
    throw UnsupportedError("Unable to change data in read only ByteData");
  }

  /// Will always throw [UnsupportedError]!
  @override
  void setInt8(int byteOffset, int value) {
    throw UnsupportedError("Unable to change data in read only ByteData");
  }

  /// Will always throw [UnsupportedError]!
  @override
  void setUint16(int byteOffset, int value, [Endian endian = Endian.big]) {
    throw UnsupportedError("Unable to change data in read only ByteData");
  }

  /// Will always throw [UnsupportedError]!
  @override
  void setUint32(int byteOffset, int value, [Endian endian = Endian.big]) {
    throw UnsupportedError("Unable to change data in read only ByteData");
  }

  /// Will always throw [UnsupportedError]!
  @override
  void setUint64(int byteOffset, int value, [Endian endian = Endian.big]) {
    throw UnsupportedError("Unable to change data in read only ByteData");
  }

  /// Will always throw [UnsupportedError]!
  @override
  void setUint8(int byteOffset, int value) {
    throw UnsupportedError("Unable to change data in read only ByteData");
  }
}
