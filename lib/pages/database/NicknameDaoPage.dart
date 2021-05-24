import 'package:flutter/material.dart';
import 'package:lighthouse_pm/bloc.dart';
import 'package:lighthouse_pm/data/Database.dart';
import 'package:lighthouse_pm/data/validators/MacValidator.dart';
import 'package:lighthouse_pm/platformSpecific/shared/LocalPlatform.dart';
import 'package:lighthouse_pm/widgets/ContentContainerWidget.dart';
import 'package:lighthouse_pm/widgets/DaoDataCreateAlertWidget.dart';
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
    return data.deviceId;
  }

  @override
  Future<void> deleteItem(Nickname item) {
    return bloc.nicknames.deleteNicknames([item.deviceId]);
  }

  @override
  Future<void> openChangeDialog(BuildContext context, Nickname data) async {
    final newValue = await DaoSimpleChangeStringAlertWidget.showCustomDialog(
        context,
        primaryKey: data.deviceId,
        startValue: data.nickname);
    if (newValue == null) {
      return;
    }
    await bloc.nicknames
        .insertNickname(Nickname(deviceId: data.deviceId, nickname: newValue));
  }

  @override
  Future<void> openAddNewItemDialog(BuildContext context) async {
    final List<DaoDataCreateAlertDecorator<dynamic>> decorators = [
      DaoDataCreateAlertStringDecorator('Device Id', null,
          validator:
              LocalPlatform.isAndroid ? MacValidator.macValidator : null),
      DaoDataCreateAlertStringDecorator('Nickname', null),
    ];
    final saveNewItem =
        await DaoDataCreateAlertWidget.showCustomDialog(context, decorators);
    if (saveNewItem) {
      final String? deviceId =
          (decorators[0] as DaoDataCreateAlertStringDecorator)
              .getNewValue()
              ?.trim()
              .toUpperCase();
      final String? value =
          (decorators[1] as DaoDataCreateAlertStringDecorator).getNewValue();
      if (deviceId == null) {
        Toast.show('No mac set!', context);
        return;
      }
      if (value == null) {
        Toast.show('No nickname set!', context);
        return;
      }
      await bloc.nicknames
          .insertNickname(Nickname(deviceId: deviceId, nickname: value));
    }
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
    final List<DaoDataCreateAlertDecorator<dynamic>> decorators = [
      DaoDataCreateAlertStringDecorator('Mac address', null,
          validator: MacValidator.macValidator),
      // TODO: use date picker
      DaoDataCreateAlertStringDecorator(
          'Last seen', DateTime.now().toIso8601String()),
    ];
    final saveNewItem =
        await DaoDataCreateAlertWidget.showCustomDialog(context, decorators);
    if (saveNewItem) {
      final String? mac = (decorators[0] as DaoDataCreateAlertStringDecorator)
          .getNewValue()
          ?.trim()
          .toUpperCase();
      final String? value =
          (decorators[1] as DaoDataCreateAlertStringDecorator).getNewValue();
      if (mac == null) {
        Toast.show('No mac set!', context);
        return;
      }
      DateTime? date;
      if (value != null && value.trim() != '') {
        date = DateTime.tryParse(value);
      }
      if (date == null) {
        date = DateTime.now();
      }
      await bloc.nicknames.insertLastSeenDevice(LastSeenDevicesCompanion.insert(
          macAddress: mac, lastSeen: moor.Value(date)));
    }
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
      body: ContentContainerWidget(builder: (context) {
        return ListView(
          children: [
            Column(
              children: [
                DaoTableDataWidget<Nickname>('Nicknames',
                    bloc.nicknames.watchNicknames, _NicknameConverter(bloc)),
                DaoTableDataWidget<LastSeenDevice>(
                    'Last seen devices',
                    bloc.nicknames.watchLastSeenDevices,
                    _LastSeenConverter(bloc))
              ],
            )
          ],
        );
      }),
    );
  }
}
