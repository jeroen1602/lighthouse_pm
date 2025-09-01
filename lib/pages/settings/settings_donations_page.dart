import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lighthouse_pm/build_options.dart';
import 'package:lighthouse_pm/links.dart';
import 'package:lighthouse_pm/theming.dart';
import 'package:lighthouse_pm/widgets/content_container_widget.dart';
import 'package:url_launcher/url_launcher.dart';

import '../base_page.dart';

const _githubSponsorsColor = Color(0xffdb61a2);

class SettingsSupportPage extends BasePage {
  const SettingsSupportPage({super.key});

  @override
  Widget buildPage(final BuildContext context) {
    final theme = Theme.of(context);
    final theming = Theming.fromTheme(theme);

    final items = <Widget>[
      if (BuildOptions.includeGithubSponsor) ...[
        ListTile(
          title: const Text('Support with Github sponsors'),
          trailing: const Icon(Icons.arrow_forward_ios),
          leading: SvgPicture.asset(
            'assets/images/github-sponsors.svg',
            colorFilter: const ColorFilter.mode(
              _githubSponsorsColor,
              BlendMode.srcIn,
            ),
            width: theming.iconSizeLarge,
            height: theming.iconSizeLarge,
          ),
          onTap: () async {
            await launchUrl(
              Links.githubSponsorsUrl,
              mode: LaunchMode.externalApplication,
            );
          },
        ),
        const Divider(),
      ],
      if (BuildOptions.includePaypal) ...[
        ListTile(
          title: const Text('Support with Paypal.me'),
          trailing: const Icon(Icons.arrow_forward_ios),
          leading: SvgPicture.asset(
            'assets/images/paypal.svg',
            colorFilter: theming.iconColor != null
                ? ColorFilter.mode(theming.iconColor!, BlendMode.srcIn)
                : null,
            width: theming.iconSizeLarge,
            height: theming.iconSizeLarge,
          ),
          onTap: () async {
            await launchUrl(
              Links.paypalMeUrl,
              mode: LaunchMode.externalApplication,
            );
          },
        ),
        const Divider(),
      ],
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Support')),
      body: ContentContainerListView(children: items),
    );
  }
}
