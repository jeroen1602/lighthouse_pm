import 'package:device_info/device_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lighthouse_pm/lighthouseProvider/LighthousePowerState.dart';
import 'package:lighthouse_pm/platformSpecific/shared/LocalPlatform.dart';
import 'package:moor/moor.dart';

import '../Database.dart';
import '../tables/SimpleSettingsTable.dart';

part 'SettingsDao.g.dart';

@UseDao(tables: [SimpleSettings])
class SettingsDao extends DatabaseAccessor<LighthouseDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(LighthouseDatabase attachedDatabase) : super(attachedDatabase);

  static const SCAN_DURATION_VALUES = const [5, 10, 15, 20];

  // region IDS
  //IDS
  static const DEFAULT_SLEEP_STATE_ID = 1;
  static const VIVE_BASE_STATION_ENABLED_ID = 2;
  static const SCAN_DURATION_ID = 3;
  static const PREFERRED_THEME_ID = 4;
  static const SHORTCUTS_ENABLED_ID = 5;

  // endregion

  Stream<LighthousePowerState> getSleepStateAsStream(
      {LighthousePowerState defaultValue = LighthousePowerState.SLEEP}) {
    return (select(simpleSettings)
          ..where((tbl) => tbl.settingsId.equals(DEFAULT_SLEEP_STATE_ID)))
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

  Future<void> insertSleepState(LighthousePowerState sleepState) {
    assert(
        sleepState == LighthousePowerState.SLEEP ||
            sleepState == LighthousePowerState.STANDBY,
        'The new sleep state cannot be ${sleepState.text.toUpperCase()}');
    return into(simpleSettings).insert(
        SimpleSetting(
            settingsId: DEFAULT_SLEEP_STATE_ID, data: sleepState.id.toString()),
        mode: InsertMode.insertOrReplace);
  }

  Stream<bool> getViveBaseStationsEnabledStream() {
    return (select(simpleSettings)
          ..where((tbl) => tbl.settingsId.equals(VIVE_BASE_STATION_ENABLED_ID)))
        .watch()
        .map((event) {
      if (event.isEmpty) {
        return false;
      }
      if (event.length == 1 &&
          (event[0].data == '0' || event[0].data == null)) {
        return false;
      }
      return true;
    });
  }

  Future<void> setViveBaseStationEnabled(bool enabled) {
    return into(simpleSettings).insert(
        SimpleSetting(
            settingsId: VIVE_BASE_STATION_ENABLED_ID,
            data: enabled ? '1' : '0'),
        mode: InsertMode.insertOrReplace);
  }

  Stream<bool> getShortcutsEnabledStream() {
    return (select(simpleSettings)
          ..where((tbl) => tbl.settingsId.equals(SHORTCUTS_ENABLED_ID)))
        .watch()
        .map((event) {
      if (event.isEmpty) {
        return false;
      }
      if (event.length == 1 &&
          (event[0].data == '0' || event[0].data == null)) {
        return false;
      }
      return true;
    });
  }

  Future<void> setShortcutsEnabledStream(bool enabled) {
    return into(simpleSettings).insert(
        SimpleSetting(
            settingsId: SHORTCUTS_ENABLED_ID, data: enabled ? '1' : '0'),
        mode: InsertMode.insertOrReplace);
  }

  Stream<int> getScanDurationsAsStream({int defaultValue = 5}) {
    return (select(simpleSettings)
          ..where((tbl) => tbl.settingsId.equals(SCAN_DURATION_ID)))
        .watchSingleOrNull()
        .map((event) {
      if (event != null && event.data != null) {
        final number = int.tryParse(event.data!, radix: 10);
        if (number != null) {
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
            settingsId: SCAN_DURATION_ID, data: duration.toRadixString(10)),
        mode: InsertMode.insertOrReplace);
  }

  Stream<ThemeMode> getPreferredThemeAsStream() {
    return (select(simpleSettings)
          ..where((tbl) => tbl.settingsId.equals(PREFERRED_THEME_ID)))
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
            settingsId: PREFERRED_THEME_ID,
            data: '${theme.index.toRadixString(10)}'),
        mode: InsertMode.insertOrReplace);
  }

  /// Check if the currently running device supports system mode theme.
  static Future<bool> get supportsThemeModeSystem async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (LocalPlatform.isAndroid) {
      final android = await deviceInfo.androidInfo;
      if (android.version.sdkInt >= 29 /* Android 10 */) {
        return true;
      }
    } else if (LocalPlatform.isIOS) {
      final ios = await deviceInfo.iosInfo;
      final iosVersion = double.tryParse(ios.systemVersion);
      if (iosVersion != null && iosVersion >= 13.0 /* iOS 13.0 */) {
        return true;
      }
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
