import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
        Theme.of(context).textTheme.bodyText2!.copyWith(fontSize: 14);
    final textThemeBold = textTheme.copyWith(fontWeight: FontWeight.bold);
    final headlineTheme = Theme.of(context).textTheme.headline6;
    final iconSize = textTheme.fontSize! + 4;

    return Scaffold(
        appBar: AppBar(title: Text('Help')),
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
                TextSpan(
                    text:
                        'There are two ways to access this feature The first is to '),
                TextSpan(text: 'tap', style: textThemeBold),
                TextSpan(
                    text: ' on the lighthouse item. The second option is to '),
                TextSpan(text: 'hold', style: textThemeBold),
                TextSpan(text: ' the '),
                WidgetSpan(
                    child: Icon(
                  Icons.power_settings_new,
                  size: iconSize,
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
                  size: iconSize,
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
                title: 'Group',
                body: RichText(
                  text: TextSpan(style: textTheme, children: [
                    TextSpan(
                        text: 'Grouping items together makes it easier for '
                            'you to change the state of the devices at the '
                            'same time.\n\n'),
                    TextSpan(text: 'Group items\n', style: headlineTheme),
                    TextSpan(text: 'To group items '),
                    TextSpan(text: 'hold', style: textThemeBold),
                    TextSpan(
                        text: ' the devices you want to add to the '
                            'group. Click on the '),
                    WidgetSpan(
                        child: SvgPicture.asset(
                      'assets/images/group-icon.svg',
                      color: textThemeBold.color,
                      width: iconSize,
                      height: iconSize,
                    )),
                    TextSpan(text: ' button', style: textThemeBold),
                    TextSpan(
                        text: ' in the dialog that pops up select the'
                            'group you want to add the items to, '
                            'or create a new one. You can also select '),
                    WidgetSpan(
                      child: Icon(Icons.clear,
                          size: iconSize, color: textThemeBold.color),
                    ),
                    TextSpan(text: 'No Group', style: textThemeBold),
                    TextSpan(
                        text:
                            ' to remove the items from the group they are in.\n\n'),
                    TextSpan(text: 'Edit group\n', style: headlineTheme),
                    TextSpan(text: 'To edit a group name either '),
                    TextSpan(text: 'hold', style: textThemeBold),
                    TextSpan(text: ' the group header to select the group. '),
                    TextSpan(
                        text: 'Or manually select select all the items '
                            'under the group.\n'),
                    TextSpan(text: 'After that click the '),
                    WidgetSpan(
                        child: SvgPicture.asset(
                      'assets/images/group-edit-icon.svg',
                      color: textThemeBold.color,
                      width: iconSize,
                      height: iconSize,
                    )),
                    TextSpan(text: ' button', style: textThemeBold),
                    TextSpan(
                        text:
                            '. After that change the name in the dialog.\n\n'),
                    TextSpan(text: 'Remove group\n', style: headlineTheme),
                    TextSpan(
                        text: 'To remove a group first follow the first '
                            'steps of '),
                    TextSpan(text: 'Edit Group', style: textThemeBold),
                    TextSpan(text: ' to select the group to remove.\n'),
                    TextSpan(text: 'After that click the '),
                    WidgetSpan(
                        child: SvgPicture.asset(
                      'assets/images/group-delete-icon.svg',
                      color: textThemeBold.color,
                      width: iconSize,
                      height: iconSize,
                    )),
                    TextSpan(text: ' button', style: textThemeBold),
                    TextSpan(
                        text: ' and confirm that you want to remove the '
                            'group.\nThe items in the group will automatically '
                            'be removed.'),
                  ]),
                )),
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
  _HelpItem({Key? key, required this.title, required this.body})
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
