import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import './BasePage.dart';

const _GITHUB_ISSUES_URL =
    "https://github.com/jeroen1602/lighthouse_pm/issues/";

///
/// A widget showing the a material scaffold with some help items the user may need.
///
class HelpPage extends BasePage {
  @override
  Widget buildPage(BuildContext context) {
    final textTheme =
        Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 14);
    final textThemeBold = textTheme.copyWith(fontWeight: FontWeight.bold);

    return Scaffold(
        appBar: AppBar(title: Text('Troubleshooting')),
        body: ListView(
          children: [
            _HelpItem(
              title: 'Metadata',
              body: RichText(
                  text: TextSpan(style: textTheme, children: [
                TextSpan(
                    text: 'Every device has some metadata and extra actions'
                        ' that you may want to access. Like changing the state to '
                        'standby without changing the global setting.\n\n'),
                TextSpan(text: 'There are two ways to access this feature The first is to '),
                    TextSpan(text: 'tap', style:textThemeBold),
                TextSpan(text: ' on the lighthouse item. The second option is to '),
                TextSpan(text: 'hold', style: textThemeBold),
                TextSpan(text: ' the '),
                WidgetSpan(
                    child: Icon(
                  Icons.power_settings_new,
                  size: textTheme.fontSize + 4,
                  color: textThemeBold.color,
                )),
                TextSpan(text: ' button', style: textThemeBold),
                TextSpan(
                    text:
                        ' of the device you want access the metadata page for.'),
              ])),
            ),
            _HelpItem(
              title: 'Nickname',
              body: RichText(
                  text: TextSpan(style: textTheme, children: [
                TextSpan(
                    text:
                        'You may want to give a device a nickname to find it more easily in the list of devices.\n\n'),
                TextSpan(text: 'To do this '),
                TextSpan(text: 'hold', style: textThemeBold),
                TextSpan(text: ' the device you want to select to enter '),
                TextSpan(text: 'selection mode', style: textThemeBold),
                TextSpan(text: '. After entering selection mode click the '),
                WidgetSpan(
                    child: Icon(
                  Icons.edit_attributes,
                  size: textTheme.fontSize + 4,
                  color: textThemeBold.color,
                )),
                TextSpan(text: 'button', style: textThemeBold),
                TextSpan(
                    text:
                        ' in the toolbar to get a dialog for changing the nickname.\n'),
                TextSpan(text: 'Leave the nickname '),
                TextSpan(text: 'blank', style: textThemeBold),
                TextSpan(text: ' if you want to remove the nickname.')
              ])),
            ),
            _HelpItem(
              title: 'To be extended',
              body: RichText(
                text: TextSpan(style: textTheme, children: [
                  TextSpan(
                      text:
                          'This page will be further extended as needed with more help items.\n\n'),
                  TextSpan(
                      text:
                          'If you feel something should be explained here, feel free to '),
                  TextSpan(
                      text: 'create an issue on github',
                      style: textTheme.copyWith(
                          color: Colors.blue,
                          decoration: TextDecoration.underline),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          await launch(_GITHUB_ISSUES_URL);
                        }),
                  TextSpan(text: '!')
                ]),
              ),
            )
          ],
        ));
  }
}

class _HelpItem extends StatelessWidget {
  _HelpItem({Key key, @required this.title, @required this.body})
      : super(key: key);

  final String title;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headline5,
            textAlign: TextAlign.start,
          ),
          Container(
            height: 10,
          ),
          body,
          Divider(),
        ],
      ),
    );
  }
}
