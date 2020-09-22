import './DeviceExtension.dart';

/// An interface for devices that have extra function extensions.
abstract class DeviceWithExtensions {
  final Set<DeviceExtension> deviceExtensions = Set();
}
