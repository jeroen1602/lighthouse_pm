import 'package:flutter/material.dart';
import 'package:lighthouse_pm/bloc.dart';
import 'package:lighthouse_pm/data/Database.dart';
import 'package:lighthouse_pm/data/validators/MacValidator.dart';
import 'package:lighthouse_pm/widgets/ContentContainerWidget.dart';
import 'package:lighthouse_pm/widgets/DaoDataCreateAlertWidget.dart';
import 'package:lighthouse_pm/widgets/DaoDataWidget.dart';
import 'package:lighthouse_pm/widgets/DaoSimpleChangeStringAlertWidget.dart';
import 'package:moor/moor.dart' as moor;
import 'package:toast/toast.dart';

import '../BasePage.dart';

class _GroupConverter extends DaoTableDataConverter<Group> {
  final LighthousePMBloc bloc;

  _GroupConverter(this.bloc);

  @override
  String getDataSubtitle(Group data) {
    return data.name;
  }

  @override
  String getDataTitle(Group data) {
    return '${data.id}';
  }

  @override
  Future<void> deleteItem(Group item) {
    return bloc.groups.deleteGroup(item.id);
  }

  @override
  Future<void> openChangeDialog(BuildContext context, Group data) async {
    final newValue = await DaoSimpleChangeStringAlertWidget.showCustomDialog(
        context,
        primaryKey: '${data.id}',
        startValue: data.name);
    if (newValue == null) {
      return;
    }
    await bloc.groups.insertEmptyGroup(
        GroupsCompanion.insert(id: moor.Value(data.id), name: newValue));
  }

  @override
  Future<void> openAddNewItemDialog(BuildContext context) async {
    final List<DaoDataCreateAlertDecorator<dynamic>> decorators = [
      DaoDataCreateAlertIntDecorator('Group id', null, autoIncrement: true),
      DaoDataCreateAlertStringDecorator('Name', null),
    ];
    final saveNewItem =
        await DaoDataCreateAlertWidget.showCustomDialog(context, decorators);
    if (saveNewItem) {
      final int? id =
          (decorators[0] as DaoDataCreateAlertIntDecorator).getNewValue();
      final String? value =
          (decorators[1] as DaoDataCreateAlertStringDecorator).getNewValue();
      if (value == null) {
        Toast.show('No name set!', context);
        return;
      }
      if (id == null) {
        await bloc.groups.insertEmptyGroup(GroupsCompanion.insert(name: value));
      } else {
        await bloc.groups.insertEmptyGroup(
            GroupsCompanion.insert(id: moor.Value(id), name: value));
      }
    }
  }
}

class _GroupEntryConverter extends DaoTableDataConverter<GroupEntry> {
  final LighthousePMBloc bloc;

  _GroupEntryConverter(this.bloc);

  @override
  String getDataSubtitle(GroupEntry data) {
    return '${data.groupId}';
  }

  @override
  String getDataTitle(GroupEntry data) {
    return data.macAddress;
  }

  @override
  Future<void> deleteItem(GroupEntry item) {
    return bloc.groups.deleteGroupEntry(item.macAddress);
  }

  @override
  Future<void> openChangeDialog(BuildContext context, GroupEntry data) async {
    final newValue = await DaoSimpleChangeStringAlertWidget.showCustomDialog(
        context,
        primaryKey: data.macAddress,
        startValue: '${data.groupId}');
    if (newValue == null) {
      return;
    }
    final intValue = int.tryParse(newValue, radix: 10);
    if (intValue == null || intValue < 0) {
      Toast.show(
          'new group id must be a number and cam\'t be negative', context);
      return;
    }
    await bloc.groups.insertGroupEntry(
        GroupEntry(macAddress: data.macAddress, groupId: intValue));
  }

  @override
  Future<void> openAddNewItemDialog(BuildContext context) async {
    final List<DaoDataCreateAlertDecorator<dynamic>> decorators = [
      DaoDataCreateAlertIntDecorator('Group id', null, autoIncrement: false),
      DaoDataCreateAlertStringDecorator('Mac address', null,
          validator: MacValidator.macValidator),
    ];
    final saveNewItem =
        await DaoDataCreateAlertWidget.showCustomDialog(context, decorators);
    if (saveNewItem) {
      final int? groupId =
          (decorators[0] as DaoDataCreateAlertIntDecorator).getNewValue();
      final String? mac = (decorators[1] as DaoDataCreateAlertStringDecorator)
          .getNewValue()
          ?.trim()
          .toUpperCase();
      if (groupId == null) {
        Toast.show('No group id set!', context);
        return;
      }
      if (mac == null) {
        Toast.show('No mac set!', context);
        return;
      }
      await bloc.groups
          .insertGroupEntry(GroupEntry(macAddress: mac, groupId: groupId));
    }
  }
}

class GroupDaoPage extends BasePage with WithBlocStateless {
  @override
  Widget buildPage(BuildContext context) {
    final bloc = blocWithoutListen(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('GroupDao'),
      ),
      body: ContentContainerWidget(
        builder: (context) {
          return ListView(
            children: [
              Column(
                children: [
                  DaoTableDataWidget<Group>(
                      'Groups',
                      bloc.groups.select(bloc.groups.groups).watch(),
                      _GroupConverter(bloc)),
                  DaoTableDataWidget<GroupEntry>(
                      'Group entries',
                      bloc.groups.select(bloc.groups.groupEntries).watch(),
                      _GroupEntryConverter(bloc))
                ],
              )
            ],
          );
        },
      ),
    );
  }
}
