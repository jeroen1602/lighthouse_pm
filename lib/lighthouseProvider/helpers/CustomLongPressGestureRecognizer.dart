import 'dart:async';

import 'package:flutter/gestures.dart';

///
/// Almost the same as the [LongPressGestureRecognizer] from the build in tools.
/// But this one will fire as soon as the timeout has been reached and not after
/// the user lets go.
///
class CustomLongPressGestureRecognizer extends TapGestureRecognizer {
  CustomLongPressGestureRecognizer(
      {Object? debugOwner, Duration duration = kLongPressTimeout})
      : this._duration = duration,
        super(debugOwner: debugOwner) {
    super.onTapDown = _onTapDownHandler;
    super.onTapUp = _onTapUpHandler;
    super.onTap = _onTapHandler;
  }

  final Duration _duration;
  Timer? _waitTimer;

  GestureTapCallback? onLongPress;
  GestureTapCallback? _internalOnTap;
  GestureTapDownCallback? _internalOnTapDown;
  GestureTapUpCallback? _internalOnTapUp;

  @override
  set onTapUp(_onTapUp) {
    this._internalOnTapUp = _onTapUp;
  }

  @override
  set onTapDown(_onTapDown) {
    this._internalOnTapDown = _onTapDown;
  }

  @override
  set onTap(_onTap) {
    this._internalOnTap = onTap;
  }

  void _onTapDownHandler(TapDownDetails details) {
    Timer(_duration, () {
      _waitTimer = null;
      this.onLongPress?.call();
    });

    this._internalOnTapDown?.call(details);
  }

  void _onTapUpHandler(TapUpDetails details) {
    _waitTimer?.cancel();
    this._internalOnTapUp?.call(details);
  }

  void _onTapHandler() {
    this._internalOnTap?.call();
  }
}
