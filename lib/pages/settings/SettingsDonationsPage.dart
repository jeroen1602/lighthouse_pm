import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lighthouse_pm/BuildOptions.dart';
import 'package:lighthouse_pm/widgets/ContentContainerWidget.dart';
import 'package:url_launcher/url_launcher.dart';

import '../BasePage.dart';
import '../SettingsPage.dart';

const _GITHUB_SPONSORS_URL = "https://github.com/sponsors/jeroen1602/";
const _GITHUB_SPONSORS_COLOR = Color(0xffdb61a2);
const _PAYPAL_ME_URL = "https://paypal.me/jeroen1602";

class SettingsDonationsPage extends BasePage {
  @override
  Widget buildPage(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = SettingsPage.getIconColor(theme.iconTheme);
    final headTheme =
        theme.textTheme.headline6?.copyWith(fontWeight: FontWeight.bold);

    final items = <Widget>[
      ListTile(
        title: Text('Donate', style: headTheme),
      ),
      Divider(
        thickness: 1.5,
      ),
      if (BuildOptions.includeGithubSponsor) ...[
        ListTile(
          title: Text('Support with Github sponsors'),
          trailing: Icon(Icons.arrow_forward_ios),
          leading: SvgPicture.asset(
            'assets/images/github-sponsors.svg',
            color: _GITHUB_SPONSORS_COLOR,
            width: 24,
            height: 24,
          ),
          onTap: () async {
            await launch(_GITHUB_SPONSORS_URL);
          },
        ),
        Divider(),
      ],
      if (BuildOptions.includePaypal) ...[
        ListTile(
          title: Text('Support with Paypal.me'),
          trailing: Icon(Icons.arrow_forward_ios),
          leading: SvgPicture.asset(
            'assets/images/paypal.svg',
            color: iconColor,
            width: 24,
            height: 24,
          ),
          onTap: () async {
            await launch(_PAYPAL_ME_URL);
          },
        ),
        Divider(),
      ],
    ];

    return Scaffold(
        appBar: AppBar(title: Text('Donate')),
        body: ContentContainerWidget(
          builder: (context) {
            return ListView(children: items);
          },
        ));
  }
}
