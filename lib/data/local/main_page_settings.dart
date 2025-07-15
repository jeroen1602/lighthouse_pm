import 'package:flutter/widgets.dart';
import 'package:lighthouse_pm/bloc.dart';
import 'package:lighthouse_pm/data/dao/settings_dao.dart';
import 'package:lighthouse_pm/data/helper_structures/lighthouse_providers.dart';
import 'package:lighthouse_provider/lighthouse_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

typedef MainPageSettingsWidgetBuilder =
    Widget Function(BuildContext context, MainPageSettings settings);

class MainPageSettings {
  const MainPageSettings._({
    required this.sleepState,
    required this.enabledDeviceProviders,
    required this.scanDuration,
    required this.updateInterval,
    required this.shortcutEnabled,
    required this.groupShowOfflineWarning,
  });

  final LighthousePowerState sleepState;
  final List<LighthouseProviders> enabledDeviceProviders;
  final int scanDuration;
  final int updateInterval;
  final bool shortcutEnabled;
  final bool groupShowOfflineWarning;

  static const defaultMainPageSettings = MainPageSettings._(
    sleepState: LighthousePowerState.sleep,
    enabledDeviceProviders: SettingsDao.defaultDeviceProviders,
    scanDuration: 5,
    updateInterval: 1,
    shortcutEnabled: false,
    groupShowOfflineWarning: true,
  );

  static Stream<MainPageSettings> mainPageSettingsStream(
    final LighthousePMBloc bloc,
  ) {
    LighthousePowerState sleepState = defaultMainPageSettings.sleepState;
    List<LighthouseProviders> enabledDeviceProviders =
        defaultMainPageSettings.enabledDeviceProviders;
    int scanDuration = defaultMainPageSettings.scanDuration;
    int updateInterval = defaultMainPageSettings.updateInterval;
    bool shortcutEnabled = defaultMainPageSettings.shortcutEnabled;
    bool groupShowOfflineWarning =
        defaultMainPageSettings.groupShowOfflineWarning;

    return MergeStream<Tuple2<SettingsIds, dynamic>>([
      bloc.settings.getSleepStateAsStream().map(
        (final state) => Tuple2(SettingsIds.defaultSleepStateId, state),
      ),
      bloc.settings.getEnabledDeviceProvidersStream().map(
        (final state) => Tuple2(SettingsIds.deviceProvidersEnabled, state),
      ),
      bloc.settings
          .getScanDurationsAsStream(defaultValue: scanDuration)
          .map((final state) => Tuple2(SettingsIds.scanDurationId, state)),
      bloc.settings
          .getUpdateIntervalAsStream(defaultUpdateInterval: updateInterval)
          .map((final state) => Tuple2(SettingsIds.updateIntervalId, state)),
      bloc.settings.getShortcutsEnabledStream().map(
        (final state) => Tuple2(SettingsIds.shortcutEnabledId, state),
      ),
      bloc.settings.getGroupOfflineWarningEnabledStream().map(
        (final state) => Tuple2(SettingsIds.groupShowOfflineWarningId, state),
      ),
    ]).map((final event) {
      switch (event.item1) {
        case SettingsIds.defaultSleepStateId:
          if (event.item2 != null) {
            sleepState = event.item2 as LighthousePowerState;
          }
          break;
        case SettingsIds.deviceProvidersEnabled:
          if (event.item2 != null) {
            enabledDeviceProviders = event.item2 as List<LighthouseProviders>;
          }
          break;
        case SettingsIds.scanDurationId:
          if (event.item2 != null) {
            scanDuration = event.item2 as int;
          }
          break;
        case SettingsIds.updateIntervalId:
          if (event.item2 != null) {
            updateInterval = event.item2 as int;
          }
          break;
        case SettingsIds.shortcutEnabledId:
          if (event.item2 != null) {
            shortcutEnabled = event.item2 as bool;
          }
          break;
        case SettingsIds.groupShowOfflineWarningId:
          if (event.item2 != null) {
            groupShowOfflineWarning = event.item2 as bool;
          }
          break;
        default:
          assert(false, "Case not handled ${event.item1.name}");
      }
      return MainPageSettings._(
        sleepState: sleepState,
        enabledDeviceProviders: enabledDeviceProviders,
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
  static Widget mainPageSettingsStreamBuilder({
    required final LighthousePMBloc bloc,
    required final MainPageSettingsWidgetBuilder builder,
  }) {
    return StreamBuilder<MainPageSettings>(
      stream: mainPageSettingsStream(bloc),
      initialData: MainPageSettings.defaultMainPageSettings,
      builder: (
        final BuildContext context,
        final AsyncSnapshot<MainPageSettings> settingsSnapshot,
      ) {
        // TODO: destroy local database if the settings are null. Which shouldn't happen unlesss there is a database error.
        return builder(
          context,
          settingsSnapshot.data ?? MainPageSettings.defaultMainPageSettings,
        );
      },
    );
  }
}
