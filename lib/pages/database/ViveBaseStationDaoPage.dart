import 'package:flutter/material.dart';
import 'package:lighthouse_pm/bloc.dart';
import 'package:lighthouse_pm/data/Database.dart';
import 'package:lighthouse_pm/data/validators/MacValidator.dart';
import 'package:lighthouse_pm/platformSpecific/shared/LocalPlatform.dart';
import 'package:lighthouse_pm/widgets/ContentContainerWidget.dart';
import 'package:lighthouse_pm/widgets/DaoDataCreateAlertWidget.dart';
import 'package:lighthouse_pm/widgets/DaoDataWidget.dart';
import 'package:lighthouse_pm/widgets/DaoSimpleChangeStringAlertWidget.dart';
import 'package:toast/toast.dart';

import '../BasePage.dart';

class _ViveBaseStationIdConverter
    extends DaoTableDataConverter<ViveBaseStationId> {
  final LighthousePMBloc bloc;

  _ViveBaseStationIdConverter(this.bloc);

  @override
  String getDataSubtitle(ViveBaseStationId data) {
    return '0x${data.baseStationId.toRadixString(16).padLeft(8, '0').toUpperCase()} (${data.baseStationId})';
  }

  @override
  String getDataTitle(ViveBaseStationId data) {
    return data.deviceId;
  }

  @override
  Future<void> deleteItem(ViveBaseStationId item) {
    return bloc.viveBaseStation.deleteId(item.deviceId);
  }

  @override
  Future<void> openChangeDialog(
      BuildContext context, ViveBaseStationId data) async {
    final newValue = await DaoSimpleChangeStringAlertWidget.showCustomDialog(
        context,
        primaryKey: data.deviceId,
        startValue:
            data.baseStationId.toRadixString(16).padLeft(8, '0').toUpperCase());
    if (newValue == null) {
      return;
    }
    try {
      final numberValue = int.parse(newValue, radix: 16);
      await bloc.viveBaseStation.insertIdNoValidate(data.deviceId, numberValue);
    } on FormatException {
      Toast.show('Could not convert "$newValue" to a hex number', context);
    }
  }

  @override
  Future<void> openAddNewItemDialog(BuildContext context) async {
    final List<DaoDataCreateAlertDecorator<dynamic>> decorators = [
      DaoDataCreateAlertStringDecorator('Device id', null,
          validator:
              LocalPlatform.isAndroid ? MacValidator.macValidator : null),
      DaoDataCreateAlertStringDecorator('Base station id', null)
    ];
    final storeValue =
        await DaoDataCreateAlertWidget.showCustomDialog(context, decorators);
    if (!storeValue) {
      return;
    }

    String? deviceId =
        (decorators[0] as DaoDataCreateAlertStringDecorator).getNewValue();
    if (LocalPlatform.isAndroid) {
      deviceId = deviceId?.trim().toUpperCase();
    }
    final String? newValueString =
        (decorators[1] as DaoDataCreateAlertStringDecorator).getNewValue();
    if (deviceId == null) {
      Toast.show('No device id set!', context);
      return;
    }
    if (newValueString == null) {
      Toast.show('No base station id set!', context);
      return;
    }
    try {
      final numberValue = int.parse(newValueString, radix: 16);
      await bloc.viveBaseStation.insertIdNoValidate(deviceId, numberValue);
    } on FormatException {
      Toast.show(
          'Could not convert "$newValueString" to a hex number', context);
    }
  }
}

class ViveBaseStationDaoPage extends BasePage with WithBlocStateless {
  @override
  Widget buildPage(BuildContext context) {
    final bloc = blocWithoutListen(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('ViveBaseStationDao'),
      ),
      body: ContentContainerWidget(builder: (context) {
        return ListView(
          children: [
            Column(
              children: [
                DaoTableDataWidget<ViveBaseStationId>(
                    'ViveBaseStationIds',
                    bloc.viveBaseStation.watchViveBaseStationIds,
                    _ViveBaseStationIdConverter(bloc)),
              ],
            )
          ],
        );
      }),
    );
  }
}
