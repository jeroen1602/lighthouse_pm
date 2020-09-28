import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lighthouse_pm/bloc.dart';
import 'package:lighthouse_pm/lighthouseProvider/LighthousePowerState.dart';
import 'package:lighthouse_pm/pages/settings/SettingsNicknamesPage.dart';
import 'package:lighthouse_pm/pages/settings/SettingsViveBaseStationIdsPage.dart';
import 'package:lighthouse_pm/widgets/ClearLastSeenAlertWidget.dart';
import 'package:lighthouse_pm/widgets/DropdownMenuListTile.dart';
import 'package:lighthouse_pm/widgets/ViveBaseStationAlertWidget.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

const _GITHUB_URL = "https://github.com/jeroen1602/lighthouse_pm";

class SettingsPage extends StatelessWidget {
  LighthousePMBloc _bloc(BuildContext context) =>
      Provider.of<LighthousePMBloc>(context, listen: false);

  Future<List<ThemeMode>> _getSupportedThemeModes() async {
    if (await SettingsBloc.supportsThemeModeSystem) {
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
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
        ),
        body: ListView(
          children: [
            Column(
              children: [
                ListTile(
                  leading: SvgPicture.asset(
                    "assets/images/app-icon.svg",
                    width: 24.0,
                    height: 24.0,
                  ),
                  title: Text('Lighthouse Power management',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headline6
                          .copyWith(fontWeight: FontWeight.bold)),
                ),
                Divider(
                  thickness: 1.5,
                ),
                ListTile(
                  title: Text('Lighthouses with nicknames'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => SettingsNicknamesPage())),
                ),
                Divider(),
                ListTile(
                    title: Text('Clear all last seen devices'),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () async {
                      // result can be `null`
                      if (await ClearLastSeenAlertWidget.showCustomDialog(
                              context) ==
                          true) {
                        await _bloc(context).deleteAllLastSeen();
                        Toast.show('Cleared up all last seen items', context,
                            duration: Toast.LENGTH_SHORT,
                            gravity: Toast.BOTTOM);
                      }
                    }),
                Divider(),
                StreamBuilder<LighthousePowerState>(
                  stream: _bloc(context).settings.getSleepStateAsStream(),
                  builder: (BuildContext c,
                      AsyncSnapshot<LighthousePowerState> snapshot) {
                    final state = snapshot.hasData &&
                        snapshot.data == LighthousePowerState.STANDBY;
                    return SwitchListTile(
                      title: Text('Use STANDBY instead of SLEEP'),
                      value: state,
                      onChanged: (value) {
                        _bloc(context).settings.insertSleepState(value
                            ? LighthousePowerState.STANDBY
                            : LighthousePowerState.SLEEP);
                      },
                    );
                  },
                ),
                Divider(),
                StreamBuilder<int>(
                  stream: _bloc(context).settings.getScanDurationsAsStream(),
                  builder: (BuildContext c, AsyncSnapshot<int> snapshot) {
                    return DropdownMenuListTile<int>(
                        title: Text('Set scan duration'),
                        value: snapshot.data,
                        onChanged: (int value) async => await _bloc(context)
                            .settings
                            .setScanDuration(value),
                        items: SettingsBloc.SCAN_DURATION_VALUES
                            .map<DropdownMenuItem<int>>((int value) =>
                                DropdownMenuItem<int>(
                                    value: value,
                                    child: Text('$value seconds')))
                            .toList());
                  },
                ),
                Divider(),
                FutureBuilder<List<ThemeMode>>(
                  future: _getSupportedThemeModes(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<ThemeMode>> supportedThemesSnapshot) {
                    if (!supportedThemesSnapshot.hasData) {
                      return CircularProgressIndicator();
                    }
                    return StreamBuilder<ThemeMode>(
                      stream:
                          _bloc(context).settings.getPreferedThemeAsStream(),
                      builder: (BuildContext context,
                          AsyncSnapshot<ThemeMode> snapshot) {
                        return DropdownMenuListTile<ThemeMode>(
                          title: Text('Set prefered theme'),
                          value: snapshot.data,
                          onChanged: (ThemeMode theme) async =>
                              await _bloc(context)
                                  .settings
                                  .setPreferedTheme(theme),
                          items: supportedThemesSnapshot.data
                              .map<DropdownMenuItem<ThemeMode>>(
                                  (ThemeMode theme) =>
                                      DropdownMenuItem<ThemeMode>(
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
                // region Vive Base station
                ListTile(
                  title: Text('Vive Base station | BETA',
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          .copyWith(fontWeight: FontWeight.bold)),
                ),
                Divider(
                  thickness: 1.5,
                ),
                ListTile(
                  title: Text('Vive Base station ids'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => SettingsViveBaseStationIdsPage())),
                ),
                Divider(),
                ListTile(
                  title: Text('Clear all Vive Base station ids'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () async {
                    if (await ViveBaseStationClearIds.showCustomDialog(
                        context)) {
                      await _bloc(context).viveBaseStation.deleteIds();
                      Toast.show('Cleared up all Base station ids', context,
                          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
                    }
                  },
                ),
                Divider(),
                StreamBuilder<bool>(
                  stream: _bloc(context)
                      .settings
                      .getViveBaseStationsEnabledStream(),
                  initialData: false,
                  builder:
                      (BuildContext context, AsyncSnapshot<bool> snapshot) {
                    return SwitchListTile(
                      title:
                          Text('BETA: enable support for Vive Base stations'),
                      value: snapshot.data,
                      onChanged: (enabled) async {
                        if (enabled) {
                          enabled = await ViveBaseStationBetaAlertWidget
                              .showCustomDialog(context);
                        }
                        await _bloc(context)
                            .settings
                            .setViveBaseStationEnabled(enabled);
                        if (enabled) {
                          Toast.show(
                              'Thanks for participating in the beta', context,
                              duration: Toast.LENGTH_LONG);
                        }
                      },
                    );
                  },
                ),
                Divider(),
                // endregion
                // region about
                ListTile(
                  title: Text('About',
                      style: Theme.of(context)
                          .textTheme
                          .headline6
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
                  onTap: () =>
                      Navigator.pushNamed(context, '/settings/privacy'),
                ),
                Divider(),
                ListTile(
                  title: Text('Fork me on Github'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  leading: SvgPicture.asset(
                    (Theme.of(context).brightness == Brightness.light)
                        ?"assets/images/github-dark.svg"
                        :"assets/images/github-light.svg" ,
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
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return ListTile(
                        title: Text('Version'),
                        subtitle: Text('${snapshot.error}'),
                      );
                    }
                    final data = snapshot.data;
                    return ListTile(
                      title: Text('Version'),
                      subtitle: Text('${data.version}'),
                      onLongPress: () async {
                        await Clipboard.setData(
                            ClipboardData(text: data.version));
                        Toast.show('Copied to clipboard', context,
                            duration: Toast.LENGTH_SHORT,
                            gravity: Toast.BOTTOM);
                      },
                    );
                  },
                ),
                Divider(),
                // endregion
              ],
            )
          ],
        ));
  }
}
