import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lighthouse_pm/widgets/ContentContainerWidget.dart';
import 'package:url_launcher/url_launcher.dart';

import '../BasePage.dart';

class PrivacyPage extends BasePage {
  static const GITHUB_PAGES_PRIVACY_URL =
      "https://docs.github.com/en/github/site-policy/github-privacy-statement#github-pages";

  @override
  Widget buildPage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Privacy"),
      ),
      body: ContentContainerWidget(builder: (context) {
        final theme = Theme.of(context);
        final textTheme = theme.textTheme;
        final linkTheme = textTheme.bodyText1?.copyWith(
            color: theme.accentColor, decoration: TextDecoration.underline);

        return Padding(
            padding: EdgeInsets.all(10.0),
            child: ListView(children: <Widget>[
              ListTile(
                title: Text(
                  "Version 1.1",
                  style: textTheme.bodyText1
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                  padding: EdgeInsets.fromLTRB(14, 0, 14, 0),
                  child: RichText(
                      text: TextSpan(style: textTheme.bodyText1, children: [
                    TextSpan(
                        text: "This privacy statement is the same for all "
                            "versions of this (web)app, it is divided in "
                            "a part for all versions. One for the web "
                            "version, one for the Android/ iOS version and "
                            "one for just the Android version.\n\n"),
                    TextSpan(text: 'Global\n\n', style: textTheme.headline5),
                    TextSpan(
                        text: "This (web)app does not collect any user "
                            "information. The Android and iOS versions don't "
                            "even have the internet permission to share any "
                            "possibly collected information. The web app "
                            "however is hosted using Github pages. Github and "
                            "it's service, Github pages, have their own "
                            "privacy statement. In this statement Github says "
                            "that they collect basic information from visitors "
                            "for legal obligations. Check the "),
                    TextSpan(
                        style: linkTheme,
                        text: "Github privacy statement",
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launch(PrivacyPage.GITHUB_PAGES_PRIVACY_URL);
                          }),
                    TextSpan(
                        text: " if you want more, and up-to-date "
                            "information.\n\n"),
                    TextSpan(text: 'Web app\n\n', style: textTheme.headline5),
                    TextSpan(
                        text: "The web app will only communicate with the "
                            "devices you (the user) give access to when you "
                            "click on the pair button. The browser will "
                            "remember the devices you have given access to. "
                            "The web app will try to re-connect to the paired "
                            "devices everytime you click the scan button "
                            "(or load the main page).\n"
                            "There is currently no way to revoke access to an "
                            "already paired device. The only way to do this is "
                            "to go to the site settings and forget the site.\n"
                            "If you select a non-lighthouse device from the "
                            "pair list then it will not show up in the "
                            "lighthouses list, because it will not pass the "
                            "tests to check if it's a real device. The "
                            "website will however try to communicate with it "
                            "to determine if it's a valid lighthouse device. "
                            "This happens when you first pair or every time "
                            "you scan for devices.\n\n"),
                    TextSpan(
                        text: "Android and iOS\n\n",
                        style: textTheme.headline5),
                    TextSpan(
                        text: "Everytime you scan for lighthouses, you also "
                            "scan for all Bluetooth low energy (BLE) devices "
                            "in your range. Before the app connects to any "
                            "device, it must first pass a name check. For "
                            "example, a Lighthouse V2 device's name must start "
                            "with \"LHB-\". If the name check doesn't pass "
                            "then it will not be considered as a valid "
                            "device, and the app won't connect to it. "
                            "\n\n"),
                    TextSpan(text: "Android\n\n", style: textTheme.headline5),
                    TextSpan(
                        text: "If you want to connect to a Bluetooth low "
                            "energy device from an Android phone, then you "
                            "will need to aks for location permissions. This "
                            "is because an app that uses Bluetooth low "
                            "energy could technically triangulate a devices'"
                            "location. An app that has the location "
                            "permissions also has access to the GPS module. "
                            "Lighthouse Power management does not use the GPS "
                            "module and only uses the Bluetooth low energy "
                            "functionality.\n\n"),
                  ]))),
              ListTile(
                title: Text(
                  "Older versions",
                  style: textTheme.headline4
                      ?.copyWith(color: textTheme.bodyText1?.color),
                ),
              ),
              Divider(
                thickness: 1.5,
              ),
              ListTile(
                title: Text(
                  "Version 1.0",
                  style: textTheme.bodyText1
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("pre may 23th 2021"),
              ),
              Padding(
                  padding: EdgeInsets.fromLTRB(14, 0, 14, 0),
                  child: RichText(
                    text: TextSpan(style: textTheme.bodyText1, children: [
                      TextSpan(
                          text: "This app does not collect any user "
                              "information. In fact this app doesn't even "
                              "have the internet permission, so it can't make "
                              "any internet connections to share any data.\n\n"),
                      TextSpan(text: "Android\n\n", style: textTheme.headline5),
                      TextSpan(
                          text: "For Android, in order for an app to use "
                              "Bluetooth Low Energy (BLE), the technology used "
                              "to communicate with the lighthouses, it needs "
                              "to request location permissions. This is "
                              "because an app that uses BLE could technically "
                              "triangulate a device's location. An app that "
                              "has the location permissions could also use the "
                              "GPS module in the device. Lighthouse PM does "
                              "not use the GPS module in a device and only "
                              "uses the BLE functionality. It also only "
                              "searches for the lighthouses and ignores any "
                              "other devices the area.")
                    ]),
                  )),
            ]));
      }),
    );
  }
}
