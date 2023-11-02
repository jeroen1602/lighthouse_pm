import 'package:flutter/material.dart';
import 'package:lighthouse_pm/platform_specific/mobile/android/android_launcher_shortcut/android_launcher_shortcut.dart';
import 'package:lighthouse_pm/widgets/content_container_widget.dart';
import 'package:shared_platform/shared_platform.dart';
import 'package:toast/toast.dart';

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

  const BasePage(
      {this.shortcutHandleArgument, this.replace = false, super.key});

  @override
  Widget build(final BuildContext context) {
    ToastContext().init(context);
    ContentScrollbar.updateShowScrollbarSubject(context);
    return _ShortcutLaunchHandleWidget(
        buildPage(context), shortcutHandleArgument, replace);
  }

  Widget buildPage(final BuildContext context);
}

class _ShortcutLaunchHandleWidget extends StatefulWidget {
  final Widget body;
  final ShortcutHandle? handle;
  final bool replace;

  const _ShortcutLaunchHandleWidget(this.body, this.handle, this.replace);

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
    if (SharedPlatform.isAndroid) {
      WidgetsBinding.instance.addPostFrameCallback((final timeStamp) {
        AndroidLauncherShortcut.instance.readyForData();
      });
    }
  }

  @override
  Widget build(final BuildContext context) {
    return StreamBuilder<ShortcutHandle?>(
        stream: _shortcutStream(),
        initialData: null,
        builder: (final BuildContext shortcutContext,
            final AsyncSnapshot<ShortcutHandle?> shortcutSnapshot) {
          WidgetsBinding.instance.addPostFrameCallback((final timeStamp) {
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
  if (SharedPlatform.isAndroid) {
    return AndroidLauncherShortcut.instance.changePowerStateMac;
  } else {
    // This platform doesn't support shortcuts so let's return an empty stream.
    return const Stream.empty();
  }
}
