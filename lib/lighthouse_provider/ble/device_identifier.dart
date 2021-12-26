import 'package:collection/collection.dart';

///
/// A class for storing a device identifier or MAC address.
///
class LHDeviceIdentifier {
  final String id;

  const LHDeviceIdentifier(this.id);

  @override
  String toString() => id;

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) =>
      other is LHDeviceIdentifier && compareAsciiLowerCase(id, other.id) == 0;
}
