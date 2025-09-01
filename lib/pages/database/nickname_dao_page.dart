import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:lighthouse_pm/bloc.dart';
import 'package:lighthouse_pm/data/database.dart';
import 'package:lighthouse_pm/data/validators/mac_validator.dart';
import 'package:lighthouse_pm/widgets/content_container_widget.dart';
import 'package:lighthouse_pm/widgets/dao_data_create_alert_widget.dart';
import 'package:lighthouse_pm/widgets/dao_data_widget.dart';
import 'package:lighthouse_pm/widgets/dao_simple_change_string_alert_widget.dart';
import 'package:shared_platform/shared_platform.dart';
import 'package:toast/toast.dart';

import '../base_page.dart';

class _NicknameConverter extends DaoTableDataConverter<Nickname> {
  final LighthousePMBloc bloc;

  _NicknameConverter(this.bloc);

  @override
  String getDataSubtitle(final Nickname data) {
    return data.nickname;
  }

  @override
  String getDataTitle(final Nickname data) {
    return data.deviceId;
  }

  @override
  Future<void> deleteItem(final Nickname item) {
    return bloc.nicknames.deleteNicknames([item.deviceId]);
  }

  @override
  Future<void> openChangeDialog(
    final BuildContext context,
    final Nickname data,
  ) async {
    final newValue = await DaoSimpleChangeStringAlertWidget.showCustomDialog(
      context,
      primaryKey: data.deviceId,
      startValue: data.nickname,
    );
    if (newValue == null) {
      return;
    }
    await bloc.nicknames.insertNickname(
      Nickname(deviceId: data.deviceId, nickname: newValue),
    );
  }

  @override
  Future<void> openAddNewItemDialog(final BuildContext context) async {
    final List<DaoDataCreateAlertDecorator<dynamic>> decorators = [
      DaoDataCreateAlertStringDecorator(
        'Device id',
        null,
        validator: SharedPlatform.isAndroid ? MacValidator.macValidator : null,
      ),
      DaoDataCreateAlertStringDecorator('Nickname', null),
    ];
    final saveNewItem = await DaoDataCreateAlertWidget.showCustomDialog(
      context,
      decorators,
    );
    if (saveNewItem) {
      String? deviceId = (decorators[0] as DaoDataCreateAlertStringDecorator)
          .getNewValue();
      if (SharedPlatform.isAndroid) {
        deviceId = deviceId?.trim().toUpperCase();
      }
      final String? value = (decorators[1] as DaoDataCreateAlertStringDecorator)
          .getNewValue();
      if (deviceId == null) {
        if (context.mounted) {
          ToastContext().init(context);
          Toast.show('No device id set!');
        }
        return;
      }
      if (value == null) {
        if (context.mounted) {
          ToastContext().init(context);
          Toast.show('No nickname set!');
        }
        return;
      }
      await bloc.nicknames.insertNickname(
        Nickname(deviceId: deviceId, nickname: value),
      );
    }
  }
}

class _LastSeenConverter extends DaoTableDataConverter<LastSeenDevice> {
  final LighthousePMBloc bloc;

  _LastSeenConverter(this.bloc);

  @override
  String getDataSubtitle(final LastSeenDevice data) {
    return data.lastSeen.toIso8601String();
  }

  @override
  String getDataTitle(final LastSeenDevice data) {
    return data.deviceId;
  }

  @override
  Future<void> deleteItem(final LastSeenDevice item) {
    return bloc.nicknames.deleteLastSeen(item);
  }

  @override
  Future<void> openChangeDialog(
    final BuildContext context,
    final LastSeenDevice data,
  ) async {
    final newValue = await DaoSimpleChangeStringAlertWidget.showCustomDialog(
      context,
      primaryKey: data.deviceId,
      startValue: data.lastSeen.toIso8601String(),
    );
    if (newValue == null) {
      return;
    }
    try {
      final newData = DateTime.parse(newValue);
      await bloc.nicknames.insertLastSeenDevice(
        LastSeenDevicesCompanion.insert(
          deviceId: data.deviceId,
          lastSeen: drift.Value(newData),
        ),
      );
    } on FormatException {
      if (context.mounted) {
        ToastContext().init(context);
        Toast.show('That didn\'t work');
      }
    }
  }

  @override
  Future<void> openAddNewItemDialog(final BuildContext context) async {
    final List<DaoDataCreateAlertDecorator<dynamic>> decorators = [
      DaoDataCreateAlertStringDecorator(
        'Device id',
        null,
        validator: SharedPlatform.isAndroid ? MacValidator.macValidator : null,
      ),
      // TODO: use date picker
      DaoDataCreateAlertStringDecorator(
        'Last seen',
        DateTime.now().toIso8601String(),
      ),
    ];
    final saveNewItem = await DaoDataCreateAlertWidget.showCustomDialog(
      context,
      decorators,
    );
    if (saveNewItem) {
      String? deviceId = (decorators[0] as DaoDataCreateAlertStringDecorator)
          .getNewValue();
      if (SharedPlatform.isAndroid) {
        deviceId = deviceId?.trim().toUpperCase();
      }
      final String? value = (decorators[1] as DaoDataCreateAlertStringDecorator)
          .getNewValue();
      if (deviceId == null) {
        if (context.mounted) {
          ToastContext().init(context);
          Toast.show('No device id set!');
        }
        return;
      }
      DateTime? date;
      if (value != null && value.trim() != '') {
        date = DateTime.tryParse(value);
      }
      date ??= DateTime.now();
      await bloc.nicknames.insertLastSeenDevice(
        LastSeenDevicesCompanion.insert(
          deviceId: deviceId,
          lastSeen: drift.Value(date),
        ),
      );
    }
  }
}

class NicknameDaoPage extends BasePage with WithBlocStateless {
  const NicknameDaoPage({super.key});

  @override
  Widget buildPage(final BuildContext context) {
    final bloc = blocWithoutListen(context);

    return Scaffold(
      appBar: AppBar(title: const Text('NicknameDao')),
      body: ContentContainerListView(
        children: [
          DaoTableDataWidget<Nickname>(
            'Nicknames',
            bloc.nicknames.watchNicknames,
            _NicknameConverter(bloc),
          ),
          DaoTableDataWidget<LastSeenDevice>(
            'Last seen devices',
            bloc.nicknames.watchLastSeenDevices,
            _LastSeenConverter(bloc),
          ),
        ],
      ),
    );
  }
}
