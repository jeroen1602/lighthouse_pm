import 'package:flutter_svg/flutter_svg.dart';

import 'DeviceExtensions.dart';

/// A device extension that allow the device to be identified.
class IdentifyDeviceExtension extends DeviceExtensions {
  IdentifyDeviceExtension({FutureCallback onTap})
      : super(
            onTap: onTap,
            toolTip: 'Identify',
            icon: SvgPicture.asset(
              "assets/images/app-icon.svg",
              width: 24,
              height: 24,
            ));
}
