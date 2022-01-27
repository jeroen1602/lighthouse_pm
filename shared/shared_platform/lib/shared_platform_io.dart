import 'dart:io';

import 'package:meta/meta.dart';

abstract class SharedPlatform {
  ///
  /// Override the platform being reported for testing. Will not happen in
  /// release mode!
  ///
  @visibleForTesting
  static PlatformOverride? overridePlatform;

  static bool _isRelease() {
    bool release = true;
    assert(() {
      release = false;
      return true;
    }());
    return release;
  }

  static bool get isAndroid {
    final bool release = _isRelease();
    if (overridePlatform == PlatformOverride.android && !release) {
      return true;
    }
    if (overridePlatform != null && !release) {
      return false;
    }
    return Platform.isAndroid;
  }

  static bool get isFuchsia {
    final bool release = _isRelease();
    if (overridePlatform == PlatformOverride.fuchsia && !release) {
      return true;
    }
    if (overridePlatform != null && !release) {
      return false;
    }
    return Platform.isFuchsia;
  }

  static bool get isIOS {
    final bool release = _isRelease();
    if (overridePlatform == PlatformOverride.ios && !release) {
      return true;
    }
    if (overridePlatform != null && !release) {
      return false;
    }
    return Platform.isIOS;
  }

  static bool get isWeb {
    final bool release = _isRelease();
    if (overridePlatform == PlatformOverride.web && !release) {
      return true;
    }
    return false;
  }

  static bool get isLinux {
    final bool release = _isRelease();
    if (overridePlatform == PlatformOverride.linux && !release) {
      return true;
    }
    if (overridePlatform != null && !release) {
      return false;
    }
    return Platform.isLinux;
  }

  static bool get isWindows {
    final bool release = _isRelease();
    if (overridePlatform == PlatformOverride.windows && !release) {
      return true;
    }
    if (overridePlatform != null && !release) {
      return false;
    }
    return Platform.isWindows;
  }

  static String get current {
    if (SharedPlatform.isAndroid) {
      return "Android";
    }
    if (SharedPlatform.isIOS) {
      return "IOS";
    }
    if (SharedPlatform.isLinux) {
      return "Linux";
    }
    if (SharedPlatform.isWindows) {
      return "Windows";
    }
    if (SharedPlatform.isWeb) {
      return "web";
    }
    if (SharedPlatform.isFuchsia) {
      return "fuchsia";
    }
    return "UNKNOWN";
  }

  static void exit(final int code) {
    exit(code);
  }
}

@visibleForTesting
enum PlatformOverride {
  android,
  fuchsia,
  ios,
  web,
  linux,
  windows,
  unsupported,
}
