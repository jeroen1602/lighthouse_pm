import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:lighthouse_pm/lighthouseProvider/ble/DeviceIdentifier.dart';
import 'package:lighthouse_pm/platformSpecific/shared/LocalPlatform.dart';

abstract class FakeDeviceIdentifier {
  static LHDeviceIdentifier generateDeviceIdentifier(int seed) {
    if (LocalPlatform.isAndroid) {
      return generateDeviceIdentifierAndroid(seed);
    } else if (LocalPlatform.isIOS) {
      return generateDeviceIdentifierIOS(seed);
    } else if (LocalPlatform.isWeb) {
      return generateDeviceIdentifierWeb(seed);
    } else if (LocalPlatform.isLinux) {
      return generateDeviceIdentifierLinux(seed);
    } else if (LocalPlatform.isWindows) {
      return generateDeviceIdentifierWindows(seed);
    }
    throw UnsupportedError(
        "Cannot generate device identifier for platform: ${LocalPlatform.current}");
  }

  @visibleForTesting
  static LHDeviceIdentifier generateBasicMacIdentifier(int seed) {
    final octets = List<int>.filled(6, 0);
    for (var i = 5; i >= 0; i--) {
      octets[i] = seed & 0xFF;
      seed >>= 8;
      if (seed <= 0) {
        break;
      }
    }
    var output = "";
    for (final octet in octets) {
      if (output.length > 0) {
        output += ":";
      }
      output += octet.toRadixString(16).padLeft(2, '0').toUpperCase();
    }
    return LHDeviceIdentifier(output);
  }

  @visibleForTesting
  static LHDeviceIdentifier generateDeviceIdentifierLinux(int seed) {
    return generateBasicMacIdentifier(seed);
  }

  @visibleForTesting
  static LHDeviceIdentifier generateDeviceIdentifierWindows(int seed) {
    return generateBasicMacIdentifier(seed);
  }

  @visibleForTesting
  static LHDeviceIdentifier generateDeviceIdentifierAndroid(int seed) {
    return generateBasicMacIdentifier(seed);
  }

  @visibleForTesting
  static LHDeviceIdentifier generateDeviceIdentifierWeb(int seed) {
    final octets = List<int>.filled(16, 0);
    for (var i = 15; i >= 0; i--) {
      octets[i] = seed & 0xFF;
      seed >>= 8;
      if (seed <= 0) {
        break;
      }
    }
    final output = base64Encode(octets);
    return LHDeviceIdentifier(output);
  }

  @visibleForTesting
  static LHDeviceIdentifier generateDeviceIdentifierIOS(int seed) {
    throw UnimplementedError('TODO implement ios fake device Identifier');
  }
}
