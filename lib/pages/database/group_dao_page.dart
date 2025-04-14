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

class _GroupConverter extends DaoTableDataConverter<Group> {
  final LighthousePMBloc bloc;

  _GroupConverter(this.bloc);

  @override
  String getDataSubtitle(final Group data) {
    return data.name;
  }

  @override
  String getDataTitle(final Group data) {
    return '${data.id}';
  }

  @override
  Future<void> deleteItem(final Group item) {
    return bloc.groups.deleteGroup(item.id);
  }

  @override
  Future<void> openChangeDialog(
    final BuildContext context,
    final Group data,
  ) async {
    final newValue = await DaoSimpleChangeStringAlertWidget.showCustomDialog(
      context,
      primaryKey: '${data.id}',
      startValue: data.name,
    );
    if (newValue == null) {
      return;
    }
    await bloc.groups.insertEmptyGroup(
      GroupsCompanion.insert(id: drift.Value(data.id), name: newValue),
    );
  }

  @override
  Future<void> openAddNewItemDialog(final BuildContext context) async {
    final List<DaoDataCreateAlertDecorator<dynamic>> decorators = [
      DaoDataCreateAlertIntDecorator('Group id', null, autoIncrement: true),
      DaoDataCreateAlertStringDecorator('Name', null),
    ];
    final saveNewItem = await DaoDataCreateAlertWidget.showCustomDialog(
      context,
      decorators,
    );
    if (saveNewItem) {
      final int? id =
          (decorators[0] as DaoDataCreateAlertIntDecorator).getNewValue();
      final String? value =
          (decorators[1] as DaoDataCreateAlertStringDecorator).getNewValue();
      if (value == null) {
        if (context.mounted) {
          ToastContext().init(context);
          Toast.show('No name set!');
        }
        return;
      }
      if (id == null) {
        await bloc.groups.insertEmptyGroup(GroupsCompanion.insert(name: value));
      } else {
        await bloc.groups.insertEmptyGroup(
          GroupsCompanion.insert(id: drift.Value(id), name: value),
        );
      }
    }
  }
}

class _GroupEntryConverter extends DaoTableDataConverter<GroupEntry> {
  final LighthousePMBloc bloc;

  _GroupEntryConverter(this.bloc);

  @override
  String getDataSubtitle(final GroupEntry data) {
    return '${data.groupId}';
  }

  @override
  String getDataTitle(final GroupEntry data) {
    return data.deviceId;
  }

  @override
  Future<void> deleteItem(final GroupEntry item) {
    return bloc.groups.deleteGroupEntry(item.deviceId);
  }

  @override
  Future<void> openChangeDialog(
    final BuildContext context,
    final GroupEntry data,
  ) async {
    final newValue = await DaoSimpleChangeStringAlertWidget.showCustomDialog(
      context,
      primaryKey: data.deviceId,
      startValue: '${data.groupId}',
    );
    if (newValue == null) {
      return;
    }
    final intValue = int.tryParse(newValue, radix: 10);
    if (intValue == null || intValue < 0) {
      if (context.mounted) {
        ToastContext().init(context);
        Toast.show('new group id must be a number and cam\'t be negative');
      }
      return;
    }
    await bloc.groups.insertGroupEntry(
      GroupEntry(deviceId: data.deviceId, groupId: intValue),
    );
  }

  @override
  Future<void> openAddNewItemDialog(final BuildContext context) async {
    final List<DaoDataCreateAlertDecorator<dynamic>> decorators = [
      DaoDataCreateAlertIntDecorator('Group id', null, autoIncrement: false),
      DaoDataCreateAlertStringDecorator(
        'Device id',
        null,
        validator: SharedPlatform.isAndroid ? MacValidator.macValidator : null,
      ),
    ];
    final saveNewItem = await DaoDataCreateAlertWidget.showCustomDialog(
      context,
      decorators,
    );
    if (saveNewItem) {
      final int? groupId =
          (decorators[0] as DaoDataCreateAlertIntDecorator).getNewValue();
      String? deviceId =
          (decorators[1] as DaoDataCreateAlertStringDecorator).getNewValue();
      if (SharedPlatform.isAndroid) {
        deviceId = deviceId?.trim().toUpperCase();
      }
      if (groupId == null) {
        if (context.mounted) {
          ToastContext().init(context);
          Toast.show('No group id set!');
        }
        return;
      }
      if (deviceId == null) {
        if (context.mounted) {
          ToastContext().init(context);
          Toast.show('No device id set!');
        }
        return;
      }
      await bloc.groups.insertGroupEntry(
        GroupEntry(deviceId: deviceId, groupId: groupId),
      );
    }
  }
}

class GroupDaoPage extends BasePage with WithBlocStateless {
  const GroupDaoPage({super.key});

  @override
  Widget buildPage(final BuildContext context) {
    final bloc = blocWithoutListen(context);

    return Scaffold(
      appBar: AppBar(title: const Text('GroupDao')),
      body: ContentContainerListView(
        children: [
          DaoTableDataWidget<Group>(
            'Groups',
            bloc.groups.select(bloc.groups.groups).watch(),
            _GroupConverter(bloc),
          ),
          DaoTableDataWidget<GroupEntry>(
            'Group entries',
            bloc.groups.select(bloc.groups.groupEntries).watch(),
            _GroupEntryConverter(bloc),
          ),
        ],
      ),
    );
  }
}
