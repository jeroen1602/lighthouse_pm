import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lighthouse_pm/build_options.dart';
import 'package:lighthouse_pm/platform_specific/mobile/in_app_purchases.dart';
import 'package:lighthouse_pm/platform_specific/mobile/in_app_purchases/in_app_purchase_item.dart';
import 'package:lighthouse_pm/theming.dart';
import 'package:lighthouse_pm/widgets/content_container_widget.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../base_page.dart';

const _githubSponsorsUrl = "https://github.com/sponsors/jeroen1602/";
const _githubSponsorsColor = Color(0xffdb61a2);
const _paypalMeUrl = "https://paypal.me/jeroen1602";

class SettingsSupportPage extends BasePage {
  @override
  Widget buildPage(BuildContext context) {
    final theming = Theming.of(context);

    final items = <Widget>[
      if (BuildOptions.includeGithubSponsor) ...[
        ListTile(
          title: const Text('Support with Github sponsors'),
          trailing: const Icon(Icons.arrow_forward_ios),
          leading: SvgPicture.asset(
            'assets/images/github-sponsors.svg',
            color: _githubSponsorsColor,
            width: theming.iconSizeLarge,
            height: theming.iconSizeLarge,
          ),
          onTap: () async {
            await launch(_githubSponsorsUrl);
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
            color: theming.iconColor,
            width: theming.iconSizeLarge,
            height: theming.iconSizeLarge,
          ),
          onTap: () async {
            await launch(_paypalMeUrl);
          },
        ),
        const Divider(),
      ],
      if (BuildOptions.includeGooglePlayInAppPurchases) ...[
        FutureBuilder<List<InAppPurchaseItem>>(
          future: InAppPurchases.instance
              .handlePendingPurchases()
              .then((e) => InAppPurchases.instance.requestPrices()),
          builder: (BuildContext context,
              AsyncSnapshot<List<InAppPurchaseItem>> pricesSnapshot) {
            if (pricesSnapshot.hasError) {
              final error = pricesSnapshot.error;
              debugPrint(error.toString());
              if (error is PlatformException) {
                if (error.code == "0" &&
                    error.details is String &&
                    (error.details as String).contains("less than 3")) {
                  return Container(
                    color: Colors.red,
                    child: ListTile(
                      title: Text("Could not get support items"),
                      subtitle:
                          Text("Maybe you're not logged into Google Play"),
                    ),
                  );
                }
              }
              return Container(
                color: Colors.red,
                child: ListTile(
                  title: Text('Something went wrong'),
                  subtitle: Text('${pricesSnapshot.error}'),
                ),
              );
            }
            final prices = pricesSnapshot.data;
            if (prices == null) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (prices.isEmpty) {
              return Container(
                color: Colors.red,
                child: ListTile(
                  title: Text("Could not get support items"),
                  subtitle:
                      Text("Check to see if you have an internet connection"),
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
                      Toast.show("Thanks for the support!", context,
                          duration: Toast.lengthLong);
                    } else if (result == 1) {
                      Toast.show("Purchase is still pending", context,
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
