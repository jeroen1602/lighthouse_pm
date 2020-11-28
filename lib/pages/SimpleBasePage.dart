import 'package:flutter/widgets.dart';
import 'package:lighthouse_pm/platformSpecific/android/Shortcut.dart';

import './BasePage.dart';

///
/// A very simple [BasePage] implementation for testing!
/// This should not be used in release, but I can't throw an error or else
/// debug will also complain.
///
class SimpleBasePage extends BasePage {
  final Widget _body;

  SimpleBasePage(this._body, {Key key, ShortcutHandle shortcutHandleArgument})
      : super(key: key, shortcutHandleArgument: shortcutHandleArgument);

  @override
  Widget buildPage(BuildContext context) {
    return _body;
  }
}
