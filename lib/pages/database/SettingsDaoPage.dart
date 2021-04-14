import 'package:flutter/material.dart';
import 'package:lighthouse_pm/bloc.dart';
import 'package:lighthouse_pm/data/Database.dart';
import 'package:lighthouse_pm/data/dao/SettingsDao.dart';
import 'package:lighthouse_pm/lighthouseProvider/LighthousePowerState.dart';
import 'package:lighthouse_pm/widgets/DaoDataCreateAlertWidget.dart';
import 'package:lighthouse_pm/widgets/DaoDataWidget.dart';
import 'package:lighthouse_pm/widgets/DaoSimpleChangeStringAlertWidget.dart';
import 'package:toast/toast.dart';

import '../BasePage.dart';

class _SimpleSettingConverter extends DaoTableDataConverter<SimpleSetting> {
  final LighthousePMBloc bloc;

  _SimpleSettingConverter(this.bloc);

  String convertSettingIdToString(int id) {
    switch (id) {
      case SettingsDao.DEFAULT_SLEEP_STATE_ID:
        return 'DEFAULT_SLEEP_STATE_ID';
      case SettingsDao.VIVE_BASE_STATION_ENABLED_ID:
        return 'VIVE_BASE_STATION_ENABLED_ID';
      case SettingsDao.SCAN_DURATION_ID:
        return 'SCAN_DURATION_ID';
      case SettingsDao.PREFERRED_THEME_ID:
        return 'PREFERRED_THEME_ID';
      case SettingsDao.SHORTCUTS_ENABLED_ID:
        return 'SHORTCUTS_ENABLED_ID';
      case SettingsDao.GROUP_SHOW_OFFLINE_WARNING_ID:
        return 'GROUP_SHOW_OFFLINE_WARNING';
      case SettingsDao.UPDATE_INTERVAL_ID:
        return 'UPDATE_INTERVAL_ID';
      default:
        return 'UNKNOWN';
    }
  }

  String convertToBoolean(String? data) {
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

  String convertDataToString(int settingId, String? data) {
    switch (settingId) {
      case SettingsDao.DEFAULT_SLEEP_STATE_ID:
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
      case SettingsDao.VIVE_BASE_STATION_ENABLED_ID:
        return convertToBoolean(data);
      case SettingsDao.SCAN_DURATION_ID:
        if (data == null) {
          return 'DEFAULT';
        }
        final value = int.tryParse(data, radix: 10);
        if (value == null) {
          return 'COULD-NOT-PARSE-VALUE';
        }
        return '$value seconds';
      case SettingsDao.PREFERRED_THEME_ID:
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
      case SettingsDao.SHORTCUTS_ENABLED_ID:
        return convertToBoolean(data);
      case SettingsDao.GROUP_SHOW_OFFLINE_WARNING_ID:
        return convertToBoolean(data);
      case SettingsDao.UPDATE_INTERVAL_ID:
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
  String getDataSubtitle(SimpleSetting data) {
    return '"${data.data ?? 'null'}" (${convertDataToString(data.settingsId, data.data)})';
  }

  @override
  String getDataTitle(SimpleSetting data) {
    return '${data.settingsId} (${convertSettingIdToString(data.settingsId)})';
  }

  @override
  Future<void> deleteItem(SimpleSetting item) {
    return bloc.settings.deleteSimpleSetting(item);
  }

  @override
  Future<void> openChangeDialog(
      BuildContext context, SimpleSetting data) async {
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
  Future<void> openAddNewItemDialog(BuildContext context) async {
    final List<DaoDataCreateAlertDecorator<dynamic>> decorators = [
      DaoDataCreateAlertIntDecorator('Id', null, autoIncrement: false),
      DaoDataCreateAlertStringDecorator('Value', null),
    ];
    final saveNewItem = await DaoDataCreateAlertWidget.showCustomDialog(context, decorators);
    if (saveNewItem) {
      final int? id = (decorators[0] as DaoDataCreateAlertIntDecorator).getNewValue();
      final String? value = (decorators[1] as DaoDataCreateAlertStringDecorator).getNewValue();
      if (id == null) {
        Toast.show('No id set!', context);
        return;
      }
      await bloc.settings.insertSimpleSetting(SimpleSetting(settingsId: id, data: value));
    }
  }
}

class SettingsDaoPage extends BasePage with WithBlocStateless {
  @override
  Widget buildPage(BuildContext context) {
    final bloc = blocWithoutListen(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('SettingsDao'),
      ),
      body: ListView(
        children: [
          Column(
            children: [
              DaoTableDataWidget<SimpleSetting>(
                  'Simple settings',
                  bloc.settings.watchSimpleSettings,
                  _SimpleSettingConverter(bloc)),
            ],
          )
        ],
      ),
    );
  }
}
