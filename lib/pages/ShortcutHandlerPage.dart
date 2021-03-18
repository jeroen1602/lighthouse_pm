import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lighthouse_pm/platformSpecific/android/AndroidLauncherShortcut.dart';
import 'package:lighthouse_pm/widgets/CloseCurrentRouteMixin.dart';

import 'BasePage.dart';
import 'shortcut/MacShortcutHandle.dart';

class ShortcutHandlerPage extends BasePage {
  final Object? handle;

  ShortcutHandlerPage(this.handle, {Key? key})
      : super(
            key: key,
            shortcutHandleArgument: handle as ShortcutHandle?,
            replace: true);

  @override
  Widget buildPage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shortcut'),
      ),
      body: Padding(
        padding: EdgeInsets.all(25),
        child: Center(
          child: ShortcutHandlerWidget(handle),
        ),
      ),
    );
  }
}

class ShortcutHandlerWidget extends StatefulWidget with CloseCurrentRouteMixin {
  final Object? handle;

  ShortcutHandle get shortcutHandle => handle as ShortcutHandle;

  const ShortcutHandlerWidget(this.handle, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    if (handle == null || !(handle is ShortcutHandle)) {
      return _ShortcutHandleNullState();
    }
    if (shortcutHandle.type == ShortcutTypes.MAC_TYPE) {
      return ShortcutHandleMacState();
    }
    // From here on out, this should never happen. But just in case.
    if (kReleaseMode) {
      return _ShortcutHandleNullState();
    }
    throw NoSuchMethodError.withInvocation(
        this,
        Invocation.method(
            Symbol("createStateHandler for ${shortcutHandle.data}"), []));
  }
}

class _ShortcutHandleNullState extends State<ShortcutHandlerWidget> {
  @override
  Widget build(BuildContext context) {
    if (!kReleaseMode) {
      return Text('Not sure how you got here\n'
          'If you do know please create an issue as you shouldn\'t be here right now');
    } else {
      return Text('shortcut Handle is `null`. How did you get here!?');
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      widget.closeCurrentRouteWithWait(context);
    });
  }
}
