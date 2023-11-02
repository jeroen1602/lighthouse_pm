import 'package:device_info_plus/device_info_plus.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:lighthouse_pm/data/helper_structures/lighthouse_providers.dart';
import 'package:lighthouse_pm/data/local/app_style.dart';
import 'package:lighthouse_provider/lighthouse_provider.dart';
import 'package:shared_platform/shared_platform.dart';

import '../database.dart';
import '../tables/simple_settings_table.dart';

part 'settings_dao.g.dart';

// region IDS
enum SettingsIds {
  defaultSleepStateId(1, "defaultSleepStateId"),
  @Deprecated("Use [deviceProvidersEnabled] instead")
  viveBaseStationEnabledId(2, "viveBaseStationEnabledId", true),
  scanDurationId(3, "scanDurationId"),
  preferredThemeId(4, "preferredThemeId"),
  shortcutEnabledId(5, "shortcutEnabledId"),
  groupShowOfflineWarningId(6, "groupShowOfflineWarningId"),
  updateIntervalId(7, "updateIntervalId"),
  appStyleId(8, "appStyleId"),
  deviceProvidersEnabled(9, "deviceProvidersEnabled");

  final int value;

  final String name;

  final bool deprecated;

  const SettingsIds(this.value, this.name, [this.deprecated = false]);
}
// endregion

