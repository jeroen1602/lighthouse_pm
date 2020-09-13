import 'package:collection/collection.dart';
import 'package:flutter_blue/flutter_blue.dart';

///
/// A class for storing a device identifier or MAC address.
///
class LHDeviceIdentifier {
  final String id;

  const LHDeviceIdentifier(this.id);

  @override
  String toString() => id.toUpperCase();

  @override
  int get hashCode => id.toUpperCase().hashCode;

  @override
  bool operator ==(Object other) =>
      other is LHDeviceIdentifier &&
      compareAsciiLowerCase(this.id, other.id) == 0;

  LHDeviceIdentifier.fromFlutterBlue(DeviceIdentifier old) : this(old.id);
}
