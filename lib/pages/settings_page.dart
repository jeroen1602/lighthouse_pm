import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lighthouse_pm/bloc.dart';
import 'package:lighthouse_pm/data/dao/settings_dao.dart';
import 'package:lighthouse_pm/links.dart';
import 'package:lighthouse_pm/pages/settings/lh_license_page.dart';
import 'package:lighthouse_pm/pages/settings/settings_nicknames_page.dart';
import 'package:lighthouse_pm/pages/settings/settings_vive_base_station_ids_page.dart';
import 'package:lighthouse_pm/platform_specific/mobile/android/android_launcher_shortcut/android_launcher_shortcut.dart';
import 'package:lighthouse_pm/theming.dart';
import 'package:lighthouse_pm/widgets/clear_last_seen_alert_widget.dart';
import 'package:lighthouse_pm/widgets/content_container_widget.dart';
import 'package:lighthouse_pm/widgets/dropdown_menu_list_tile.dart';
import 'package:lighthouse_pm/widgets/shortcut_alert_widget.dart';
import 'package:lighthouse_pm/widgets/vive_base_station_alert_widget.dart';
import 'package:lighthouse_provider/lighthouse_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_platform/shared_platform.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../build_options.dart';
import 'base_page.dart';
import 'settings/privacy_page.dart';
import 'settings/settings_donations_page.dart';

class SettingsPage extends BasePage with WithBlocStateless {
  const SettingsPage({final Key? key}) : super(key: key);

  Future<List<ThemeMode>> _getSupportedThemeModes() async {
    if (await SettingsDao.supportsThemeModeSystem) {
      return [ThemeMode.light, ThemeMode.dark, ThemeMode.system];
    } else {
      return [ThemeMode.light, ThemeMode.dark];
    }
  }

