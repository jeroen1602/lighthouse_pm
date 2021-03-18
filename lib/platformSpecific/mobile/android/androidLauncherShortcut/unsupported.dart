import 'package:flutter/foundation.dart';

import 'shared.dart';

///
/// A copy of the api but all the functions fail, this is done so it can still
/// exist on the other platforms.
///
class AndroidLauncherShortcut {
  static AndroidLauncherShortcut? _instance;

  AndroidLauncherShortcut._() {
    if (!kReleaseMode) {
      throw UnsupportedError(
          "Hey developer this platform doesn't support shortcuts!\nHow come the class is still initialized?");
    }
  }

  static AndroidLauncherShortcut get instance {
    if (_instance == null) {
      _instance = AndroidLauncherShortcut._();
    }
    return _instance!;
  }

  Future<void> readyForData() async {
    _throwUnsupportedError();
  }

  Stream<ShortcutHandle?> get changePowerStateMac {
    _throwUnsupportedError();
    return Stream.empty();
  }

  Future<bool> shortcutSupported() async {
    return false;
  }

  Future<bool> requestShortcutLighthouse(String macAddress, String name) async {
    _throwUnsupportedError();
    return false;
  }

  static void _throwUnsupportedError() {
    if (!kReleaseMode) {
      throw UnsupportedError(
          "Hey developer this platform doesn't support shortcuts!");
    }
  }
}
