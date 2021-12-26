import 'package:flutter/foundation.dart';

class LocalPlatform {
  static const bool isAndroid = false;

  static const bool isIOS = false;

  static const bool isWeb = true;

  static const bool isLinux = false;

  static const String current = "web";

  static void exit(int code) {
    if (!kReleaseMode) {
      throw UnsupportedError(
          "Hey developer this platform doesn't support exit!");
    }
  }
}
