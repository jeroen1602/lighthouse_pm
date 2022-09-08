import 'package:flutter/material.dart';
import 'package:lighthouse_pm/bloc.dart';
import 'package:lighthouse_pm/data/database.dart';
import 'package:lighthouse_pm/data/dao/settings_dao.dart';
import 'package:lighthouse_provider/lighthouse_provider.dart';
import 'package:lighthouse_pm/widgets/content_container_widget.dart';
import 'package:lighthouse_pm/widgets/dao_data_create_alert_widget.dart';
import 'package:lighthouse_pm/widgets/dao_data_widget.dart';
import 'package:lighthouse_pm/widgets/dao_simple_change_string_alert_widget.dart';
import 'package:toast/toast.dart';

import '../base_page.dart';

class _SimpleSettingConverter extends DaoTableDataConverter<SimpleSetting> {
  final LighthousePMBloc bloc;

  _SimpleSettingConverter(this.bloc);

  String convertSettingIdToString(final int id) {
    switch (id) {
      case SettingsDao.defaultSleepStateId:
        return 'DEFAULT_SLEEP_STATE_ID';
      case SettingsDao.viveBaseStationEnabledId:
        return 'VIVE_BASE_STATION_ENABLED_ID';
      case SettingsDao.scanDurationId:
        return 'SCAN_DURATION_ID';
      case SettingsDao.preferredThemeId:
        return 'PREFERRED_THEME_ID';
      case SettingsDao.shortcutEnabledId:
        return 'SHORTCUTS_ENABLED_ID';
      case SettingsDao.groupShowOfflineWarningId:
        return 'GROUP_SHOW_OFFLINE_WARNING_ID';
      case SettingsDao.updateIntervalId:
        return 'UPDATE_INTERVAL_ID';
      default:
        return 'UNKNOWN';
    }
  }

  String convertToBoolean(final String? data) {
    if (data == "1") {
      return 'true';
    } else if (data == "0") {
      return 'false';
    } else if (data == null) {
      return 'DEFAULT';
    } else {
      return 'true (UNKNOWN STATE)';
    }
  }

  String convertDataToString(final int settingId, final String? data) {
    switch (settingId) {
      case SettingsDao.defaultSleepStateId:
        if (data == null) {
          return 'DEFAULT';
        }
        final value = int.tryParse(data, radix: 10);
        if (value == null) {
          return 'COULD-NOT-PARSE-VALUE';
        }
        try {
          return LighthousePowerState.fromId(value).text;
        } on ArgumentError {
          return 'NOT-LEGAL-POWER-STATE';
        }
      case SettingsDao.viveBaseStationEnabledId:
        return convertToBoolean(data);
      case SettingsDao.scanDurationId:
        if (data == null) {
          return 'DEFAULT';
        }
        final value = int.tryParse(data, radix: 10);
        if (value == null) {
          return 'COULD-NOT-PARSE-VALUE';
        }
        return '$value seconds';
      case SettingsDao.preferredThemeId:
        if (data == null) {
          return 'DEFAULT';
        }
        final value = int.tryParse(data, radix: 10);
        if (value == null) {
          return 'COULD-NOT-PARSE-VALUE';
        }
        if (value < 0 || value >= ThemeMode.values.length) {
          return 'NOT-LEGAL-THEME-MODE';
        }
        final themeMode = ThemeMode.values[value];
        return themeMode.toString();
      case SettingsDao.shortcutEnabledId:
        return convertToBoolean(data);
      case SettingsDao.groupShowOfflineWarningId:
        return convertToBoolean(data);
      case SettingsDao.updateIntervalId:
        if (data == null) {
          return 'DEFAULT';
        }
        final value = int.tryParse(data, radix: 10);
        if (value == null) {
          return 'COULD-NOT-PARSE-VALUE';
        }
        return '$value seconds';
      default:
        return 'UNKNOWN CONVERSION';
    }
  }

  @override
  String getDataSubtitle(final SimpleSetting data) {
    return '"${data.data ?? 'null'}" (${convertDataToString(data.settingsId, data.data)})';
  }

  @override
  String getDataTitle(final SimpleSetting data) {
    return '${data.settingsId} (${convertSettingIdToString(data.settingsId)})';
  }

  @override
  Future<void> deleteItem(final SimpleSetting item) {
    return bloc.settings.deleteSimpleSetting(item);
  }

  @override
  Future<void> openChangeDialog(
      final BuildContext context, final SimpleSetting data) async {
    final newValue = await DaoSimpleChangeStringAlertWidget.showCustomDialog(
        context,
        primaryKey: '${data.settingsId}',
        startValue: data.data);
    if (newValue == null) {
      return;
    }
    return bloc.settings.insertSimpleSetting(
        SimpleSetting(settingsId: data.settingsId, data: newValue));
  }

  @override
  Future<void> openAddNewItemDialog(final BuildContext context) async {
    final List<DaoDataCreateAlertDecorator<dynamic>> decorators = [
      DaoDataCreateAlertIntDecorator('Id', null, autoIncrement: false),
      DaoDataCreateAlertStringDecorator('Value', null),
    ];
    final saveNewItem =
        await DaoDataCreateAlertWidget.showCustomDialog(context, decorators);
    if (saveNewItem) {
      final int? id =
          (decorators[0] as DaoDataCreateAlertIntDecorator).getNewValue();
      final String? value =
          (decorators[1] as DaoDataCreateAlertStringDecorator).getNewValue();
      if (id == null) {
        Toast.show('No id set!');
        return;
      }
      await bloc.settings
          .insertSimpleSetting(SimpleSetting(settingsId: id, data: value));
    }
  }
}

class SettingsDaoPage extends BasePage with WithBlocStateless {
  const SettingsDaoPage({final Key? key}) : super(key: key);

  @override
  Widget buildPage(final BuildContext context) {
    final bloc = blocWithoutListen(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SettingsDao'),
      ),
      body: ContentContainerListView(
        children: [
          DaoTableDataWidget<SimpleSetting>('Simple settings',
              bloc.settings.watchSimpleSettings, _SimpleSettingConverter(bloc)),
        ],
      ),
    );
  }
}
