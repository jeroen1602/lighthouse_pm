import 'dart:io';

import 'package:flutter/foundation.dart';

class LocalPlatform {
  ///
  /// Override the platform being reported for testing. Will not happen in
  /// release mode!
  ///
  @visibleForTesting
  static PlatformOverride? overridePlatform;

  static bool get isAndroid {
    if (overridePlatform == PlatformOverride.android && !kReleaseMode) {
      return true;
    }
    return Platform.isAndroid;
  }

  static bool get isIOS {
    if (overridePlatform == PlatformOverride.ios && !kReleaseMode) {
      return true;
    }
    return Platform.isIOS;
  }

  static bool get isWeb {
    if (overridePlatform == PlatformOverride.web && !kReleaseMode) {
      return true;
    }
    return false;
  }

  static String get current {
    if (LocalPlatform.isAndroid ||
        (overridePlatform == PlatformOverride.android && !kReleaseMode)) {
      return "Android";
    }
    if (LocalPlatform.isIOS ||
        (overridePlatform == PlatformOverride.ios && !kReleaseMode)) {
      return "IOS";
    }
    if (overridePlatform == PlatformOverride.web && !kReleaseMode) {
      return "web";
    }
    return "UNKNOWN";
  }

  static void exit(int code) {
    exit(code);
  }
}

@visibleForTesting
enum PlatformOverride {
  android,
  ios,
  web,
}
