import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lighthouse_pm/bloc.dart';
import 'package:lighthouse_pm/data/dao/SettingsDao.dart';
import 'package:lighthouse_pm/lighthouseProvider/LighthousePowerState.dart';
import 'package:lighthouse_pm/platformSpecific/android/AndroidLauncherShortcut.dart';
import 'package:lighthouse_pm/widgets/ClearLastSeenAlertWidget.dart';
import 'package:lighthouse_pm/widgets/DropdownMenuListTile.dart';
import 'package:lighthouse_pm/widgets/ShortcutAlertWidget.dart';
import 'package:lighthouse_pm/widgets/ViveBaseStationAlertWidget.dart';
import 'package:package_info/package_info.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

import './BasePage.dart';
import 'settings/PrivacyPage.dart';
import 'settings/SettingsNicknamesPage.dart';
import 'settings/SettingsViveBaseStationIdsPage.dart';

const _GITHUB_URL = "https://github.com/jeroen1602/lighthouse_pm";

class SettingsPage extends BasePage with WithBlocStateless {
  Future<List<ThemeMode>> _getSupportedThemeModes() async {
    if (await SettingsDao.supportsThemeModeSystem) {
      return [ThemeMode.light, ThemeMode.dark, ThemeMode.system];
    } else {
      return [ThemeMode.light, ThemeMode.dark];
    }
  }

