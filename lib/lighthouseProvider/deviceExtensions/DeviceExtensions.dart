import 'package:flutter/widgets.dart';

typedef FutureCallback = Future<void> Function();

//A single device extension to add extra functionality to a device.
abstract class DeviceExtensions {
  DeviceExtensions(
      {@required this.toolTip, @required this.icon, @required this.onTap});

  final String toolTip;
  final Widget icon;
  final FutureCallback onTap;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == this.runtimeType;
  }

  @override
  int get hashCode => super.hashCode;
}
