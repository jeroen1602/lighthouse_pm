import 'package:flutter_svg/flutter_svg.dart';
import 'package:rxdart/rxdart.dart';

import 'DeviceExtension.dart';

/// A device extension that allow the device to be identified.
class IdentifyDeviceExtension extends DeviceExtension {
  IdentifyDeviceExtension({FutureCallback onTap})
      : super(
            onTap: onTap,
            toolTip: 'Identify',
            icon: SvgPicture.asset(
              "assets/images/app-icon.svg",
              width: 24,
              height: 24,
            )) {
    super.streamEnabledFunction = _enabledStream;
  }

  BehaviorSubject<bool> _enabledSubject = BehaviorSubject.seeded(true);

  Stream<bool> _enabledStream() {
    if (_enabledSubject == null) {
      _enabledSubject = BehaviorSubject.seeded(true);
    }
    return _enabledSubject.stream;
  }

  void setEnabled(bool enabled) {
    _enabledSubject.add(enabled);
  }

  Future<void> close() async {
    if (_enabledSubject != null) {
      await _enabledSubject.close();
    }
  }
}
