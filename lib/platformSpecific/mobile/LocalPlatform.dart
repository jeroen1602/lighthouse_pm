import 'dart:io';

class LocalPlatform {
  static bool get isAndroid {
    return Platform.isAndroid;
  }

  static bool get isIOS {
    return Platform.isIOS;
  }

  static bool get isWeb {
    return false;
  }

  static String get current {
    if (LocalPlatform.isAndroid) {
      return "Android";
    }
    if (LocalPlatform.isIOS) {
      return "IOS";
    }
    return "UNKNOWN";
  }

  static void exit(int code) {
    exit(code);
  }
}
