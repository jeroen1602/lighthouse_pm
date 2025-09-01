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

class _ViveBaseStationIdConverter
    extends DaoTableDataConverter<ViveBaseStationId> {
  final LighthousePMBloc bloc;

  _ViveBaseStationIdConverter(this.bloc);

  @override
  String getDataSubtitle(final ViveBaseStationId data) {
    return '0x${data.baseStationId.toRadixString(16).padLeft(8, '0').toUpperCase()} (${data.baseStationId})';
  }

  @override
  String getDataTitle(final ViveBaseStationId data) {
    return data.deviceId;
  }

  @override
  Future<void> deleteItem(final ViveBaseStationId item) {
    return bloc.viveBaseStation.deleteId(item.deviceId);
  }

  @override
  Future<void> openChangeDialog(
    final BuildContext context,
    final ViveBaseStationId data,
  ) async {
    final newValue = await DaoSimpleChangeStringAlertWidget.showCustomDialog(
      context,
      primaryKey: data.deviceId,
      startValue: data.baseStationId
          .toRadixString(16)
          .padLeft(8, '0')
          .toUpperCase(),
    );
    if (newValue == null) {
      return;
    }
    try {
      final numberValue = int.parse(newValue, radix: 16);
      await bloc.viveBaseStation.insertIdNoValidate(data.deviceId, numberValue);
    } on FormatException {
      if (context.mounted) {
        ToastContext().init(context);
        Toast.show('Could not convert "$newValue" to a hex number');
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
      DaoDataCreateAlertStringDecorator('Base station id', null),
    ];
    final storeValue = await DaoDataCreateAlertWidget.showCustomDialog(
      context,
      decorators,
    );
    if (!storeValue) {
      return;
    }

    String? deviceId = (decorators[0] as DaoDataCreateAlertStringDecorator)
        .getNewValue();
    if (SharedPlatform.isAndroid) {
      deviceId = deviceId?.trim().toUpperCase();
    }
    final String? newValueString =
        (decorators[1] as DaoDataCreateAlertStringDecorator).getNewValue();
    if (deviceId == null) {
      if (context.mounted) {
        ToastContext().init(context);
        Toast.show('No device id set!');
      }
      return;
    }
    if (newValueString == null) {
      if (context.mounted) {
        ToastContext().init(context);
        Toast.show('No base station id set!');
      }
      return;
    }
    try {
      final numberValue = int.parse(newValueString, radix: 16);
      await bloc.viveBaseStation.insertIdNoValidate(deviceId, numberValue);
    } on FormatException {
      if (context.mounted) {
        ToastContext().init(context);
        Toast.show('Could not convert "$newValueString" to a hex number');
      }
    }
  }
}

class ViveBaseStationDaoPage extends BasePage with WithBlocStateless {
  const ViveBaseStationDaoPage({super.key});

  @override
  Widget buildPage(final BuildContext context) {
    final bloc = blocWithoutListen(context);

    return Scaffold(
      appBar: AppBar(title: const Text('ViveBaseStationDao')),
      body: ContentContainerListView(
        children: [
          DaoTableDataWidget<ViveBaseStationId>(
            'ViveBaseStationIds',
            bloc.viveBaseStation.getViveBaseStationIdsAsStream(),
            _ViveBaseStationIdConverter(bloc),
          ),
        ],
      ),
    );
  }
}
