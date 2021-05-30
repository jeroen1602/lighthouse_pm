import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lighthouse_pm/BuildOptions.dart';
import 'package:lighthouse_pm/platformSpecific/mobile/InAppPurchases.dart';
import 'package:lighthouse_pm/platformSpecific/mobile/inAppPurchases/InAppPurchaseItem.dart';
import 'package:lighthouse_pm/widgets/ContentContainerWidget.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../BasePage.dart';
import '../SettingsPage.dart';

const _GITHUB_SPONSORS_URL = "https://github.com/sponsors/jeroen1602/";
const _GITHUB_SPONSORS_COLOR = Color(0xffdb61a2);
const _PAYPAL_ME_URL = "https://paypal.me/jeroen1602";

class SettingsSupportPage extends BasePage {
  @override
  Widget buildPage(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = SettingsPage.getIconColor(theme.iconTheme);

    final items = <Widget>[
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
                  title: Text('${price.title}'),
                  subtitle: Text('${price.price}'),
                  trailing: Icon(Icons.arrow_forward_ios),
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
                Divider(),
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
