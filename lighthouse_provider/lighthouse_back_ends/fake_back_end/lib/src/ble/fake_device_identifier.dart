part of fake_back_end;

abstract class FakeDeviceIdentifier {
  static LHDeviceIdentifier generateDeviceIdentifier(int seed) {
    if (SharedPlatform.isAndroid) {
      return generateDeviceIdentifierAndroid(seed);
    } else if (SharedPlatform.isIOS) {
      return generateDeviceIdentifierIOS(seed);
    } else if (SharedPlatform.isWeb) {
      return generateDeviceIdentifierWeb(seed);
    } else if (SharedPlatform.isLinux) {
      return generateDeviceIdentifierLinux(seed);
    }
    throw UnsupportedError(
        "Cannot generate device identifier for platform: ${SharedPlatform.current}");
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
      if (output.isNotEmpty) {
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
