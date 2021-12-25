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
