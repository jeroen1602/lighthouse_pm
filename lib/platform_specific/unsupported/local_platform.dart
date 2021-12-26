import 'package:flutter/foundation.dart';

class LocalPlatform {
  static bool get isAndroid {
    _throwUnsupportedError();
    return false;
  }

  static bool get isIOS {
    _throwUnsupportedError();
    return false;
  }

  static bool get isWeb {
    _throwUnsupportedError();
    return false;
  }

  static bool get isLinux {
    _throwUnsupportedError();
    return false;
  }

  static String get current {
    _throwUnsupportedError();
    return "unsupported";
  }

  static void exit(int code) {
    _throwUnsupportedError();
  }

  static void _throwUnsupportedError() {
    if (!kReleaseMode) {
      throw UnsupportedError(
          "Hey developer this platform doesn't support platform determination!");
    }
  }
}