@DriftAccessor(tables: [SimpleSettings])
class SettingsDao extends DatabaseAccessor<LighthouseDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(super.attachedDatabase);

  static const scanDurationValues = [5, 10, 15, 20];
  static const updateIntervalValues = [1, 2, 3, 4, 5, 10, 20, 30];
  static const defaultDeviceProviders = LighthouseProviders.values;

  Stream<LighthousePowerState> getSleepStateAsStream(
      {final LighthousePowerState defaultValue = LighthousePowerState.sleep}) {
    return (select(simpleSettings)
          ..where((final tbl) =>
              tbl.settingsId.equals(SettingsIds.defaultSleepStateId.value)))
        .watchSingleOrNull()
        .map((final event) {
      if (event != null && event.data != null) {
        try {
          final data = int.parse(event.data!, radix: 10);
          return LighthousePowerState.fromId(data);
        } on FormatException {
          debugPrint('Could not convert data returned to a string');
        } on ArgumentError {
          debugPrint(
              'Could not convert data returned to Lighthouse power state');
        }
      }
      return defaultValue;
    });
  }

  Future<void> setSleepState(final LighthousePowerState sleepState) {
    assert(
        sleepState == LighthousePowerState.sleep ||
            sleepState == LighthousePowerState.standby,
        'The new sleep state cannot be ${sleepState.text.toUpperCase()}');
    return into(simpleSettings).insert(
        SimpleSetting(
            settingsId: SettingsIds.defaultSleepStateId.value,
            data: sleepState.index.toString()),
        mode: InsertMode.insertOrReplace);
  }

  Stream<bool> getGroupOfflineWarningEnabledStream() {
    return (select(simpleSettings)
          ..where((final tbl) => tbl.settingsId
              .equals(SettingsIds.groupShowOfflineWarningId.value)))
        .watchSingleOrNull()
        .map((final event) {
      if (event == null) {
        return true;
      }
      if (event.data == '0' || event.data == null) {
        return false;
      }
      return true;
    });
  }

  Future<void> setGroupOfflineWarningEnabled(final bool enabled) {
    return into(simpleSettings).insert(
        SimpleSetting(
            settingsId: SettingsIds.groupShowOfflineWarningId.value,
            data: enabled ? '1' : '0'),
        mode: InsertMode.insertOrReplace);
  }

  Stream<List<LighthouseProviders>> getEnabledDeviceProvidersStream() {
    return (select(simpleSettings)
          ..where((final tbl) =>
              tbl.settingsId.equals(SettingsIds.deviceProvidersEnabled.value)))
        .watchSingleOrNull()
        .map((final event) {
      final data = event?.data;
      if (data == null) {
        return defaultDeviceProviders;
      }
      final enabled = data
          .split(",")
          .map((final e) => int.tryParse(e, radix: 10))
          .where((final e) =>
              e != null && e >= 0 && e < LighthouseProviders.values.length)
          .cast<int>()
          .map((final e) => LighthouseProviders.values[e])
          .toList();

      return enabled;
    });
  }

  Future<void> setEnabledDeviceProvidersStream(
      final List<LighthouseProviders> enabledProviders) {
    return into(simpleSettings).insert(
        SimpleSetting(
            settingsId: SettingsIds.deviceProvidersEnabled.value,
            data: enabledProviders.map((final e) => e.index).join(",")),
        mode: InsertMode.insertOrReplace);
  }

  Stream<bool> getShortcutsEnabledStream() {
    return (select(simpleSettings)
          ..where((final tbl) =>
              tbl.settingsId.equals(SettingsIds.shortcutEnabledId.value)))
        .watchSingleOrNull()
        .map((final event) {
      if (event == null || event.data == '0' || event.data == null) {
        return false;
      }
      return true;
    });
  }

  Future<void> setShortcutsEnabledStream(final bool enabled) {
    return into(simpleSettings).insert(
        SimpleSetting(
            settingsId: SettingsIds.shortcutEnabledId.value,
            data: enabled ? '1' : '0'),
        mode: InsertMode.insertOrReplace);
  }

  Stream<int> getScanDurationsAsStream({final int defaultValue = 5}) {
    return (select(simpleSettings)
          ..where((final tbl) =>
              tbl.settingsId.equals(SettingsIds.scanDurationId.value)))
        .watchSingleOrNull()
        .map((final event) {
      if (event != null && event.data != null) {
        final number = int.tryParse(event.data!, radix: 10);
        if (number != null && scanDurationValues.contains(number)) {
          return number;
        }
      }
      return defaultValue;
    });
  }

  Future<void> setScanDuration(final int duration) {
    assert(duration > 0, 'duration should be higher than 0');
    return into(simpleSettings).insert(
        SimpleSetting(
            settingsId: SettingsIds.scanDurationId.value,
            data: duration.toRadixString(10)),
        mode: InsertMode.insertOrReplace);
  }

  Stream<int> getUpdateIntervalAsStream({final int defaultUpdateInterval = 1}) {
    return (select(simpleSettings)
          ..where((final tbl) =>
              tbl.settingsId.equals(SettingsIds.updateIntervalId.value)))
        .watchSingleOrNull()
        .map((final event) {
      if (event != null && event.data != null) {
        final number = int.tryParse(event.data!, radix: 10);
        if (number != null && updateIntervalValues.contains(number)) {
          return number;
        }
      }
      return defaultUpdateInterval;
    });
  }

  Future<void> setUpdateInterval(final int updateInterval) {
    assert(updateInterval > 0, 'update interval should be higher than 0');
    return into(simpleSettings).insert(
        SimpleSetting(
            settingsId: SettingsIds.updateIntervalId.value,
            data: updateInterval.toRadixString(10)),
        mode: InsertMode.insertOrReplace);
  }

  Stream<ThemeMode> getPreferredThemeAsStream() {
    return (select(simpleSettings)
          ..where((final tbl) =>
              tbl.settingsId.equals(SettingsIds.preferredThemeId.value)))
        .watchSingleOrNull()
        .asyncMap((final event) async {
      if (event != null && event.data != null) {
        final themeIndex = int.tryParse(event.data!, radix: 10);
        if (themeIndex != null &&
            themeIndex >= 0 &&
            themeIndex < ThemeMode.values.length) {
          var themeMode = ThemeMode.values[themeIndex];
          // Make sure the theme mode is something that the current device supports.
          // How it´s become a value that isn't supported is a question to solve then.
          if (themeMode == ThemeMode.system && !await supportsThemeModeSystem) {
            themeMode = ThemeMode.light;
          }
          return themeMode;
        }
      }
      return await defaultThemeMode;
    });
  }

  Future<void> setPreferredTheme(final ThemeMode theme) {
    return into(simpleSettings).insert(
        SimpleSetting(
            settingsId: SettingsIds.preferredThemeId.value,
            data: theme.index.toRadixString(10)),
        mode: InsertMode.insertOrReplace);
  }

  /// Check if the currently running device supports system mode theme.
  static Future<bool> get supportsThemeModeSystem async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (SharedPlatform.isAndroid) {
      final android = await deviceInfo.androidInfo;
      if (android.version.sdkInt >= 29 /* Android 10 */) {
        return true;
      }
    } else if (SharedPlatform.isIOS) {
      final ios = await deviceInfo.iosInfo;
      final iosVersion = double.tryParse(ios.systemVersion);
      if (iosVersion != null && iosVersion >= 13.0 /* iOS 13.0 */) {
        return true;
      }
    } else if (SharedPlatform.isLinux) {
      // TODO: check if the current platform supports it
      return true;
    } else if (SharedPlatform.isWeb) {
      // TODO: check if the current browser actually supports it.
      return true;
    }
    return false;
  }

  /// Get the default theme mode taking [supportsThemeModeSystem]
  /// into consideration.
  static Future<ThemeMode> get defaultThemeMode async {
    if (await supportsThemeModeSystem) {
      return ThemeMode.system;
    }
    return ThemeMode.light;
  }

  Stream<AppStyle> getPreferredStyleAsStream() {
    return (select(simpleSettings)
          ..where((final tbl) =>
              tbl.settingsId.equals(SettingsIds.appStyleId.value)))
        .watchSingleOrNull()
        .asyncMap((final event) async {
      if (event != null && event.data != null) {
        final styleIndex = int.tryParse(event.data!, radix: 10);
        if (styleIndex != null &&
            styleIndex >= 0 &&
            styleIndex < AppStyle.values.length) {
          var chosenStyle = AppStyle.values[styleIndex];
          // Make sure the chosen style is something that the current device supports.
          // How it´s become a value that isn't supported is a question to solve then.
          final supportedStyles = await supportedAppStyles;
          if (!supportedStyles.contains(chosenStyle)) {
            chosenStyle = await defaultAppStyle;
          }
          return chosenStyle;
        }
      }
      return await defaultAppStyle;
    });
  }

  Future<void> setPreferredStyle(final AppStyle style) {
    return into(simpleSettings).insert(
        SimpleSetting(
            settingsId: SettingsIds.appStyleId.value,
            data: style.index.toRadixString(10)),
        mode: InsertMode.insertOrReplace);
  }

  static Future<List<AppStyle>> get supportedAppStyles async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final styles = [AppStyle.material];
    if (SharedPlatform.isLinux ||
        SharedPlatform.isWindows ||
        SharedPlatform.isAndroid &&
            (await deviceInfo.androidInfo).version.sdkInt >=
                31 /* Android 12 */) {
      styles.add(AppStyle.materialDynamic);
    }
    return styles;
  }

  static Future<AppStyle> get defaultAppStyle async {
    final supportedStyles = await supportedAppStyles;
    if (supportedStyles.contains(AppStyle.materialDynamic)) {
      return AppStyle.materialDynamic;
    }
    return supportedStyles.cast<AppStyle?>()[0] ?? AppStyle.material;
  }

  Stream<List<SimpleSetting>> get watchSimpleSettings {
    debugPrint(
        'WARNING using watchSimpleSettings, this should not happen in release mode!');
    return select(simpleSettings).watch();
  }

  Future<void> deleteSimpleSettingId(final int settingId) {
    debugPrint(
        'WARNING using deleteSimpleSettingId, this should not happen in release mode!');
    return (delete(simpleSettings)
          ..where((final tbl) => tbl.settingsId.equals(settingId)))
        .go();
  }

  Future<void> deleteSimpleSetting(final SimpleSetting setting) {
    return deleteSimpleSettingId(setting.settingsId);
  }

  Future<void> insertSimpleSetting(final SimpleSetting setting) {
    debugPrint(
        'WARNING using insertSimpleSetting, this should not happen in release mode!');
    return into(simpleSettings)
        .insert(setting, mode: InsertMode.insertOrReplace);
  }
}
