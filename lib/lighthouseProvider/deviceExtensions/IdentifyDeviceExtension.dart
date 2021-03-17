import 'package:flutter_svg/flutter_svg.dart';
import 'package:rxdart/rxdart.dart';

import 'DeviceExtension.dart';

/// A device extension that allow the device to be identified.
class IdentifyDeviceExtension extends DeviceExtension {
  IdentifyDeviceExtension({required FutureCallback onTap})
      : super(
            onTap: onTap,
            toolTip: 'Identify',
            icon: SvgPicture.asset(
              "assets/images/identify-icon.svg",
              width: 24,
              height: 24,
            )) {
    super.streamEnabledFunction = _enabledStream;
  }

  BehaviorSubject<bool>? _enabledSubject = BehaviorSubject.seeded(true);

  Stream<bool> _enabledStream() {
    return _nonNullEnabledSubject().stream;
  }

  BehaviorSubject<bool> _nonNullEnabledSubject() {
    if (_enabledSubject == null) {
      _enabledSubject = BehaviorSubject.seeded(true);
    }
    return _enabledSubject!;
  }

  void setEnabled(bool enabled) {
    _nonNullEnabledSubject().add(enabled);
  }

  Future<void> close() async {
    final enabledSubject = _enabledSubject;
    if (enabledSubject != null) {
      await enabledSubject.close();
      _enabledSubject = null;
    }
  }
}
