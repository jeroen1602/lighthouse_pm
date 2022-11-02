import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lighthouse_pm/theming.dart';
import 'package:lighthouse_provider/device_extensions/device_extension.dart';
import 'package:lighthouse_provider/device_extensions/shortcut_extension.dart';
import 'package:lighthouse_provider/lighthouse_provider.dart';
import 'package:lighthouse_providers/lighthouse_v2_device_provider.dart';
import 'package:lighthouse_providers/vive_base_station_device_provider.dart';

Widget getWidgetFromDeviceExtension(
  final DeviceExtension extension,
) {
  if (extension is OnExtension ||
      extension is SleepExtension ||
      extension is StandbyExtension) {
    return const Icon(Icons.power_settings_new);
  } else if (extension is ShortcutExtension) {
    return const Icon(Icons.add);
  } else if (extension is IdentifyDeviceExtension) {
    return SvgPicture.asset(
      "assets/images/identify-icon.svg",
    );
  } else if (extension is ClearIdExtension) {
    return const Text('ID');
  }

  return Text(extension.runtimeType.toString());
}

Color getButtonColorFromDeviceExtension(
    final BuildContext context, final DeviceExtension extension) {
  final theming = Theming.of(context);
  if (extension is OnExtension) {
    return theming.customColors.onContainer;
  } else if (extension is SleepExtension) {
    return theming.customColors.sleepContainer;
  } else if (extension is StandbyExtension) {
    return theming.customColors.standbyContainer;
  }

  return theming.buttonColor;
}

ButtonStyle? getButtonStyleFromState(
    final Theming theming, final LighthousePowerState state) {
  switch (state) {
    case LighthousePowerState.on:
      return _createButtonStyle(
          theming.customColors.onOn,
          theming.customColors.on,
          theming.brightness == Brightness.dark
              ? theming.customColors.onSurface
              : null,
          theming.customColors.onOnSurface);
    case LighthousePowerState.sleep:
      return _createButtonStyle(
          theming.customColors.onSleep,
          theming.customColors.sleep,
          theming.brightness == Brightness.dark
              ? theming.customColors.sleepSurface
              : null,
          theming.customColors.onSleepSurface);
    case LighthousePowerState.standby:
      return _createButtonStyle(
          theming.customColors.onStandby,
          theming.customColors.standby,
          theming.brightness == Brightness.dark
              ? theming.customColors.standbySurface
              : null,
          theming.customColors.onStandbySurface);
    case LighthousePowerState.booting:
      return _createButtonStyle(
          theming.customColors.onBooting,
          theming.customColors.booting,
          theming.brightness == Brightness.dark
              ? theming.customColors.bootingSurface
              : null,
          theming.customColors.onBootingSurface);
    case LighthousePowerState.unknown:
      return ElevatedButton.styleFrom(shape: const CircleBorder());
  }
  return null;
}

ButtonStyle? getButtonStyleFromDeviceExtension(
    final Theming theming, final DeviceExtension extension) {
  if (extension is OnExtension) {
    return getButtonStyleFromState(theming, LighthousePowerState.on);
  } else if (extension is SleepExtension) {
    return getButtonStyleFromState(theming, LighthousePowerState.sleep);
  } else if (extension is StandbyExtension) {
    return getButtonStyleFromState(theming, LighthousePowerState.standby);
  }

  return null;
}

ButtonStyle _createButtonStyle(final Color foreground, final Color background,
    final Color? surface, final Color? onSurface) {
  return ElevatedButton.styleFrom(
    shape: const CircleBorder(),
    foregroundColor: foreground,
    backgroundColor: background,
    disabledBackgroundColor: surface,
    disabledForegroundColor: onSurface,
  );
}
