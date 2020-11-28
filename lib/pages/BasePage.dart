import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lighthouse_pm/platformSpecific/android/Shortcut.dart';

///
/// A base page that has some functions that every page should have.
///
/// For now it just handles the shortcuts
///
abstract class BasePage extends StatelessWidget {
  final ShortcutHandle /* ? */ shortcutHandleArgument;

  const BasePage({Key key, this.shortcutHandleArgument}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _ShortcutLaunchHandleWidget(
        buildPage(context), this.shortcutHandleArgument);
  }

  Widget buildPage(BuildContext context);
}

class _ShortcutLaunchHandleWidget extends StatefulWidget {
  final Widget body;
  final ShortcutHandle /* ? */ handle;

  const _ShortcutLaunchHandleWidget(this.body, this.handle, {Key key})
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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Shortcut.instance.readyForData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ShortcutHandle /* ? */ >(
        stream: _shortcutStream(),
        initialData: null,
        builder: (BuildContext shortcutContext,
            AsyncSnapshot<ShortcutHandle /* ? */ > shortcutSnapshot) {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            if (shortcutSnapshot.data != null &&
                shortcutSnapshot.data != widget.handle) {
              Navigator.pushNamed(context, '/shortcutHandler',
                  arguments: shortcutSnapshot.data);
            }
          });
          return widget.body;
        });
  }
}

Stream<ShortcutHandle /* ? */ > _shortcutStream() {
  if (Platform.isAndroid) {
    return Shortcut.instance.changePowerStateMac;
  } else {
    // This platform doesn't support shortcuts so let's return an empty stream.
    return Stream.empty();
  }
}
