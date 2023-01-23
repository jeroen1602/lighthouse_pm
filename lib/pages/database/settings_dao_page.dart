import 'package:flutter/material.dart';
import 'package:lighthouse_pm/bloc.dart';
import 'package:lighthouse_pm/data/dao/settings_dao.dart';
import 'package:lighthouse_pm/data/database.dart';
import 'package:lighthouse_pm/data/helper_structures/lighthouse_providers.dart';
import 'package:lighthouse_pm/data/local/app_style.dart';
import 'package:lighthouse_pm/widgets/content_container_widget.dart';
import 'package:lighthouse_pm/widgets/dao_data_create_alert_widget.dart';
import 'package:lighthouse_pm/widgets/dao_data_widget.dart';
import 'package:lighthouse_pm/widgets/dao_simple_change_string_alert_widget.dart';
import 'package:lighthouse_provider/lighthouse_provider.dart';
import 'package:toast/toast.dart';

import '../base_page.dart';

class _SimpleSettingConverter extends DaoTableDataConverter<SimpleSetting> {
  final LighthousePMBloc bloc;

  _SimpleSettingConverter(this.bloc);

  SettingsIds? getSettingFromId(final int id) {
    return SettingsIds.values
        .cast<SettingsIds?>()
        .firstWhere((final e) => e?.value == id, orElse: () => null);
  }

  String convertSettingIdToString(final int id) {
    final setting = getSettingFromId(id);
    if (setting != null) {
      var output = setting.name;
      if (setting.deprecated) {
        output += ' (Deprecated)';
      }
      return output;
    }

    return 'Unknown';
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
    final setting = getSettingFromId(settingId);
    switch (setting) {
      case SettingsIds.defaultSleepStateId:
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
      // ignore: deprecated_member_use_from_same_package
      case SettingsIds.viveBaseStationEnabledId:
        return convertToBoolean(data);
      case SettingsIds.scanDurationId:
        if (data == null) {
          return 'DEFAULT';
        }
        final value = int.tryParse(data, radix: 10);
        if (value == null) {
          return 'COULD-NOT-PARSE-VALUE';
        }
        return '$value seconds';
      case SettingsIds.preferredThemeId:
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
      case SettingsIds.shortcutEnabledId:
        return convertToBoolean(data);
      case SettingsIds.groupShowOfflineWarningId:
        return convertToBoolean(data);
      case SettingsIds.updateIntervalId:
        if (data == null) {
          return 'DEFAULT';
        }
        final value = int.tryParse(data, radix: 10);
        if (value == null) {
          return 'COULD-NOT-PARSE-VALUE';
        }
        return '$value seconds';
      case SettingsIds.appStyleId:
        if (data == null) {
          return 'DEFAULT';
        }
        final value = int.tryParse(data, radix: 10);
        if (value == null) {
          return 'COULD-NOT-PARSE-VALUE';
        }
        if (value < 0 || value >= AppStyle.values.length) {
          return 'NOT-LEGAL-APP-STYLE';
        }
        final appStyle = AppStyle.values[value];
        return appStyle.toString();
      case SettingsIds.deviceProvidersEnabled:
        if (data == null) {
          return 'DEFAULT';
        }
        final items = data
            .split(",")
            .map((final e) => int.tryParse(e, radix: 10))
            .where((final e) =>
                e != null && e >= 0 && e < LighthouseProviders.values.length)
            .cast<int>()
            .map((final e) => '${LighthouseProviders.values[e].name} ($e)')
            .join(", ");
        return items;
      case null:
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
