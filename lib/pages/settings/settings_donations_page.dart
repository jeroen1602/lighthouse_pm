import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lighthouse_pm/build_options.dart';
import 'package:lighthouse_pm/links.dart';
import 'package:lighthouse_pm/platform_specific/mobile/in_app_purchases.dart';
import 'package:lighthouse_pm/platform_specific/mobile/in_app_purchases/in_app_purchase_item.dart';
import 'package:lighthouse_pm/theming.dart';
import 'package:lighthouse_pm/widgets/content_container_widget.dart';
import 'package:toast/toast.dart';
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
            colorFilter:
                const ColorFilter.mode(_githubSponsorsColor, BlendMode.srcIn),
            width: theming.iconSizeLarge,
            height: theming.iconSizeLarge,
          ),
          onTap: () async {
            await launchUrl(Links.githubSponsorsUrl,
                mode: LaunchMode.externalApplication);
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
            await launchUrl(Links.paypalMeUrl,
                mode: LaunchMode.externalApplication);
          },
        ),
        const Divider(),
      ],
      if (BuildOptions.includeGooglePlayInAppPurchases) ...[
        FutureBuilder<List<InAppPurchaseItem>>(
          future: InAppPurchases.instance
              .handlePendingPurchases()
              .then((final e) => InAppPurchases.instance.requestPrices()),
          builder: (final BuildContext context,
              final AsyncSnapshot<List<InAppPurchaseItem>> pricesSnapshot) {
            if (pricesSnapshot.hasError) {
              final error = pricesSnapshot.error;
              debugPrint(error.toString());
              if (error is PlatformException) {
                if (error.code == "0" &&
                    error.details is String &&
                    (error.details as String).contains("less than 3")) {
                  return Container(
                    color: theme.colorScheme.errorContainer,
                    child: ListTile(
                      title: Text(
                        "Could not get support items",
                        style: theming.bodyMedium?.copyWith(
                            color: theme.colorScheme.onErrorContainer),
                      ),
                      subtitle: Text(
                        "Maybe you're not logged into Google Play",
                        style: theming.bodyMedium?.copyWith(
                            color: theme.colorScheme.onErrorContainer
                                .withOpacity(0.75)),
                      ),
                    ),
                  );
                }
              }
              return Container(
                color: theme.colorScheme.errorContainer,
                child: ListTile(
                  title: Text(
                    'Something went wrong',
                    style: theming.bodyMedium
                        ?.copyWith(color: theme.colorScheme.onErrorContainer),
                  ),
                  subtitle: Text(
                    '${pricesSnapshot.error}',
                    style: theming.bodyMedium?.copyWith(
                        color: theme.colorScheme.onErrorContainer
                            .withOpacity(0.75)),
                  ),
                ),
              );
            }
            final prices = pricesSnapshot.data;
            if (prices == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (prices.isEmpty) {
              return Container(
                color: theme.colorScheme.errorContainer,
                child: ListTile(
                  title: Text(
                    "Could not get support items",
                    style: theming.bodyMedium
                        ?.copyWith(color: theme.colorScheme.onErrorContainer),
                  ),
                  subtitle: Text(
                    "Check to see if you have an internet connection",
                    style: theming.bodyMedium?.copyWith(
                        color: theme.colorScheme.onErrorContainer
                            .withOpacity(0.75)),
                  ),
                ),
              );
            }
            final children = <Widget>[];
            for (final price in prices) {
              children.addAll([
                ListTile(
                  title: Text(price.title),
                  subtitle: Text(price.price),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () async {
                    final result = await InAppPurchases.instance
                        .startBillingFlow(price.id);
                    if (result == 0) {
                      Toast.show("Thanks for the support!",
                          duration: Toast.lengthLong);
                    } else if (result == 1) {
                      Toast.show("Purchase is still pending",
                          duration: Toast.lengthLong);
                    }
                  },
                ),
                const Divider(),
              ]);
            }
            return Column(
              children: children,
            );
          },
        )
      ],
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Support')),
      body: ContentContainerListView(children: items),
    );
  }
}
