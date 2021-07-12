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
    if (overridePlatform != null && !kReleaseMode) {
      return false;
    }
    return Platform.isAndroid;
  }

  static bool get isIOS {
    if (overridePlatform == PlatformOverride.ios && !kReleaseMode) {
      return true;
    }
    if (overridePlatform != null && !kReleaseMode) {
      return false;
    }
    return Platform.isIOS;
  }

  static bool get isWeb {
    if (overridePlatform == PlatformOverride.web && !kReleaseMode) {
      return true;
    }
    if (overridePlatform != null && !kReleaseMode) {
      return false;
    }
    return false;
  }

  static bool get isLinux {
    if (overridePlatform == PlatformOverride.linux && !kReleaseMode) {
      return true;
    }
    if (overridePlatform != null && !kReleaseMode) {
      return false;
    }
    return Platform.isLinux;
  }

  static String get current {
    if (LocalPlatform.isAndroid) {
      return "Android";
    }
    if (LocalPlatform.isIOS) {
      return "IOS";
    }
    if (LocalPlatform.isLinux) {
      return "Linux";
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
  linux,
  unsupported,
}
