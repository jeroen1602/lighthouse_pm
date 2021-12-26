import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:lighthouse_pm/platform_specific/shared/local_platform.dart';
import 'package:rxdart/rxdart.dart';

import 'android_launcher_shortcut_shared.dart';

///
/// Code for handling and creating shortcuts.
///
class AndroidLauncherShortcut {
  AndroidLauncherShortcut._() {
    channel.setMethodCallHandler(AndroidLauncherShortcut.messageHandler);
    if (!kReleaseMode && !LocalPlatform.isAndroid) {
      throw UnsupportedError(
          "Hey developer this platform doesn't support shortcuts!\nHow come the class is still initialized?");
    }
  }

  @visibleForTesting
  static Future<void> messageHandler(MethodCall call) async {
    for (final item in _InMethods.items) {
      if (item.functionName == call.method) {
        return item.functionHandler(call);
      }
    }
    throw NoSuchMethodError.withInvocation(
        instance, Invocation.method(Symbol(call.method), null));
  }

  static AndroidLauncherShortcut? _instance;

  static AndroidLauncherShortcut get instance =>
      _instance ??= AndroidLauncherShortcut._();

  BehaviorSubject<ShortcutHandle?> _changePowerStateMac = BehaviorSubject();

  @visibleForTesting
  void clearStateStream() {
    _changePowerStateMac.close();
    _changePowerStateMac = BehaviorSubject();
  }

  @visibleForTesting
  static const channel = MethodChannel("com.jeroen1602.lighthouse_pm/shortcut");

  ///
  /// Notify the native code that the app is ready for method callbacks.
  /// Otherwise callbacks will be missed.
  ///
  /// The native code will cache data to send until the flutter part tells that
  /// it's ready to handle code.
  ///
  Future<void> readyForData() async {
    await channel.invokeMethod('readyForData');
  }

  ///
  /// Check if shortcut pins are supported on the current device.
  /// This should be true if the device is running Android 8.0 (Oreo api 26) or
  /// higher, but it may also happen if the shortcut manager is `null`.
  ///
  Future<bool> shortcutSupported() async {
    return channel.invokeMethod('supportShortcut').then((value) {
      if (value is bool) {
        return value;
      }
      return false;
    });
  }

  Future<bool> _requestShortcut(
      ShortcutTypes type, String shortCutString, String name) {
    return channel.invokeMethod<bool>('requestShortcut', <String, dynamic>{
      'action': "${type.part}/$shortCutString",
      'name': name
    }).then((value) => value == true);
  }

  ///
  /// Request the user to a shortcut for a lighthouse.
  ///
  Future<bool> requestShortcutLighthouse(String macAddress, String name) {
    return _requestShortcut(ShortcutTypes.macType, macAddress, name);
  }

  ///
  /// This stream will have shortcut handles that should be handled.
  /// For example a [ShortcutTypes.macType] where the [ShortcutHandle.data]
  /// will contain the mac address of the device that should have it's power
  /// state toggled.
  ///
  Stream<ShortcutHandle?> get changePowerStateMac =>
      _changePowerStateMac.stream;

  ///
  /// Handle the incoming mac callback.
  ///
  static Future<void> _handleMacShortcut(MethodCall call) async {
    if (call.arguments != null && call.arguments is String) {
      instance._changePowerStateMac
          .add(ShortcutHandle(ShortcutTypes.macType, call.arguments as String));
    } else {
      debugPrint("Could not handle mac shortcut callback because the argument "
          "was missing or of a wrong type");
    }
    return;
  }
}

typedef _InMethodHandler = Future<dynamic> Function(MethodCall call);

///
/// A list of "enums" with the information for the methods that the shortcut
/// handler can receive
///
class _InMethods {
  static const handleMacShortcut = _InMethods._(
      'handleMacShortcut', AndroidLauncherShortcut._handleMacShortcut);

  static const items = [handleMacShortcut];

  final String functionName;
  final _InMethodHandler functionHandler;

  const _InMethods._(this.functionName, this.functionHandler);
}
