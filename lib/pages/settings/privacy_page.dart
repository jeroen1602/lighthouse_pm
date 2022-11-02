import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lighthouse_pm/links.dart';
import 'package:lighthouse_pm/theming.dart';
import 'package:lighthouse_pm/widgets/content_container_widget.dart';
import 'package:url_launcher/url_launcher.dart';

import '../base_page.dart';

class _NotesCounter {
  final List<String> _values = [];

  int getValue(final String name) {
    final index = _values.indexOf(name);
    if (index >= 0) {
      return index + 1;
    }
    _values.add(name);
    return _values.length;
  }
}

class PrivacyPage extends BasePage {
  const PrivacyPage({final Key? key}) : super(key: key);

  static const version1_1Date = "January 1st 2022";

  static const superScript = ["⁰", "¹", "²", "³", "⁴", "⁵", "⁶", "⁷", "⁸", "⁹"];

  static String toSuperScript(int number) {
    final negative = number < 0;
    number = number.abs();
    String out = "";
    while (number != 0) {
      final current = number % 10;
      out = "${superScript[current]}$out";
      number ~/= 10;
    }
    if (negative) {
      return "⁻$out";
    }
    return out;
  }

  static final _notesCounter = _NotesCounter();

  static get _neverLeaveDevice => _notesCounter.getValue("neverLeaveDevice");

  static get _identifierNote => _notesCounter.getValue("identifierNote");

  static get _lastSeenValidDevices =>
      _notesCounter.getValue("lastSeenValidDevices");

  static get _userGeneratedData => _notesCounter.getValue("userGeneratedData");

