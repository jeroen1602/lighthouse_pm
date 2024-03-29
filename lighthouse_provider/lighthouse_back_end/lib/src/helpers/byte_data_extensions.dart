part of '../../lighthouse_back_end.dart';

///
/// Extension functions for [ByteData]
///
extension ByteDataFunctions on ByteData {
  List<int> toUint8List() {
    return buffer.asUint8List();
  }

  List<int> toInt8List() {
    return buffer.asInt8List();
  }

  int calculateHashCode() {
    const equality = ListEquality<int>();
    return equality.hash(toUint8List());
  }
}