  String _themeModeToString(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.system:
        return "System";
      case ThemeMode.dark:
        return "Dark";
      case ThemeMode.light:
        return "Light";
      default:
        return "UNKNOWN";
    }
  }

  @override
  Widget buildPage(BuildContext context) {
    final theme = Theme.of(context);

    final items = <Widget>[
      ListTile(
        leading: SvgPicture.asset(
          "assets/images/app-icon.svg",
          width: 24.0,
          height: 24.0,
        ),
        title: Text('Lighthouse Power management',
            style: theme.textTheme.headline6!
                .copyWith(fontWeight: FontWeight.bold)),
      ),
      Divider(
        thickness: 1.5,
      ),
      ListTile(
        title: Text('Lighthouses with nicknames'),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () => Navigator.pushNamed(context, '/settings/nicknames'),
      ),
      Divider(),
      ListTile(
          title: Text('Clear all last seen devices'),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: () async {
            // result can be `null`
            if (await ClearLastSeenAlertWidget.showCustomDialog(context) ==
                true) {
              await blocWithoutListen(context).nicknames.deleteAllLastSeen();
              Toast.show('Cleared up all last seen items', context,
                  duration: Toast.lengthShort, gravity: Toast.bottom);
            }
          }),
      Divider(),
      StreamBuilder<LighthousePowerState>(
        stream: blocWithoutListen(context).settings.getSleepStateAsStream(),
        builder:
            (BuildContext c, AsyncSnapshot<LighthousePowerState> snapshot) {
          final state =
              snapshot.hasData && snapshot.data == LighthousePowerState.STANDBY;
          return SwitchListTile(
            title: Text('Use STANDBY instead of SLEEP'),
            value: state,
            onChanged: (value) {
              blocWithoutListen(context).settings.insertSleepState(value
                  ? LighthousePowerState.STANDBY
                  : LighthousePowerState.SLEEP);
            },
          );
        },
      ),
      Divider(),
      StreamBuilder<int>(
        stream: blocWithoutListen(context).settings.getScanDurationsAsStream(),
        builder: (BuildContext c, AsyncSnapshot<int> snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }
          return DropdownMenuListTile<int>(
              title: Text('Set scan duration'),
              value: snapshot.requireData,
              onChanged: (int? value) async {
                if (value != null) {
                  await blocWithoutListen(context)
                      .settings
                      .setScanDuration(value);
                }
              },
              items: SettingsDao.SCAN_DURATION_VALUES
                  .map<DropdownMenuItem<int>>((int value) =>
                      DropdownMenuItem<int>(
                          value: value, child: Text('$value seconds')))
                  .toList());
        },
      ),
      Divider(),
      FutureBuilder<List<ThemeMode>>(
        future: _getSupportedThemeModes(),
        builder: (BuildContext context,
            AsyncSnapshot<List<ThemeMode>> supportedThemesSnapshot) {
          final supportedThemes = supportedThemesSnapshot.data;
          if (supportedThemes == null) {
            return CircularProgressIndicator();
          }
          return StreamBuilder<ThemeMode>(
            stream:
                blocWithoutListen(context).settings.getPreferredThemeAsStream(),
            builder: (BuildContext context, AsyncSnapshot<ThemeMode> snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }
              return DropdownMenuListTile<ThemeMode>(
                title: Text('Set preferred theme'),
                value: snapshot.requireData,
                onChanged: (ThemeMode? theme) async {
                  if (theme != null) {
                    await blocWithoutListen(context)
                        .settings
                        .setPreferredTheme(theme);
                  }
                },
                items: supportedThemes
                    .map<DropdownMenuItem<ThemeMode>>(
                        (ThemeMode theme) => DropdownMenuItem<ThemeMode>(
                              value: theme,
                              child: Text(_themeModeToString(theme)),
                            ))
                    .toList(),
              );
            },
          );
        },
      ),
      Divider(),
    ];

    // region Vive Base station
    items.addAll([
      ListTile(
        title: Text('Vive Base station | BETA',
            style: theme.textTheme.headline6!
                .copyWith(fontWeight: FontWeight.bold)),
      ),
      Divider(thickness: 1.5),
      ListTile(
        title: Text('Vive Base station ids'),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () => Navigator.pushNamed(context, '/settings/vive'),
      ),
      Divider(),
      ListTile(
        title: Text('Clear all Vive Base station ids'),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () async {
          if (await ViveBaseStationClearIds.showCustomDialog(context)) {
            await blocWithoutListen(context).viveBaseStation.deleteIds();
            Toast.show('Cleared up all Base station ids', context,
                duration: Toast.lengthShort, gravity: Toast.bottom);
          }
        },
      ),
      Divider(),
      StreamBuilder<bool>(
        stream: blocWithoutListen(context)
            .settings
            .getViveBaseStationsEnabledStream(),
        initialData: false,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          return SwitchListTile(
            title: Text('BETA: enable support for Vive Base stations'),
            value: snapshot.requireData,
            onChanged: (enabled) async {
              if (enabled) {
                enabled = await ViveBaseStationBetaAlertWidget.showCustomDialog(
                    context);
              }
              await blocWithoutListen(context)
                  .settings
                  .setViveBaseStationEnabled(enabled);
              if (enabled) {
                Toast.show('Thanks for participating in the beta', context,
                    duration: Toast.lengthShort, gravity: Toast.bottom);
              }
            },
          );
        },
      ),
      Divider(),
    ]);
    // endregion

    // region shortcut
    if (Platform.isAndroid) {
      items.add(FutureBuilder<bool>(
        future: AndroidLauncherShortcut.instance.shortcutSupported(),
        builder: (context, supportedSnapshot) {
          final supported = supportedSnapshot.data;
          if (supported == null) {
            return CircularProgressIndicator();
          }
          return Column(
            children: [
              ListTile(
                  title: Text('Shortcuts | BETA',
                      style: theme.textTheme.headline6!
                          .copyWith(fontWeight: FontWeight.bold))),
              Divider(thickness: 1.5),
              StreamBuilder<bool>(
                stream: blocWithoutListen(context)
                    .settings
                    .getShortcutsEnabledStream(),
                initialData: false,
                builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                  // Disable the setting if for some reason it got set to true,
                  // while not being supported.
                  if (!supported && snapshot.data == true) {
                    blocWithoutListen(context)
                        .settings
                        .setShortcutsEnabledStream(false);
                  }
                  return SwitchListTile(
                    title: Text('BETA: enable support for shortcuts'),
                    value: snapshot.requireData,
                    inactiveThumbColor:
                        (supported) ? null : Theme.of(context).disabledColor,
                    onChanged: (enabled) async {
                      if (!supported) {
                        ShortcutNotSupportedWidget.showCustomDialog(context);
                      } else {
                        if (enabled) {
                          enabled =
                              await ShortcutBetaAlertWidget.showCustomDialog(
                                  context);
                        }
                        await blocWithoutListen(context)
                            .settings
                            .setShortcutsEnabledStream(enabled);
                        if (enabled) {
                          Toast.show(
                              'Thanks for participating in the beta', context,
                              duration: Toast.lengthShort,
                              gravity: Toast.bottom);
                        }
                      }
                    },
                  );
                },
              ),
              Divider(),
            ],
          );
        },
      ));
    }
    // endregion

    // region about
    items.addAll([
      ListTile(
        title: Text('About',
            style: theme.textTheme.headline6!
                .copyWith(fontWeight: FontWeight.bold)),
      ),
      Divider(
        thickness: 1.5,
      ),
      ListTile(
        title: Text('Licences'),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () => {showLicensePage(context: context)},
      ),
      Divider(),
      ListTile(
        title: Text('Privacy'),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () => Navigator.pushNamed(context, '/settings/privacy'),
      ),
      Divider(),
      ListTile(
        title: Text('Fork me on Github'),
        trailing: Icon(Icons.arrow_forward_ios),
        leading: SvgPicture.asset(
          (theme.brightness == Brightness.light)
              ? "assets/images/github-dark.svg"
              : "assets/images/github-light.svg",
          width: 24,
          height: 24,
        ),
        onTap: () async {
          await launch(_GITHUB_URL);
        },
      ),
      Divider(),
      FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (_, snapshot) {
          if (snapshot.hasError) {
            return ListTile(
              title: Text('Version'),
              subtitle: Text('${snapshot.error}'),
            );
          }
          final packageInfo = snapshot.data;
          if (packageInfo == null) {
            return CircularProgressIndicator();
          }
          return ListTile(
            title: Text('Version'),
            subtitle: Text('${packageInfo.version}'),
            onLongPress: () async {
              await Clipboard.setData(ClipboardData(text: packageInfo.version));
              Toast.show('Copied to clipboard', context,
                  duration: Toast.lengthShort, gravity: Toast.bottom);
            },
          );
        },
      ),
      Divider(),
    ]);
    // endregion

    return Scaffold(
        appBar: AppBar(title: Text('Settings')),
        body: ListView(children: [Column(children: items)]));
  }

  static Map<String, PageBuilder> _subPages = {
    '/nicknames': (context) => SettingsNicknamesPage(),
    '/vive': (context) => SettingsViveBaseStationIdsPage(),
    '/privacy': (context) => PrivacyPage(),
  };

  static Map<String, PageBuilder> getSubPages(String parentPath) {
    Map<String, PageBuilder> subPages = {};

    for (final subPage in _subPages.entries) {
      subPages['$parentPath${subPage.key}'] = subPage.value;
    }

    return subPages;
  }
}
