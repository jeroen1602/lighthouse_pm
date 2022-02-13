import 'package:flutter/widgets.dart';
import 'package:lighthouse_pm/bloc.dart';
import 'package:lighthouse_pm/data/dao/settings_dao.dart';
import 'package:lighthouse_provider/lighthouse_provider.dart';
import 'package:lighthouse_providers/vive_base_station_device_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

typedef MainPageSettingsWidgetBuilder = Widget Function(
    BuildContext context, MainPageSettings? settings);

class MainPageSettings {
  const MainPageSettings._({
    required this.sleepState,
    required this.viveBaseStationsEnabled,
    required this.scanDuration,
    required this.updateInterval,
    required this.shortcutEnabled,
    required this.groupShowOfflineWarning,
  });

  final LighthousePowerState sleepState;
  final bool viveBaseStationsEnabled;
  final int scanDuration;
  final int updateInterval;
  final bool shortcutEnabled;
  final bool groupShowOfflineWarning;

  static const defaultMainPageSettings = MainPageSettings._(
    sleepState: LighthousePowerState.sleep,
    viveBaseStationsEnabled: false,
    scanDuration: 5,
    updateInterval: 1,
    shortcutEnabled: false,
    groupShowOfflineWarning: true,
  );

  static Stream<MainPageSettings> mainPageSettingsStream(
      final LighthousePMBloc bloc) {
    LighthousePowerState sleepState = defaultMainPageSettings.sleepState;
    bool viveBaseStationsEnabled =
        defaultMainPageSettings.viveBaseStationsEnabled;
    int scanDuration = defaultMainPageSettings.scanDuration;
    int updateInterval = defaultMainPageSettings.updateInterval;
    bool shortcutEnabled = defaultMainPageSettings.shortcutEnabled;
    bool groupShowOfflineWarning =
        defaultMainPageSettings.groupShowOfflineWarning;

    return MergeStream<Tuple2<int, dynamic>>([
      bloc.settings
          .getSleepStateAsStream()
          .map((final state) => Tuple2(SettingsDao.defaultSleepStateId, state)),
      bloc.settings.getViveBaseStationsEnabledStream().map(
          (final state) => Tuple2(SettingsDao.viveBaseStationEnabledId, state)),
      bloc.settings
          .getScanDurationsAsStream(defaultValue: scanDuration)
          .map((final state) => Tuple2(SettingsDao.scanDurationId, state)),
      bloc.settings
          .getUpdateIntervalAsStream(defaultUpdateInterval: updateInterval)
          .map((final state) => Tuple2(SettingsDao.updateIntervalId, state)),
      bloc.settings
          .getShortcutsEnabledStream()
          .map((final state) => Tuple2(SettingsDao.shortcutEnabledId, state)),
      bloc.settings.getGroupOfflineWarningEnabledStream().map((final state) =>
          Tuple2(SettingsDao.groupShowOfflineWarningId, state)),
    ]).map((final event) {
      switch (event.item1) {
        case SettingsDao.defaultSleepStateId:
          if (event.item2 != null) {
            sleepState = event.item2 as LighthousePowerState;
          }
          break;
        case SettingsDao.viveBaseStationEnabledId:
          if (event.item2 != null) {
            viveBaseStationsEnabled = event.item2 as bool;
          }
          break;
        case SettingsDao.scanDurationId:
          if (event.item2 != null) {
            scanDuration = event.item2 as int;
          }
          break;
        case SettingsDao.updateIntervalId:
          if (event.item2 != null) {
            updateInterval = event.item2 as int;
          }
          break;
        case SettingsDao.shortcutEnabledId:
          if (event.item2 != null) {
            shortcutEnabled = event.item2 as bool;
          }
          break;
        case SettingsDao.groupShowOfflineWarningId:
          if (event.item2 != null) {
            groupShowOfflineWarning = event.item2 as bool;
          }
          break;
      }
      return MainPageSettings._(
        sleepState: sleepState,
        viveBaseStationsEnabled: viveBaseStationsEnabled,
        scanDuration: scanDuration,
        updateInterval: updateInterval,
        shortcutEnabled: shortcutEnabled,
        groupShowOfflineWarning: groupShowOfflineWarning,
      );
    });
  }

  ///
  /// A little helper function for creating a [StreamBuilder] for getting the
  /// [MainPageSettings].
  static Widget mainPageSettingsStreamBuilder(
      {required final LighthousePMBloc bloc,
      required final MainPageSettingsWidgetBuilder builder}) {
    return StreamBuilder<MainPageSettings>(
      stream: mainPageSettingsStream(bloc),
      initialData: MainPageSettings.defaultMainPageSettings,
      builder: (final BuildContext context,
          final AsyncSnapshot<MainPageSettings> settingsSnapshot) {
        // Not sure if I want to keep this logic in here.
        if (settingsSnapshot.data?.viveBaseStationsEnabled ?? false) {
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
