import 'package:flutter/widgets.dart';
import 'package:shared_platform/shared_platform.dart';

const _exitWaitTime = 5;

abstract class CloseCurrentRouteMixin {
  Future<void> closeCurrentRouteWithWait(final BuildContext context) async {
    await Future.delayed(const Duration(seconds: _exitWaitTime));
    await closeCurrentRoute(context);
  }

  Future<void> closeCurrentRoute(final BuildContext context) async {
    Navigator.pop(context);
    final bool canPop = Navigator.canPop(context);
    if (!canPop) {
      if (SharedPlatform.isAndroid) {
        // This is not recommended for iOS but this code should only be run
        // on Android.
        SharedPlatform.exit(0);
      } else {
        Navigator.pushNamed(context, Navigator.defaultRouteName);
      }
    }
  }
}
