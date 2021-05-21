import 'package:flutter/material.dart';
import 'package:lighthouse_pm/platformSpecific/mobile/android/androidLauncherShortcut/AndroidLauncherShortcut.dart';
import 'package:lighthouse_pm/platformSpecific/shared/LocalPlatform.dart';

/// The same as a [WidgetBuilder] only require it to return a [BasePage].
typedef PageBuilder = BasePage Function(BuildContext context);

///
/// A base page that has some functions that every page should have.
///
/// For now it just handles the shortcuts
///
abstract class BasePage extends StatelessWidget {
  final ShortcutHandle? shortcutHandleArgument;
  final bool replace;

  const BasePage({Key? key, this.shortcutHandleArgument, this.replace = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _ShortcutLaunchHandleWidget(
        buildPage(context), this.shortcutHandleArgument, replace);
  }

  Widget buildPage(BuildContext context);
}

class _ShortcutLaunchHandleWidget extends StatefulWidget {
  final Widget body;
  final ShortcutHandle? handle;
  final bool replace;

  const _ShortcutLaunchHandleWidget(this.body, this.handle, this.replace,
      {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ShortcutLaunchHandleState();
  }
}

class _ShortcutLaunchHandleState extends State<_ShortcutLaunchHandleWidget> {
  @override
  void initState() {
    super.initState();
    // Notify the Shortcut handler native code that the app is ready for data.
    if (LocalPlatform.isAndroid) {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        AndroidLauncherShortcut.instance.readyForData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ShortcutHandle?>(
        stream: _shortcutStream(),
        initialData: null,
        builder: (BuildContext shortcutContext,
            AsyncSnapshot<ShortcutHandle?> shortcutSnapshot) {
          WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
            if (shortcutSnapshot.data != null &&
                shortcutSnapshot.data != widget.handle) {
              if (widget.replace) {
                Navigator.pushReplacementNamed(context, '/shortcutHandler',
                    arguments: shortcutSnapshot.data);
              } else {
                Navigator.pushNamed(context, '/shortcutHandler',
                    arguments: shortcutSnapshot.data);
              }
            }
          });
          return widget.body;
        });
  }
}

Stream<ShortcutHandle?> _shortcutStream() {
  if (LocalPlatform.isAndroid) {
    return AndroidLauncherShortcut.instance.changePowerStateMac;
  } else {
    // This platform doesn't support shortcuts so let's return an empty stream.
    return Stream.empty();
  }
}