  String _themeModeToString(final ThemeMode themeMode) {
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
  Widget buildPage(final BuildContext context) {
    final theme = Theme.of(context);
    final theming = Theming.fromTheme(theme);
    final headTheme = theming.headline6?.copyWith(fontWeight: FontWeight.bold);

    // region header
    final items = <Widget>[
      ListTile(
        leading: SvgPicture.asset(
          "assets/images/app-icon.svg",
          width: theming.iconSizeLarge,
          height: theming.iconSizeLarge,
          color: theming.iconColor,
        ),
        title: Text('Lighthouse Power management', style: headTheme),
      ),
      const Divider(
        thickness: 1.5,
      ),
    ];
    // endregion

    // region main settings
    items.addAll([
      ListTile(
        title: const Text('Lighthouses with nicknames'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => Navigator.pushNamed(context, '/settings/nicknames'),
      ),
      const Divider(),
      ListTile(
          title: const Text('Clear all last seen devices'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () async {
            // result can be `null`
            if (await ClearLastSeenAlertWidget.showCustomDialog(context) ??
                false) {
              await blocWithoutListen(context).nicknames.deleteAllLastSeen();
              Toast.show('Cleared up all last seen items',
                  duration: Toast.lengthShort, gravity: Toast.bottom);
            }
          }),
      const Divider(),
      StreamBuilder<LighthousePowerState>(
        stream: blocWithoutListen(context).settings.getSleepStateAsStream(),
        builder: (final BuildContext c,
            final AsyncSnapshot<LighthousePowerState> snapshot) {
          if (snapshot.hasError) {
            debugPrint(snapshot.error.toString());
            return Container(
              color: Colors.red,
              child: ListTile(
                title: const Text('Error'),
                subtitle: Text(snapshot.error.toString()),
              ),
            );
          }
          final state =
              snapshot.hasData && snapshot.data == LighthousePowerState.standby;
          return SwitchListTile(
            title: const Text('Use STANDBY instead of SLEEP'),
            subtitle: const Text('Only V2 lighthouse support this.'),
            value: state,
            onChanged: (final value) {
              blocWithoutListen(context).settings.setSleepState(value
                  ? LighthousePowerState.standby
                  : LighthousePowerState.sleep);
            },
          );
        },
      ),
      const Divider(),
      StreamBuilder<int>(
        stream: blocWithoutListen(context).settings.getScanDurationsAsStream(),
        builder: (final BuildContext c, final AsyncSnapshot<int> snapshot) {
          if (snapshot.hasError) {
            debugPrint(snapshot.error.toString());
            return Container(
              color: Colors.red,
              child: ListTile(
                title: const Text('Error'),
                subtitle: Text(snapshot.error.toString()),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }
          return DropdownMenuListTile<int>(
              title: const Text('Set scan duration'),
              value: snapshot.requireData,
              onChanged: (final int? value) async {
                if (value != null) {
                  await blocWithoutListen(context)
                      .settings
                      .setScanDuration(value);
                }
              },
              items: SettingsDao.scanDurationValues
                  .map<DropdownMenuItem<int>>((final int value) =>
                      DropdownMenuItem<int>(
                          value: value, child: Text('$value seconds')))
                  .toList());
        },
      ),
      const Divider(),
      StreamBuilder<int>(
        stream: blocWithoutListen(context).settings.getUpdateIntervalAsStream(),
        builder: (final BuildContext c, final AsyncSnapshot<int> snapshot) {
          if (snapshot.hasError) {
            debugPrint(snapshot.error.toString());
            return Container(
              color: Colors.red,
              child: ListTile(
                title: const Text('Error'),
                subtitle: Text(snapshot.error.toString()),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }
          return DropdownMenuListTile<int>(
              title: const Text('Set update interval'),
              subTitle:
                  const Text('You may want to change this if you have a lot'
                      ' of devices.'),
              value: snapshot.requireData,
              onChanged: (final int? value) async {
                if (value != null) {
                  await blocWithoutListen(context)
                      .settings
                      .setUpdateInterval(value);
                }
              },
              items: SettingsDao.updateIntervalValues
                  .map<DropdownMenuItem<int>>((final int value) =>
                      DropdownMenuItem<int>(
                          value: value, child: Text('$value seconds')))
                  .toList());
        },
      ),
      const Divider(),
      FutureBuilder<List<ThemeMode>>(
        future: _getSupportedThemeModes(),
        builder: (final BuildContext context,
            final AsyncSnapshot<List<ThemeMode>> supportedThemesSnapshot) {
          final supportedThemes = supportedThemesSnapshot.data;
          if (supportedThemes == null) {
            return const CircularProgressIndicator();
          }
          return StreamBuilder<ThemeMode>(
            stream:
                blocWithoutListen(context).settings.getPreferredThemeAsStream(),
            builder: (final BuildContext context,
                final AsyncSnapshot<ThemeMode> snapshot) {
              if (snapshot.hasError) {
                debugPrint(snapshot.error.toString());
                return Container(
                  color: Colors.red,
                  child: ListTile(
                    title: const Text('Error'),
                    subtitle: Text(snapshot.error.toString()),
                  ),
                );
              }
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }
              return DropdownMenuListTile<ThemeMode>(
                title: const Text('Set preferred theme'),
                value: snapshot.requireData,
                onChanged: (final ThemeMode? theme) async {
                  if (theme != null) {
                    await blocWithoutListen(context)
                        .settings
                        .setPreferredTheme(theme);
                  }
                },
                items: supportedThemes
                    .map<DropdownMenuItem<ThemeMode>>(
                        (final ThemeMode theme) => DropdownMenuItem<ThemeMode>(
                              value: theme,
                              child: Text(_themeModeToString(theme)),
                            ))
                    .toList(),
              );
            },
          );
        },
      ),
      const Divider(),
      StreamBuilder(
        stream: blocWithoutListen(context)
            .settings
            .getGroupOfflineWarningEnabledStream(),
        builder:
            (final BuildContext context, final AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasError) {
            debugPrint(snapshot.error.toString());
            return Container(
              color: Colors.red,
              child: ListTile(
                title: const Text('Error'),
                subtitle: Text(snapshot.error.toString()),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }
          return SwitchListTile(
              title: const Text('Show devices in group offline warning'),
              value: snapshot.requireData,
              onChanged: (final value) {
                blocWithoutListen(context)
                    .settings
                    .setGroupOfflineWarningEnabled(value);
              });
        },
      ),
      const Divider(),
    ]);
    // endregion

    // region Vive Base station
    items.addAll([
      ListTile(
        title: Text('Vive Base station | BETA', style: headTheme),
      ),
      const Divider(thickness: 1.5),
      ListTile(
        title: const Text('Vive Base station ids'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => Navigator.pushNamed(context, '/settings/vive'),
      ),
      const Divider(),
      ListTile(
        title: const Text('Clear all Vive Base station ids'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () async {
          if (await ViveBaseStationClearIds.showCustomDialog(context)) {
            await blocWithoutListen(context).viveBaseStation.deleteIds();
            Toast.show('Cleared up all Base station ids',
                duration: Toast.lengthShort, gravity: Toast.bottom);
          }
        },
      ),
      const Divider(),
      StreamBuilder<bool>(
        stream: blocWithoutListen(context)
            .settings
            .getViveBaseStationsEnabledStream(),
        initialData: false,
        builder:
            (final BuildContext context, final AsyncSnapshot<bool> snapshot) {
          return SwitchListTile(
            title: const Text('BETA: enable support for Vive Base stations'),
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
                Toast.show('Thanks for participating in the beta',
                    duration: Toast.lengthShort, gravity: Toast.bottom);
              }
            },
          );
        },
      ),
      const Divider(),
    ]);
    // endregion

    // region shortcut
    if (SharedPlatform.isAndroid) {
      items.add(FutureBuilder<bool>(
        future: AndroidLauncherShortcut.instance.shortcutSupported(),
        builder: (final context, final supportedSnapshot) {
          final supported = supportedSnapshot.data;
          if (supported == null) {
            return const CircularProgressIndicator();
          }
          return Column(
            children: [
              ListTile(title: Text('Shortcuts | BETA', style: headTheme)),
              const Divider(thickness: 1.5),
              StreamBuilder<bool>(
                stream: blocWithoutListen(context)
                    .settings
                    .getShortcutsEnabledStream(),
                initialData: false,
                builder: (final BuildContext context,
                    final AsyncSnapshot<bool> snapshot) {
                  // Disable the setting if for some reason it got set to true,
                  // while not being supported.
                  if (!supported && (snapshot.data ?? false)) {
                    blocWithoutListen(context)
                        .settings
                        .setShortcutsEnabledStream(false);
                  }
                  return SwitchListTile(
                    title: const Text('BETA: enable support for shortcuts'),
                    value: snapshot.requireData,
                    inactiveThumbColor:
                        (supported) ? null : theming.disabledColor,
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
                              'Thanks for participating in the beta',
                              duration: Toast.lengthShort,
                              gravity: Toast.bottom);
                        }
                      }
                    },
                  );
                },
              ),
              const Divider(),
            ],
          );
        },
      ));
    }
    // endregion

    // region about
    items.addAll([
      ListTile(
        title: Text('About', style: headTheme),
      ),
      const Divider(
        thickness: 1.5,
      ),
      ListTile(
        title: const Text('Licenses'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => Navigator.pushNamed(context, '/settings/license'),
      ),
      const Divider(),
      ListTile(
        title: const Text('Privacy'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => Navigator.pushNamed(context, '/settings/privacy'),
      ),
      const Divider(),
      if (BuildOptions.includeSupportButtons &&
          BuildOptions.includeSupportPage) ...[
        ListTile(
          title: const Text('Support'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => Navigator.pushNamed(context, '/settings/support'),
        ),
        const Divider(),
      ],
      ListTile(
        title: const Text('Fork me on Github'),
        trailing: const Icon(Icons.arrow_forward_ios),
        leading: SvgPicture.asset(
          (theme.brightness == Brightness.light)
              ? "assets/images/github-dark.svg"
              : "assets/images/github-light.svg",
          width: theming.iconSizeLarge,
          height: theming.iconSizeLarge,
        ),
        onTap: () async {
          await launchUrl(Links.projectUrl);
        },
      ),
      const Divider(),
      if (SharedPlatform.isWeb || SharedPlatform.isLinux) ...[
        ListTile(
          title: const Text('Try the Android app'),
          subtitle: const Text('On Google Play'),
          trailing: const Icon(Icons.arrow_forward_ios),
          leading: Icon(
            CommunityMaterialIcons.google_play,
            size: theming.iconSizeLarge,
            color: theming.iconColor,
          ),
          onTap: () async {
            await launchUrl(Links.googlePlayUrl);
          },
        ),
        const Divider(),
        ListTile(
          title: const Text('Try the Android app'),
          subtitle: const Text('On F-Droid'),
          trailing: const Icon(Icons.arrow_forward_ios),
          leading: SvgPicture.asset(
            "assets/images/f-droid-logo.svg",
            width: theming.iconSizeLarge,
            height: theming.iconSizeLarge,
            color: theming.iconColor,
          ),
          onTap: () async {
            await launchUrl(Links.fDroidUrl);
          },
        ),
        const Divider(),
      ],
      if (!SharedPlatform.isWeb) ...[
        ListTile(
          title: const Text('Try the Webapp'),
          trailing: const Icon(Icons.arrow_forward_ios),
          leading: Icon(
            Icons.public,
            size: theming.iconSizeLarge,
            color: theming.iconColor,
          ),
          onTap: () async {
            await launchUrl(Links.webUrl);
          },
        ),
        const Divider(),
      ],
      FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (final _, final snapshot) {
          if (snapshot.hasError) {
            debugPrint(snapshot.error.toString());
            return ListTile(
              title: const Text('Version'),
              subtitle: Text('${snapshot.error}'),
            );
          }
          final packageInfo = snapshot.data;
          if (packageInfo == null) {
            return const CircularProgressIndicator();
          }
          return ListTile(
            title: const Text('Version'),
            subtitle: Text(packageInfo.version),
            onLongPress: () async {
              await Clipboard.setData(ClipboardData(text: packageInfo.version));
              Toast.show('Copied to clipboard',
                  duration: Toast.lengthShort, gravity: Toast.bottom);
            },
          );
        },
      ),
      const Divider(),
    ]);
    // endregion

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ContentContainerListView(
        children: items,
      ),
    );
  }

  static final Map<String, PageBuilder> _subPages = {
    '/nicknames': (final context) => const SettingsNicknamesPage(),
    '/vive': (final context) => const SettingsViveBaseStationIdsPage(),
    '/privacy': (final context) => const PrivacyPage(),
    '/license': (final context) => LHLicensePage(),
    if (BuildOptions.includeSupportButtons && BuildOptions.includeSupportPage)
      '/support': (final context) => const SettingsSupportPage(),
  };

  static Map<String, PageBuilder> getSubPages(final String parentPath) {
    final Map<String, PageBuilder> subPages = {};

    for (final subPage in _subPages.entries) {
      subPages['$parentPath${subPage.key}'] = subPage.value;
    }

    return subPages;
  }
}
