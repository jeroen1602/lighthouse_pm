import 'package:device_info/device_info.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:lighthouse_provider/lighthouse_provider.dart';
import 'package:shared_platform/shared_platform.dart';

import '../database.dart';
import '../tables/simple_settings_table.dart';

part 'settings_dao.g.dart';

@DriftAccessor(tables: [SimpleSettings])
class SettingsDao extends DatabaseAccessor<LighthouseDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(LighthouseDatabase attachedDatabase) : super(attachedDatabase);

  static const scanDurationValues = [5, 10, 15, 20];
  static const updateIntervalValues = [1, 2, 3, 4, 5, 10, 20, 30];

  // region IDS
  //IDS
  static const defaultSleepStateId = 1;
  static const viveBaseStationEnabledId = 2;
  static const scanDurationId = 3;
  static const preferredThemeId = 4;
  static const shortcutEnabledId = 5;
  static const groupShowOfflineWarningId = 6;
  static const updateIntervalId = 7;

  // endregion

  Stream<LighthousePowerState> getSleepStateAsStream(
      {LighthousePowerState defaultValue = LighthousePowerState.sleep}) {
    return (select(simpleSettings)
          ..where((tbl) => tbl.settingsId.equals(defaultSleepStateId)))
        .watchSingleOrNull()
        .map((event) {
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

  Future<void> setSleepState(LighthousePowerState sleepState) {
    assert(
        sleepState == LighthousePowerState.sleep ||
            sleepState == LighthousePowerState.standby,
        'The new sleep state cannot be ${sleepState.text.toUpperCase()}');
    return into(simpleSettings).insert(
        SimpleSetting(
            settingsId: defaultSleepStateId, data: sleepState.id.toString()),
        mode: InsertMode.insertOrReplace);
  }

  Stream<bool> getGroupOfflineWarningEnabledStream() {
    return (select(simpleSettings)
          ..where((tbl) => tbl.settingsId.equals(groupShowOfflineWarningId)))
        .watchSingleOrNull()
        .map((event) {
      if (event == null) {
        return true;
      }
      if (event.data == '0' || event.data == null) {
        return false;
      }
      return true;
    });
  }

  Future<void> setGroupOfflineWarningEnabled(bool enabled) {
    return into(simpleSettings).insert(
        SimpleSetting(
            settingsId: groupShowOfflineWarningId, data: enabled ? '1' : '0'),
        mode: InsertMode.insertOrReplace);
  }

  Stream<bool> getViveBaseStationsEnabledStream() {
    return (select(simpleSettings)
          ..where((tbl) => tbl.settingsId.equals(viveBaseStationEnabledId)))
        .watchSingleOrNull()
        .map((event) {
      if (event == null || event.data == '0' || event.data == null) {
        return false;
      }
      return true;
    });
  }

  Future<void> setViveBaseStationEnabled(bool enabled) {
    return into(simpleSettings).insert(
        SimpleSetting(
            settingsId: viveBaseStationEnabledId, data: enabled ? '1' : '0'),
        mode: InsertMode.insertOrReplace);
  }

  Stream<bool> getShortcutsEnabledStream() {
    return (select(simpleSettings)
          ..where((tbl) => tbl.settingsId.equals(shortcutEnabledId)))
        .watchSingleOrNull()
        .map((event) {
      if (event == null || event.data == '0' || event.data == null) {
        return false;
      }
      return true;
    });
  }

  Future<void> setShortcutsEnabledStream(bool enabled) {
    return into(simpleSettings).insert(
        SimpleSetting(settingsId: shortcutEnabledId, data: enabled ? '1' : '0'),
        mode: InsertMode.insertOrReplace);
  }

  Stream<int> getScanDurationsAsStream({int defaultValue = 5}) {
    return (select(simpleSettings)
          ..where((tbl) => tbl.settingsId.equals(scanDurationId)))
        .watchSingleOrNull()
        .map((event) {
      if (event != null && event.data != null) {
        final number = int.tryParse(event.data!, radix: 10);
        if (number != null && scanDurationValues.contains(number)) {
          return number;
        }
      }
      return defaultValue;
    });
  }

  Future<void> setScanDuration(int duration) {
    assert(duration > 0, 'duration should be higher than 0');
    return into(simpleSettings).insert(
        SimpleSetting(
            settingsId: scanDurationId, data: duration.toRadixString(10)),
        mode: InsertMode.insertOrReplace);
  }

  Stream<int> getUpdateIntervalAsStream({int defaultUpdateInterval = 1}) {
    return (select(simpleSettings)
          ..where((tbl) => tbl.settingsId.equals(updateIntervalId)))
        .watchSingleOrNull()
        .map((event) {
      if (event != null && event.data != null) {
        final number = int.tryParse(event.data!, radix: 10);
        if (number != null && updateIntervalValues.contains(number)) {
          return number;
        }
      }
      return defaultUpdateInterval;
    });
  }

  Future<void> setUpdateInterval(int updateInterval) {
    assert(updateInterval > 0, 'update interval should be higher than 0');
    return into(simpleSettings).insert(
        SimpleSetting(
            settingsId: updateIntervalId,
            data: updateInterval.toRadixString(10)),
        mode: InsertMode.insertOrReplace);
  }

  Stream<ThemeMode> getPreferredThemeAsStream() {
    return (select(simpleSettings)
          ..where((tbl) => tbl.settingsId.equals(preferredThemeId)))
        .watchSingleOrNull()
        .asyncMap((event) async {
      if (event != null && event.data != null) {
        final themeIndex = int.tryParse(event.data!, radix: 10);
        if (themeIndex != null &&
            themeIndex >= 0 &&
            themeIndex < ThemeMode.values.length) {
          var themeMode = ThemeMode.values[themeIndex];
          // Make sure the theme mode is something that the current device supports.
          // How it´s become a value that isn't support is a question to solve then.
          if (themeMode == ThemeMode.system && !await supportsThemeModeSystem) {
            themeMode = ThemeMode.light;
          }
          return themeMode;
        }
      }
      return await defaultThemeMode;
    });
  }

  Future<void> setPreferredTheme(ThemeMode theme) {
    return into(simpleSettings).insert(
        SimpleSetting(
            settingsId: preferredThemeId, data: theme.index.toRadixString(10)),
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

  Stream<List<SimpleSetting>> get watchSimpleSettings {
    debugPrint(
        'WARNING using watchSimpleSettings, this should not happen in release mode!');
    return select(simpleSettings).watch();
  }

  Future<void> deleteSimpleSettingId(int settingId) {
    debugPrint(
        'WARNING using deleteSimpleSettingId, this should not happen in release mode!');
    return (delete(simpleSettings)
          ..where((tbl) => tbl.settingsId.equals(settingId)))
        .go();
  }

  Future<void> deleteSimpleSetting(SimpleSetting setting) {
    return deleteSimpleSettingId(setting.settingsId);
  }

  Future<void> insertSimpleSetting(SimpleSetting setting) {
    debugPrint(
        'WARNING using insertSimpleSetting, this should not happen in release mode!');
    return into(simpleSettings)
        .insert(setting, mode: InsertMode.insertOrReplace);
  }
}
