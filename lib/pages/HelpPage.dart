import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lighthouse_pm/Theming.dart';
import 'package:lighthouse_pm/bloc.dart';
import 'package:lighthouse_pm/data/local/MainPageSettings.dart';
import 'package:lighthouse_pm/lighthouseProvider/LighthouseProvider.dart';
import 'package:lighthouse_pm/widgets/ContentContainerWidget.dart';
import 'package:url_launcher/url_launcher.dart';

import 'BasePage.dart';

const _GITHUB_ISSUES_URL =
    "https://github.com/jeroen1602/lighthouse_pm/issues/";

///
/// A widget showing the a material scaffold with some help items the user may need.
///
class HelpPage extends BasePage with WithBlocStateless {
  @override
  Widget buildPage(BuildContext context) {
    final theming = Theming.of(context);

    return Scaffold(
        appBar: AppBar(title: const Text('Help')),
        body: MainPageSettings.mainPageSettingsStreamBuilder(
            bloc: blocWithoutListen(context),
            builder: (context, settings) {
              return ContentContainerListView(
                children: [
                  _HelpItem(
                    title: 'Metadata',
                    body: RichText(
                        text: TextSpan(style: theming.bodyText, children: [
                      const TextSpan(
                          text:
                              'Every device has some metadata and extra actions'
                              ' that you may want to access. Like changing the state to '
                              'standby without changing the global setting.\n\n'),
                      const TextSpan(
                          text:
                              'There are two ways to access this feature The first is to '),
                      TextSpan(text: 'tap', style: theming.bodyTextBold),
                      const TextSpan(
                          text:
                              ' on the lighthouse item. The second option is to '),
                      TextSpan(text: 'hold', style: theming.bodyTextBold),
                      const TextSpan(text: ' the '),
                      WidgetSpan(
                          child: Icon(
                        Icons.power_settings_new,
                        size: theming.bodyTextIconSize,
                        color: theming.iconColor,
                      )),
                      TextSpan(text: ' button', style: theming.bodyTextBold),
                      const TextSpan(
                          text:
                              ' of the device you want access the metadata page for.'),
                    ])),
                  ),
                  _HelpItem(
                    title: 'Nickname',
                    body: RichText(
                        text: TextSpan(style: theming.bodyText, children: [
                      const TextSpan(
                          text:
                              'You may want to give a device a nickname to find it more easily in the list of devices.\n\n'),
                      const TextSpan(text: 'To do this '),
                      TextSpan(text: 'hold', style: theming.bodyTextBold),
                      const TextSpan(
                          text: ' the device you want to select to enter '),
                      TextSpan(
                          text: 'selection mode', style: theming.bodyTextBold),
                      const TextSpan(
                          text: '. After entering selection mode click the '),
                      WidgetSpan(
                          child: SvgPicture.asset(
                        'assets/images/nickname-icon.svg',
                        color: theming.iconColor,
                        width: theming.bodyTextIconSize,
                        height: theming.bodyTextIconSize,
                      )),
                      TextSpan(text: 'button', style: theming.bodyTextBold),
                      const TextSpan(
                          text:
                              ' in the toolbar to get a dialog for changing the nickname.\n'),
                      const TextSpan(text: 'Leave the nickname '),
                      TextSpan(text: 'blank', style: theming.bodyTextBold),
                      const TextSpan(
                          text: ' if you want to remove the nickname.')
                    ])),
                  ),
                  _HelpItem(
                      title: 'Group',
                      body: RichText(
                        text: TextSpan(style: theming.bodyText, children: [
                          const TextSpan(
                              text:
                                  'Grouping items together makes it easier for '
                                  'you to change the state of the devices at the '
                                  'same time.\n\n'),
                          TextSpan(
                              text: 'Group items\n', style: theming.headline6),
                          const TextSpan(text: 'To group items '),
                          TextSpan(text: 'hold', style: theming.bodyTextBold),
                          const TextSpan(
                              text: ' the devices you want to add to the '
                                  'group. Click on the '),
                          WidgetSpan(
                              child: SvgPicture.asset(
                            'assets/images/group-add-icon.svg',
                            color: theming.iconColor,
                            width: theming.bodyTextIconSize,
                            height: theming.bodyTextIconSize,
                          )),
                          TextSpan(
                              text: ' button', style: theming.bodyTextBold),
                          const TextSpan(
                              text: ' in the dialog that pops up select the'
                                  'group you want to add the items to, '
                                  'or create a new one. You can also select '),
                          WidgetSpan(
                            child: Icon(Icons.clear,
                                size: theming.bodyTextIconSize,
                                color: theming.iconColor),
                          ),
                          TextSpan(
                              text: 'No Group', style: theming.bodyTextBold),
                          const TextSpan(
                              text:
                                  ' to remove the items from the group they are in.\n\n'),
                          TextSpan(
                              text: 'Edit group\n', style: theming.headline6),
                          const TextSpan(text: 'To edit a group name either '),
                          TextSpan(text: 'hold', style: theming.bodyTextBold),
                          const TextSpan(
                              text: ' the group header to select the group. '),
                          const TextSpan(
                              text: 'Or manually select select all the items '
                                  'under the group.\n'),
                          const TextSpan(text: 'After that click the '),
                          WidgetSpan(
                              child: SvgPicture.asset(
                            'assets/images/group-edit-icon.svg',
                            color: theming.iconColor,
                            width: theming.bodyTextIconSize,
                            height: theming.bodyTextIconSize,
                          )),
                          TextSpan(
                              text: ' button', style: theming.bodyTextBold),
                          const TextSpan(
                              text:
                                  '. After that change the name in the dialog.\n\n'),
                          TextSpan(
                              text: 'Remove group\n', style: theming.headline6),
                          const TextSpan(
                              text: 'To remove a group first follow the first '
                                  'steps of '),
                          TextSpan(
                              text: 'Edit Group', style: theming.bodyTextBold),
                          const TextSpan(
                              text: ' to select the group to remove.\n'),
                          const TextSpan(text: 'After that click the '),
                          WidgetSpan(
                              child: SvgPicture.asset(
                            'assets/images/group-delete-icon.svg',
                            color: theming.iconColor,
                            width: theming.bodyTextIconSize,
                            height: theming.bodyTextIconSize,
                          )),
                          TextSpan(
                              text: ' button', style: theming.bodyTextBold),
                          const TextSpan(
                              text: ' and confirm that you want to remove the '
                                  'group.\nThe items in the group will automatically '
                                  'be removed.'),
                        ]),
                      )),
                  if (LighthouseProvider.instance.getPairBackEnds().length > 0)
                    _HelpItem(
                        title: 'Pairing a device',
                        body: RichText(
                          text: TextSpan(style: theming.bodyText, children: [
                            const TextSpan(
                                text:
                                    'You will need to pair a lighthouse before you can communicate with it. To do this, go to the main page and click on the '),
                            WidgetSpan(
                              child: Icon(Icons.bluetooth_connected,
                                  size: theming.bodyTextIconSize,
                                  color: theming.iconColor),
                            ),
                            TextSpan(text: 'Pair', style: theming.bodyTextBold),
                            const TextSpan(
                                text:
                                    ' button. After this select the device you want to connect with from the list.\n'),
                            const TextSpan(
                                text:
                                    'Lighthouses version 2.0 should start with '),
                            TextSpan(text: 'LHB-', style: theming.bodyTextBold),
                            const TextSpan(text: '.\n'),
                            if (settings?.viveBaseStationsEnabled == true) ...[
                              const TextSpan(
                                  text:
                                      'Vive base stations should start with '),
                              TextSpan(
                                  text: 'HTC BS', style: theming.bodyTextBold),
                              const TextSpan(text: '.'),
                            ],
                          ]),
                        )),
                  _HelpItem(
                    title: 'To be extended',
                    body: RichText(
                      text: TextSpan(style: theming.bodyText, children: [
                        const TextSpan(
                            text:
                                'This page will be further extended as needed with more help items.\n\n'),
                        const TextSpan(
                            text:
                                'If you feel something should be explained here, feel free to '),
                        TextSpan(
                            text: 'create an issue on github',
                            style: theming.linkTheme,
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                await launch(_GITHUB_ISSUES_URL);
                              }),
                        const TextSpan(text: '!')
                      ]),
                    ),
                  )
                ],
              );
            }));
  }
}

class _HelpItem extends StatelessWidget {
  const _HelpItem({Key? key, required this.title, required this.body})
      : super(key: key);

  final String title;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final theming = Theming.of(context);

    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theming.headline5,
            textAlign: TextAlign.start,
          ),
          Container(
            height: 10,
          ),
          body,
          const Divider(),
        ],
      ),
    );
  }
}
