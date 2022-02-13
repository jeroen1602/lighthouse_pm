class SharedPlatform {
  static const bool isAndroid = false;

  static const bool isFuchsia = false;

  static const bool isIOS = false;

  static const bool isWeb = true;

  static const bool isLinux = false;

  static const bool isWindows = false;

  static const String current = "web";

  static void exit(final int code) {
    assert(() {
      throw UnsupportedError(
          "Hey developer this platform doesn't support exit!");
    }());
  }
}
