import 'package:flutter/material.dart';
import 'package:lighthouse_pm/bloc.dart';
import 'package:lighthouse_pm/data/Database.dart';
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
    return 'HTC BS XX${(data.id & 0xFFFF).toRadixString(16).padLeft(4, '0').toUpperCase()}';
  }

  @override
  String getDataTitle(ViveBaseStationId data) {
    return '0x${data.id.toRadixString(16).padLeft(8, '0').toUpperCase()} (${data.id})';
  }

  @override
  Future<void> deleteItem(ViveBaseStationId item) {
    return bloc.viveBaseStation.deleteIdNoValidate(item.id);
  }

  @override
  Future<void> openChangeDialog(
      BuildContext context, ViveBaseStationId data) async {
    final newValue = await DaoSimpleChangeStringAlertWidget.showCustomDialog(
        context,
        primaryKey: getDataTitle(data),
        startValue: data.id.toRadixString(16).padLeft(8, '0'));
    if (newValue == null) {
      return;
    }
    try {
      final numberValue = int.parse(newValue, radix: 16);
      await bloc.viveBaseStation.insertIdNoValidate(numberValue);
      await bloc.viveBaseStation.deleteIdNoValidate(data.id);
    } on FormatException {
      Toast.show('Could not convert "$newValue" to a hex number', context);
    }
  }

  @override
  Future<void> openAddNewItemDialog(BuildContext context) async {
    final List<DaoDataCreateAlertDecorator<dynamic>> decorators = [
      DaoDataCreateAlertIntDecorator('Base station id', null,
          autoIncrement: false),
    ];
    final saveNewItem =
        await DaoDataCreateAlertWidget.showCustomDialog(context, decorators);
    if (saveNewItem) {
      final int? id =
          (decorators[0] as DaoDataCreateAlertIntDecorator).getNewValue();
      if (id == null) {
        Toast.show('No id set!', context);
        return;
      }
      await bloc.viveBaseStation.insertIdNoValidate(id);
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
