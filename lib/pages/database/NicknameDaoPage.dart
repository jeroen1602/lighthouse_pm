import 'package:flutter/material.dart';
import 'package:lighthouse_pm/bloc.dart';
import 'package:lighthouse_pm/data/Database.dart';
import 'package:lighthouse_pm/widgets/DaoDataWidget.dart';
import 'package:lighthouse_pm/widgets/DaoSimpleChangeStringAlertWidget.dart';
import 'package:moor/moor.dart' as moor;
import 'package:toast/toast.dart';

import '../BasePage.dart';

class _NicknameConverter extends DaoTableDataConverter<Nickname> {
  final LighthousePMBloc bloc;

  _NicknameConverter(this.bloc);

  @override
  String getDataSubtitle(Nickname data) {
    return data.nickname;
  }

  @override
  String getDataTitle(Nickname data) {
    return data.macAddress;
  }

  @override
  Future<void> deleteItem(Nickname item) {
    return bloc.nicknames.deleteNicknames([item.macAddress]);
  }

  @override
  Future<void> openChangeDialog(BuildContext context, Nickname data) async {
    final newValue = await DaoSimpleChangeStringAlertWidget.showCustomDialog(
        context,
        primaryKey: data.macAddress,
        startValue: data.nickname);
    if (newValue == null) {
      return;
    }
    await bloc.nicknames.insertNickname(
        Nickname(macAddress: data.macAddress, nickname: newValue));
  }

  @override
  Future<void> openAddNewItemDialog(BuildContext context) async {
    Toast.show('TODO: implement add item dialog', context);
  }
}

class _LastSeenConverter extends DaoTableDataConverter<LastSeenDevice> {
  final LighthousePMBloc bloc;

  _LastSeenConverter(this.bloc);

  @override
  String getDataSubtitle(LastSeenDevice data) {
    return data.lastSeen.toIso8601String();
  }

  @override
  String getDataTitle(LastSeenDevice data) {
    return data.macAddress;
  }

  @override
  Future<void> deleteItem(LastSeenDevice item) {
    return bloc.nicknames.deleteLastSeen(item);
  }

  @override
  Future<void> openChangeDialog(
      BuildContext context, LastSeenDevice data) async {
    final newValue = await DaoSimpleChangeStringAlertWidget.showCustomDialog(
        context,
        primaryKey: data.macAddress,
        startValue: data.lastSeen.toIso8601String());
    if (newValue == null) {
      return;
    }
    try {
      final newData = DateTime.parse(newValue);
      await bloc.nicknames.insertLastSeenDevice(LastSeenDevicesCompanion.insert(
          macAddress: data.macAddress, lastSeen: moor.Value(newData)));
    } on FormatException {
      Toast.show('That didn\'t work', context);
    }
  }

  @override
  Future<void> openAddNewItemDialog(BuildContext context) async {
    Toast.show('TODO: implement add item dialog', context);
  }

}

class NicknameDaoPage extends BasePage with WithBlocStateless {
  @override
  Widget buildPage(BuildContext context) {
    final bloc = blocWithoutListen(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('NicknameDao'),
      ),
      body: ListView(
        children: [
          Column(
            children: [
              DaoTableDataWidget<Nickname>('Nicknames',
                  bloc.nicknames.watchNicknames, _NicknameConverter(bloc)),
              DaoTableDataWidget<LastSeenDevice>('Last seen devices',
                  bloc.nicknames.watchLastSeenDevices, _LastSeenConverter(bloc))
            ],
          )
        ],
      ),
    );
  }
}