  @override
  Widget buildPage(final BuildContext context) {
    final theming = Theming.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy"),
      ),
      body: ContentContainerListView(children: [
        ListTile(
          title: Text(
            "Version 1.1",
            style: theming.bodyTextBold,
          ),
          subtitle: const Text("Post $version1_1Date"),
        ),
        Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
            child: RichText(
                text: TextSpan(style: theming.bodyText, children: [
              const TextSpan(
                  text: "This privacy statement is the same for all "
                      "versions of this (web)app, it is divided in "
                      "a part for all versions. One for the web "
                      "version, one for the Android/ iOS version and "
                      "one for just the Android version.\n\n"),
              TextSpan(text: 'Global\n\n', style: theming.headline5),
              const TextSpan(
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
                  style: theming.linkTheme,
                  text: "Github privacy statement",
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      launchUrl(Links.githubPagesPrivacyUrl,
                          mode: LaunchMode.externalApplication);
                    }),
              const TextSpan(
                  text: " if you want more, and up-to-date "
                      "information.\n\n"),
              TextSpan(
                  text: "This doesn't mean that this app doesn't "
                      "handle any user information. The data that is collected "
                      "will only be stored on your device"
                      "${toSuperScript(_neverLeaveDevice)}, be it a phone or "
                      "a desktop web browser. The data collected include:\n\n"
                      " • Bluetooth low energy device identifier.${toSuperScript(_identifierNote)}\n"
                      " • Date and time of last seen valid devices.${toSuperScript(_lastSeenValidDevices)}\n"
                      " • User generated data.${toSuperScript(_userGeneratedData)}\n"
                      "\n"),
              TextSpan(
                  text: "${toSuperScript(_neverLeaveDevice)}"
                      "While the app doesn't have any build in mechanisms to "
                      "export data, that doesn't mean that it will never leave "
                      "the device. If you yourself decide to export the data of "
                      "from for example the web version using the developer "
                      "tools then it could leave the device. Another way is if "
                      "you choose to take your apps with you to a new device on "
                      "Android. In this case the locally stored information will "
                      "transferred over to the new device by the Android system. "
                      "See "),
              TextSpan(
                  style: theming.linkTheme,
                  text: "Switch to a new Android phone",
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      launchUrl(Links.androidSwitchToNewPhone,
                          mode: LaunchMode.externalApplication);
                    }),
              const TextSpan(text: " for more info.\n\n"),
              TextSpan(
                text: "${toSuperScript(_identifierNote)}"
                    "This identifier varies per version of the app, "
                    "on Android This will be the actual mac address of the "
                    "Bluetooth device, while on iOS and the web it will be a "
                    "randomly generated string. These identifiers are used "
                    "to bind information to these devices, for example a "
                    "nickname. And to manage connections, for example making "
                    "sure the same device is not connected to twice, or a "
                    "known to be invalid device isn't connected to again.\n\n",
              ),
              TextSpan(
                text: "${toSuperScript(_lastSeenValidDevices)}"
                    "A valid device means a deice that this app is able to "
                    "communicate with, so a Valve Lighthouse or a "
                    "vive Base station if enabled in the settings. "
                    "This information is bound to the device identifier.\n\n",
              ),
              TextSpan(
                text: "${toSuperScript(_userGeneratedData)}"
                    "User generated data means in this case the data a user "
                    "inputs themself. This includes a nickname for a device, "
                    "the name of a group and the device that are inside it, "
                    "all the settings on the settings page, the "
                    "pairing id needed for vive base stations.\n\n",
              ),
              TextSpan(text: 'Web app\n\n', style: theming.headline5),
              const TextSpan(
                  text: "The web app will only communicate with the "
                      "devices you (the user) give access to when you "
                      "click on the pair button. The browser may "
                      "remember the devices you have given access to. "
                      "This depends on what bluetooth features your browser "
                      "supports. The web app will try to re-connect to the "
                      "paired devices everytime you click the scan button "
                      "(or load the main page).\n"
                      "There is currently no way to revoke access to an "
                      "already paired device. The only way to do this is "
                      "to go to the site settings and forget the site.\n"
                      "If you select a non-lighthouse device from the "
                      "pair list then it will not show up in the "
                      "lighthouses list, because it will not pass the "
                      "tests to check if it's a supported device. The "
                      "website will however try to communicate with it "
                      "to determine if it's a valid lighthouse device. "
                      "This happens when you first pair or every time "
                      "you scan for devices.\n\n"),
              TextSpan(text: "Android and iOS\n\n", style: theming.headline5),
              const TextSpan(
                  text: "Everytime you scan for lighthouses, you also "
                      "scan for all Bluetooth low energy (BLE) devices "
                      "in your range. Before the app connects to any "
                      "device, it must first pass a name check. For "
                      "example, a Lighthouse V2 device's name must start "
                      "with \"LHB-\". If the name check doesn't pass "
                      "then it will not be considered as a valid "
                      "device, and the app won't connect to it. "
                      "\n\n"),
              TextSpan(text: "Android\n\n", style: theming.headline5),
              const TextSpan(
                  text: "If you want to connect to a Bluetooth low "
                      "energy device from an Android phone, running Android 11 or lower,"
                      " then you will need to aks for location permissions. "
                      "This is because an app that uses Bluetooth low "
                      "energy could technically triangulate a devices'"
                      "location. An app that has the location "
                      "permissions also has access to the GPS module. "
                      "Lighthouse Power management does not use the GPS "
                      "module and only uses the Bluetooth low energy "
                      "functionality.\n"),
              TextSpan(
                  text: "Android 12 and higher\n\n", style: theming.headline6),
              const TextSpan(
                  text: "These location permissions are not needed for "
                      "Android 12 and higher, on those devices you will get a "
                      "message asking if you want to allow the app to "
                      "communicate with nearby devices.\n"
                      "Do note that the Android 12 version of the app still has"
                      "the location permission in its manifest for running on "
                      "devices with older versions of Android, but it has "
                      "been marked as never for location, meaning that it "
                      "won't show up in the permission list on the device and "
                      "you will never be asked to accept these permissions. "
                      "If have the app installed that was made for Android 11 "
                      "and upgrade to the Android 12 version, and have Android "
                      "12 installed on your phone, then it may still be in that "
                      "list. You can safely revoke the location permission in "
                      "this case.\n"),
              TextSpan(
                  text: "Google play version\n\n", style: theming.headline6),
              const TextSpan(
                  text: "If you have installed the app via Google play then, "
                      "it will use the Google Billing api to get a list of "
                      "ways to support the app. This uses a connection "
                      "directly to the Google Play Services on your device "
                      "and doesn't share any information about the app. "
                      "Google may however still collect some data through "
                      "this connection. Check the "),
              TextSpan(
                  style: theming.linkTheme,
                  text: "Google privacy Statement",
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      launchUrl(Links.googlePrivacyUrl,
                          mode: LaunchMode.externalApplication);
                    }),
              const TextSpan(
                  text: " for more, and up-to-date information.\n\n"),
            ]))),
        ListTile(
          title: Text(
            "Older versions",
            style: theming.headline4,
          ),
        ),
        const Divider(
          thickness: 1.5,
        ),
        ListTile(
          title: Text(
            "Version 1.0",
            style: theming.bodyTextBold,
          ),
          subtitle: const Text("Pre $version1_1Date"),
        ),
        Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
            child: RichText(
              text: TextSpan(style: theming.bodyText, children: [
                const TextSpan(
                    text: "This app does not collect any user "
                        "information. In fact this app doesn't even "
                        "have the internet permission, so it can't make "
                        "any internet connections to share any data.\n\n"),
                TextSpan(text: "Android\n\n", style: theming.headline5),
                const TextSpan(
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
                        "other devices the area.\n\n")
              ]),
            )),
      ]),
    );
  }
}
