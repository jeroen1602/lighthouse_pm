part of device_extension;

/// An interface for devices that have extra function extensions.
abstract class DeviceWithExtensions {
  final Set<DeviceExtension> deviceExtensions = {};
}
