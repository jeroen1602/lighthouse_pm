import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:lighthouse_pm/lighthouseProvider/helpers/ByteDataExtensions.dart';

///
/// Guid for Bluetooth Low energy services and characteristics.
///
class LighthouseGuid {
  final ByteData _bytes;
  final int _hashCode;

  LighthouseGuid.fromBytes(ByteData bytes)
      : _bytes = bytes,
        _hashCode = _calculateHashCode(bytes);

  LighthouseGuid.fromString(String input) : this.fromBytes(_fromString(input));

  LighthouseGuid.empty() : this.fromBytes(ByteData(16));

  static ByteData _fromString(String input) {
    if (input == null) {
      throw new ArgumentError("Input was null");
    }

    input = _removeNonHexCharacters(input);
    final byteArray = hex.decode(input);

    if (byteArray.length != 16) {
      throw new FormatException("The format is invalid");
    }

    final bytes = ByteData(byteArray.length);
    for (var i = 0; i < byteArray.length; i++) {
      bytes.setUint8(i, byteArray[i]);
    }
    return bytes;
  }

  @override
  String toString() {
    String one =
        _bytes.getUint32(0, Endian.big).toRadixString(16).padLeft(8, '0');
    String two =
        _bytes.getUint16(4, Endian.big).toRadixString(16).padLeft(4, '0');
    String three =
        _bytes.getUint16(6, Endian.big).toRadixString(16).padLeft(4, '0');
    String four =
        _bytes.getUint16(8, Endian.big).toRadixString(16).padLeft(4, '0');
    String five =
        _bytes.getUint32(10, Endian.big).toRadixString(16).padLeft(8, '0') +
            _bytes.getUint16(14, Endian.big).toRadixString(16).padLeft(4, '0');
    return "$one-$two-$three-$four-$five".toUpperCase();
  }

  operator ==(other) =>
      other is LighthouseGuid && this._hashCode == other._hashCode;

  @override
  int get hashCode => this._hashCode;

  ReadOnlyByteData getByteData() {
    return ReadOnlyByteData.fromByteData(this._bytes);
  }

  static String _removeNonHexCharacters(String sourceString) {
    return String.fromCharCodes(sourceString.runes.where((r) =>
            (r >= 48 && r <= 57) // characters 0 to 9
            ||
            (r >= 65 && r <= 70) // characters A to F
            ||
            (r >= 97 && r <= 102) // characters a to f
        ));
  }

  static int _calculateHashCode(ByteData bytes) {
    return bytes.calculateHashCode();
  }
}

class Guid32 extends LighthouseGuid {
  Guid32.empty() : super.fromBytes(ByteData(4));

  Guid32.fromInt32(int bytes) : super.fromBytes(ByteData(4)) {
    super._bytes.setInt32(0, bytes, Endian.big);
  }

  Guid32.fromLighthouseGuid(LighthouseGuid old) : super.fromBytes(ByteData(4)) {
    super._bytes.setInt32(0, old._bytes.getUint32(0, Endian.big), Endian.big);
  }

  @override
  String toString() {
    return "${_bytes.getUint32(0, Endian.big)}";
  }

  @override
  operator ==(other) => other is Guid32 && this._hashCode == other._hashCode;

  @override
  int get hashCode => super.hashCode;

  bool isEqualToInt32(int other) {
    return this._bytes.getUint32(0, Endian.big) == other;
  }

  bool isEqualToGuid(LighthouseGuid guid) {
    final other = guid.getByteData();
    return this._bytes.getUint32(0, Endian.big) ==
        other.getUint32(0, Endian.big);
  }
}
