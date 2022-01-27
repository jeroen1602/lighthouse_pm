library device_extension;

import 'package:meta/meta.dart';
import 'package:lighthouse_provider/lighthouse_provider.dart';

part 'device_with_extensions.dart';

part 'on_extension.dart';

part 'sleep_extension.dart';

part 'state_extension.dart';

typedef FutureCallback = Future<void> Function();
typedef StreamEnabledFunction = Stream<bool> Function();

//A single device extension to add extra functionality to a device.
abstract class DeviceExtension {
  DeviceExtension(
      {required this.toolTip,
      required this.onTap,
      this.updateListAfter = false,
      this.streamEnabledFunction});

  final String toolTip;
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
    return other.runtimeType == runtimeType;
  }

  @override
  int get hashCode => runtimeType.hashCode;
}
