import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lighthouse_pm/data/Database.dart';
import 'package:lighthouse_pm/data/bloc/ViveBaseStationBloc.dart';
import 'package:lighthouse_pm/lighthouseProvider/LighthousePowerState.dart';
import 'package:moor_flutter/moor_flutter.dart';

class LighthousePMBloc {
  final LighthouseDatabase db;
  final SettingsBloc settings;
  final ViveBaseStationBloc viveBaseStation;

  LighthousePMBloc(LighthouseDatabase db)
      : db = db,
        settings = SettingsBloc(db),
        viveBaseStation = ViveBaseStationBloc(db);

  Stream<List<Nickname>> get watchSavedNicknames => db.watchSavedNicknames;

  Stream<Nickname /* ? */ > watchNicknameForMacAddress(String macAddress) {
    return db.watchNicknameForMacAddress(macAddress);
  }

  Future<int> insertNickname(Nickname nickname) =>
      db.insertNewNickname(nickname);

  Future deleteNicknames(List<String> macAddresses) =>
      db.deleteNicknames(macAddresses);

  Stream<List<NicknamesLastSeenJoin>> watchSavedNicknamesWithLastSeen() {
    return db.watchSavedNicknamesWithLastSeen();
  }

  Future<int> insertLastSeenDevice(LastSeenDevice lastSeen) {
    return db.insertLastSeenDevice(lastSeen);
  }

  Future<void> deleteAllLastSeen() {
    return db.deleteAllLastSeen();
  }

  void close() {
    db.close();
  }
}

class SettingsBloc {
  final LighthouseDatabase db;

  SettingsBloc(this.db);

  // region IDS
  static const SCAN_DURATION_VALUES = const [5, 10, 15, 20];

  //IDS
  static const DEFAULT_SLEEP_STATE_ID = 1;
  static const VIVE_BASE_STATION_ENABLED_ID = 2;
  static const SCAN_DURATION_ID = 3;
  static const PREFERED_THEME_ID = 4;

  // endregion

  Stream<LighthousePowerState> getSleepStateAsStream(
      {LighthousePowerState defaultValue = LighthousePowerState.SLEEP}) {
    return (db.select(db.simpleSettings)
          ..where((tbl) => tbl.settingsId.equals(DEFAULT_SLEEP_STATE_ID)))
        .watch()
        .map((event) {
      if (event.length >= 1 && event[0].data != null) {
        try {
          final data = int.parse(event[0].data, radix: 10);
          return LighthousePowerState.fromId(data);
        } on FormatException {
          debugPrint('Could not convert data returned to a string');
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
    return db.into(db.simpleSettings).insert(
        SimpleSetting(
            settingsId: DEFAULT_SLEEP_STATE_ID, data: sleepState.id.toString()),
        mode: InsertMode.insertOrReplace);
  }

  Stream<bool> getViveBaseStationsEnabledStream() {
    return (db.select(db.simpleSettings)
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
    return db.into(db.simpleSettings).insert(
        SimpleSetting(
            settingsId: VIVE_BASE_STATION_ENABLED_ID, data: enabled ? '1' : '0'),
        mode: InsertMode.insertOrReplace);
  }

  Stream<int> getScanDurationsAsStream({int defaultValue = 5}) {
    return (db.select(db.simpleSettings)
          ..where((tbl) => tbl.settingsId.equals(SCAN_DURATION_ID)))
        .watch()
        .map((event) {
      if (event.length == 1 && event[0].data != null) {
        return int.tryParse(event[0].data, radix: 10);
      } else {
        return defaultValue;
      }
    });
  }

  Future<void> setScanDuration(int duration) {
    assert(duration > 0, 'duration should be higher than 0');
    return db.into(db.simpleSettings).insert(
        SimpleSetting(settingsId: SCAN_DURATION_ID, data: duration.toRadixString(10)),
        mode: InsertMode.insertOrReplace);
  }

  Stream<ThemeMode> getPreferedThemeAsStream() {
    return (db.select(db.simpleSettings)
          ..where((tbl) => tbl.settingsId.equals(PREFERED_THEME_ID)))
        .watch()
        .asyncMap((event) async {
      if (event.length == 1 && event[0].data != null) {
        final themeIndex = int.tryParse(event[0].data, radix: 10);
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

  Future<void> setPreferedTheme(ThemeMode theme) {
    return db.into(db.simpleSettings).insert(
        SimpleSetting(
            settingsId: PREFERED_THEME_ID, data: '${theme.index.toRadixString(10)}'),
        mode: InsertMode.insertOrReplace);
  }

  /// Check if the currently running device supports system mode theme.
  static Future<bool> get supportsThemeModeSystem async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final android = await deviceInfo.androidInfo;
      if (android.version.sdkInt >= 29 /* Android 10 */) {
        return true;
      }
    } else if (Platform.isIOS) {
      final ios = await deviceInfo.iosInfo;
      var iosVersion = double.tryParse(ios.systemVersion);
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
}
