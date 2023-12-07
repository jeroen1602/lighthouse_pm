import 'dart:async';

import 'package:flutter/gestures.dart';

///
/// Almost the same as the [LongPressGestureRecognizer] from the build in tools.
/// But this one will fire as soon as the timeout has been reached and not after
/// the user lets go.
///
class CustomLongPressGestureRecognizer extends TapGestureRecognizer {
  CustomLongPressGestureRecognizer(
      {super.debugOwner, final Duration duration = kLongPressTimeout})
      : _duration = duration {
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
  set onTapUp(final onTapUp) {
    _internalOnTapUp = onTapUp;
  }

  @override
  set onTapDown(final onTapDown) {
    _internalOnTapDown = onTapDown;
  }

  @override
  set onTap(final onTap) {
    _internalOnTap = onTap;
  }

  void _onTapDownHandler(final TapDownDetails details) {
    Timer(_duration, () {
      _waitTimer = null;
      onLongPress?.call();
    });

    _internalOnTapDown?.call(details);
  }

  void _onTapUpHandler(final TapUpDetails details) {
    _waitTimer?.cancel();
    _internalOnTapUp?.call(details);
  }

  void _onTapHandler() {
    _internalOnTap?.call();
  }
}
