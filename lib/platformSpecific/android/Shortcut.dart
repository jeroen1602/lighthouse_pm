import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';

///
/// Code for handling and creating shortcuts.
///
class Shortcut {
  Shortcut._() {
    _channel.setMethodCallHandler((call) {
      for (final item in _InMethods.items) {
        if (item.functionName == call.method) {
          return item.functionHandler(this, call);
        }
      }
      throw NoSuchMethodError.withInvocation(
          this, Invocation.method(Symbol(call.method), null));
    });
    if (!kReleaseMode && !Platform.isAndroid) {
      throw UnsupportedError(
          "Hey developer this platform doesn't support shortcuts!\nHow come the class is still initialized?");
    }
  }

  static Shortcut? _instance;

  static Shortcut get instance {
    if (_instance == null) {
      _instance = Shortcut._();
    }
    return _instance!;
  }

  BehaviorSubject<ShortcutHandle?> _changePowerStateMac = BehaviorSubject();

  static const _channel =
      const MethodChannel("com.jeroen1602.lighthouse_pm/shortcut");

  ///
  /// Notify the native code that the app is ready for method callbacks.
  /// Otherwise callbacks will be missed.
  ///
  /// The native code will cache data to send until the flutter part tells that
  /// it's ready to handle code.
  ///
  Future<void> readyForData() async {
    await _channel.invokeMethod('readyForData');
  }

  Future<bool> _requestShortcut(
      ShortcutTypes type, String shortCutString, String name) {
    return _channel.invokeMethod<bool>('requestShortcut', <String, dynamic>{
      'action': "${type._part}/$shortCutString",
      'name': name
    }).then((value) => value == true);
  }

  ///
  /// Request the user to a shortcut for a lighthouse.
  ///
  ///
  Future<bool> requestShortcutLighthouse(String macAddress, String name) {
    return _requestShortcut(ShortcutTypes.MAC_TYPE, macAddress, name);
  }

  ///
  /// This stream will have shortcut handles that should be handled.
  /// For example a [ShortcutTypes.MAC_TYPE] where the [ShortcutHandle.data]
  /// will contain the mac address of the device that should have it's power
  /// state toggled.
  Stream<ShortcutHandle?> get changePowerStateMac =>
      _changePowerStateMac.stream;

  ///
  /// Handle the incoming mac callback.
  ///
  static Future<void> _handleMacShortcut(
      Shortcut instance, MethodCall call) async {
    if (call.arguments != null && call.arguments is String) {
      instance._changePowerStateMac.add(
          ShortcutHandle(ShortcutTypes.MAC_TYPE, call.arguments as String));
    } else {
      debugPrint("Could not handle mac shortcut callback because the argument "
          "was missing or of a wrong type");
    }
    return;
  }
}

typedef _InMethodHandler = Future<dynamic> Function(
    Shortcut instance, MethodCall call);

///
/// A list of "enums" with the information for the methods that the shortcut
/// handler can receive
///
class _InMethods {
  static const HANDLE_MAC_SHORTCUT =
      _InMethods._('handleMacShortcut', Shortcut._handleMacShortcut);

  static const items = [HANDLE_MAC_SHORTCUT];

  final String functionName;
  final _InMethodHandler functionHandler;

  const _InMethods._(this.functionName, this.functionHandler);
}

///
/// Types of shortcuts that exist
///
class ShortcutTypes {
  static const MAC_TYPE = ShortcutTypes._("mac");

  final String _part;

  const ShortcutTypes._(this._part);
}

///
/// Data class with all the information for a shortcut type.
///
class ShortcutHandle {
  final ShortcutTypes type;
  final String data;

  const ShortcutHandle(this.type, this.data);

  @override
  bool operator ==(Object other) {
    if (other is ShortcutHandle) {
      return other.type == this.type && other.data == this.data;
    }
    return false;
  }

  @override
  int get hashCode => super.hashCode;
}
