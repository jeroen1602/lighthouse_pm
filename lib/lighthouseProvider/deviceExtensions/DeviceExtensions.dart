import 'package:flutter/widgets.dart';

typedef FutureCallback = Future<void> Function();
typedef StreamEnabledFunction = Stream<bool> Function();

//A single device extension to add extra functionality to a device.
abstract class DeviceExtensions {
  DeviceExtensions(
      {@required this.toolTip,
      @required this.icon,
      @required this.onTap,
      this.streamEnabledFunction});

  final String toolTip;
  final Widget icon;
  final FutureCallback onTap;
  @protected
  StreamEnabledFunction streamEnabledFunction;

  Stream<bool> get enabledStream {
    if (streamEnabledFunction != null) {
      return streamEnabledFunction();
    } else {
      return Stream.value(true);
    }
  }

  @override
  bool operator ==(Object other) {
    return other.runtimeType == this.runtimeType;
  }

  @override
  int get hashCode => super.hashCode;
}
