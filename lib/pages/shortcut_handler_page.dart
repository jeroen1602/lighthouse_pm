import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lighthouse_pm/platform_specific/mobile/android/android_launcher_shortcut/android_launcher_shortcut.dart';
import 'package:lighthouse_pm/widgets/close_current_route_mixin.dart';

import 'base_page.dart';
import 'shortcut/mac_shortcut_handle.dart';

class ShortcutHandlerPage extends BasePage {
  final Object? handle;

  const ShortcutHandlerPage(this.handle, {final Key? key})
      : super(
            key: key,
            shortcutHandleArgument: handle as ShortcutHandle?,
            replace: true);

  @override
  Widget buildPage(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shortcut'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
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

  const ShortcutHandlerWidget(this.handle, {final Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // ignore_for_file: no_logic_in_create_state
    if (handle == null || handle is! ShortcutHandle) {
      return _ShortcutHandleNullState();
    }
    if (shortcutHandle.type == ShortcutTypes.macType) {
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
  Widget build(final BuildContext context) {
    if (!kReleaseMode) {
      return const Text('Not sure how you got here\n'
          'If you do know please create an issue as you shouldn\'t be here right now');
    } else {
      return const Text('shortcut Handle is `null`. How did you get here!?');
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((final _) {
      widget.closeCurrentRouteWithWait(context);
    });
  }
}
