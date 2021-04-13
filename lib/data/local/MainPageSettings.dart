import 'package:flutter/widgets.dart';
import 'package:lighthouse_pm/bloc.dart';
import 'package:lighthouse_pm/data/dao/SettingsDao.dart';
import 'package:lighthouse_pm/lighthouseProvider/LighthousePowerState.dart';
import 'package:lighthouse_pm/lighthouseProvider/LighthouseProvider.dart';
import 'package:lighthouse_pm/lighthouseProvider/deviceProviders/ViveBaseStationDeviceProvider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

typedef MainPageSettingsWidgetBuilder = Widget Function(
    BuildContext context, MainPageSettings? settings);

class MainPageSettings {
  const MainPageSettings._({
    required this.sleepState,
    required this.viveBaseStationsEnabled,
    required this.scanDuration,
    required this.shortcutEnabled,
    required this.groupShowOfflineWarning,
  });

  final LighthousePowerState sleepState;
  final bool viveBaseStationsEnabled;
  final int scanDuration;
  final bool shortcutEnabled;
  final bool groupShowOfflineWarning;

  static const DEFAULT_MAIN_PAGE_SETTINGS = MainPageSettings._(
    sleepState: LighthousePowerState.SLEEP,
    viveBaseStationsEnabled: false,
    scanDuration: 5,
    shortcutEnabled: false,
    groupShowOfflineWarning: true,
  );

  static Stream<MainPageSettings> mainPageSettingsStream(
      LighthousePMBloc bloc) {
    LighthousePowerState sleepState = DEFAULT_MAIN_PAGE_SETTINGS.sleepState;
    bool viveBaseStationsEnabled =
        DEFAULT_MAIN_PAGE_SETTINGS.viveBaseStationsEnabled;
    int scanDuration = DEFAULT_MAIN_PAGE_SETTINGS.scanDuration;
    bool shortcutEnabled = DEFAULT_MAIN_PAGE_SETTINGS.shortcutEnabled;
    bool groupShowOfflineWarning =
        DEFAULT_MAIN_PAGE_SETTINGS.groupShowOfflineWarning;

    return MergeStream<Tuple2<int, dynamic>>([
      bloc.settings
          .getSleepStateAsStream()
          .map((state) => Tuple2(SettingsDao.DEFAULT_SLEEP_STATE_ID, state)),
      bloc.settings.getViveBaseStationsEnabledStream().map(
          (state) => Tuple2(SettingsDao.VIVE_BASE_STATION_ENABLED_ID, state)),
      bloc.settings
          .getScanDurationsAsStream(defaultValue: scanDuration)
          .map((state) => Tuple2(SettingsDao.SCAN_DURATION_ID, state)),
      bloc.settings
          .getShortcutsEnabledStream()
          .map((state) => Tuple2(SettingsDao.SHORTCUTS_ENABLED_ID, state)),
      bloc.settings.getGroupOfflineWarningEnabledStream().map(
          (state) => Tuple2(SettingsDao.GROUP_SHOW_OFFLINE_WARNING, state)),
    ]).map((event) {
      switch (event.item1) {
        case SettingsDao.DEFAULT_SLEEP_STATE_ID:
          if (event.item2 != null) {
            sleepState = event.item2 as LighthousePowerState;
          }
          break;
        case SettingsDao.VIVE_BASE_STATION_ENABLED_ID:
          if (event.item2 != null) {
            viveBaseStationsEnabled = event.item2 as bool;
          }
          break;
        case SettingsDao.SCAN_DURATION_ID:
          if (event.item2 != null) {
            scanDuration = event.item2 as int;
          }
          break;
        case SettingsDao.SHORTCUTS_ENABLED_ID:
          if (event.item2 != null) {
            shortcutEnabled = event.item2 as bool;
          }
          break;
        case SettingsDao.GROUP_SHOW_OFFLINE_WARNING:
          if (event.item2 != null) {
            groupShowOfflineWarning = event.item2 as bool;
          }
          break;
      }
      return MainPageSettings._(
        sleepState: sleepState,
        viveBaseStationsEnabled: viveBaseStationsEnabled,
        scanDuration: scanDuration,
        shortcutEnabled: shortcutEnabled,
        groupShowOfflineWarning: groupShowOfflineWarning,
      );
    });
  }

  ///
  /// A little helper function for creating a [StreamBuilder] for getting the
  /// [MainPageSettings].
  static Widget mainPageSettingsStreamBuilder(
      {required LighthousePMBloc bloc,
      required MainPageSettingsWidgetBuilder builder}) {
    return StreamBuilder<MainPageSettings>(
      stream: mainPageSettingsStream(bloc),
      initialData: MainPageSettings.DEFAULT_MAIN_PAGE_SETTINGS,
      builder: (BuildContext context,
          AsyncSnapshot<MainPageSettings> settingsSnapshot) {
        // Not sure if I want to keep this logic in here.
        if (settingsSnapshot.data?.viveBaseStationsEnabled == true) {
          LighthouseProvider.instance
              .addProvider(ViveBaseStationDeviceProvider.instance);
        } else {
          LighthouseProvider.instance
              .removeProvider(ViveBaseStationDeviceProvider.instance);
        }
        return builder(context, settingsSnapshot.data);
      },
    );
  }
}
