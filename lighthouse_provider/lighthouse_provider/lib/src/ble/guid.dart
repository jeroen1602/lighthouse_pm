part of lighthouse_provider;

///
/// Guid for Bluetooth Low energy services and characteristics.
///
class LighthouseGuid {
  final ByteData _bytes;
  final int _hashCode;

  LighthouseGuid.fromBytes(final ByteData bytes)
      : _bytes = bytes,
        _hashCode = _calculateHashCode(bytes);

  LighthouseGuid.fromString(final String input)
      : this.fromBytes(_fromString(input));

  LighthouseGuid.empty() : this.fromBytes(ByteData(16));

  static ByteData _fromString(String input) {
    input = _removeNonHexCharacters(input);
    final byteArray = hex.decode(input);

    if (byteArray.length != 16) {
      throw FormatException("The format is invalid");
    }

    final bytes = ByteData(byteArray.length);
    for (var i = 0; i < byteArray.length; i++) {
      bytes.setUint8(i, byteArray[i]);
    }
    return bytes;
  }

  @override
  String toString() {
    final one =
        _bytes.getUint32(0, Endian.big).toRadixString(16).padLeft(8, '0');
    final two =
        _bytes.getUint16(4, Endian.big).toRadixString(16).padLeft(4, '0');
    final three =
        _bytes.getUint16(6, Endian.big).toRadixString(16).padLeft(4, '0');
    final four =
        _bytes.getUint16(8, Endian.big).toRadixString(16).padLeft(4, '0');
    final five =
        _bytes.getUint32(10, Endian.big).toRadixString(16).padLeft(8, '0') +
            _bytes.getUint16(14, Endian.big).toRadixString(16).padLeft(4, '0');
    return "$one-$two-$three-$four-$five".toUpperCase();
  }

  @override
  operator ==(final other) =>
      other is LighthouseGuid && hashCode == other.hashCode;

  @override
  int get hashCode => _hashCode;

  /// Get the byte data.
  /// You're not supposed to update any of the data stored in the [ByteData]
  /// object!
  ByteData getByteData() {
    return _bytes;
  }

  static String _removeNonHexCharacters(final String sourceString) {
    return String.fromCharCodes(sourceString.runes.where((final r) =>
            (r >= 48 && r <= 57) // characters 0 to 9
            ||
            (r >= 65 && r <= 70) // characters A to F
            ||
            (r >= 97 && r <= 102) // characters a to f
        ));
  }

  static int _calculateHashCode(final ByteData bytes) {
    return bytes.calculateHashCode();
  }
}

class Guid32 extends LighthouseGuid {
  Guid32.empty() : super.fromBytes(ByteData(4));

  Guid32.fromInt32(final int input) : super.fromBytes(_fromInt32(input));

  Guid32.fromLighthouseGuid(final LighthouseGuid old)
      : super.fromBytes(_lighthouseGuid(old));

  static ByteData _fromInt32(final int input) {
    final bytes = ByteData(4);
    bytes.setInt32(0, input, Endian.big);
    return bytes;
  }

  static ByteData _lighthouseGuid(final LighthouseGuid old) {
    final bytes = ByteData(4);
    bytes.setInt32(0, old._bytes.getInt32(0, Endian.big), Endian.big);
    return bytes;
  }

  @override
  String toString() {
    return _bytes
        .getUint32(0, Endian.big)
        .toRadixString(16)
        .toUpperCase()
        .padLeft(8, '0');
  }

  @override
  operator ==(final other) => other is Guid32 && hashCode == other.hashCode;

  @override
  int get hashCode => _hashCode;

  bool isEqualToInt32(final int other) {
    return _bytes.getUint32(0, Endian.big) == other;
  }

  bool isEqualToGuid(final LighthouseGuid guid) {
    final other = guid.getByteData();
    return _bytes.getUint32(0, Endian.big) == other.getUint32(0, Endian.big);
  }
}
