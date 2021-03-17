import 'package:flutter/widgets.dart';

typedef FutureCallback = Future<void> Function();
typedef StreamEnabledFunction = Stream<bool> Function();

//A single device extension to add extra functionality to a device.
abstract class DeviceExtension {
  DeviceExtension(
      {required this.toolTip,
      required this.icon,
      required this.onTap,
      this.updateListAfter = false,
      this.streamEnabledFunction});

  final String toolTip;
  final Widget icon;
  final FutureCallback onTap;
  final bool updateListAfter;
  @protected
  StreamEnabledFunction? streamEnabledFunction;

  Stream<bool> get enabledStream {
    final enabledFunction = streamEnabledFunction;
    if (enabledFunction != null) {
      return enabledFunction();
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
