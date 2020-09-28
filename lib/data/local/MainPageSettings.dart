import 'package:flutter/foundation.dart';
import 'package:lighthouse_pm/bloc.dart';
import 'package:lighthouse_pm/lighthouseProvider/LighthousePowerState.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

class MainPageSettings {
  const MainPageSettings._(
      {@required this.sleepState,
      @required this.viveBaseStationsEnabled,
      @required this.scanDuration});

  final LighthousePowerState sleepState;
  final bool viveBaseStationsEnabled;
  final int scanDuration;

  static const DEFAULT_MAIN_PAGE_SETTINGS = MainPageSettings._(
      sleepState: LighthousePowerState.SLEEP,
      viveBaseStationsEnabled: false,
      scanDuration: 5);

  static Stream<MainPageSettings> mainPageSettingsStream(
      LighthousePMBloc bloc) {
    LighthousePowerState sleepState = DEFAULT_MAIN_PAGE_SETTINGS.sleepState;
    bool viveBaseStationsEnabled =
        DEFAULT_MAIN_PAGE_SETTINGS.viveBaseStationsEnabled;
    int scanDuration = DEFAULT_MAIN_PAGE_SETTINGS.scanDuration;

    return MergeStream<Tuple2<int, dynamic>>([
      bloc.settings
          .getSleepStateAsStream()
          .map((state) => Tuple2(SettingsBloc.DEFAULT_SLEEP_STATE_ID, state)),
      bloc.settings.getViveBaseStationsEnabledStream().map(
          (state) => Tuple2(SettingsBloc.VIVE_BASE_STATION_ENABLED_ID, state)),
      bloc.settings
          .getScanDurationsAsStream(defaultValue: scanDuration)
          .map((state) => Tuple2(SettingsBloc.SCAN_DURATION_ID, state))
    ]).map((event) {
      switch (event.item1) {
        case SettingsBloc.DEFAULT_SLEEP_STATE_ID:
          if (event.item2 != null) {
            sleepState = event.item2 as LighthousePowerState;
          }
          break;
        case SettingsBloc.VIVE_BASE_STATION_ENABLED_ID:
          if (event.item2 != null) {
            viveBaseStationsEnabled = event.item2 as bool;
          }
          break;
        case SettingsBloc.SCAN_DURATION_ID:
          if (event.item2 != null) {
            scanDuration = event.item2 as int;
          }
          break;
      }
      return MainPageSettings._(
          sleepState: sleepState,
          viveBaseStationsEnabled: viveBaseStationsEnabled,
          scanDuration: scanDuration);
    });
  }
}
