import 'package:flutter/widgets.dart';
import 'package:lighthouse_pm/data/Database.dart';
import 'package:lighthouse_pm/data/dao/NicknameDao.dart';
import 'package:lighthouse_pm/data/dao/SettingsDao.dart';
import 'package:lighthouse_pm/data/dao/ViveBaseStationDao.dart';
import 'package:provider/provider.dart';

class LighthousePMBloc {
  final LighthouseDatabase db;
  SettingsDao get settings => db.settingsDao;
  ViveBaseStationDao get viveBaseStation => db.viveBaseStationDao;
  NicknameDao get nicknames => db.nicknameDao;

  LighthousePMBloc(LighthouseDatabase db)
      : db = db;

  void close() {
    db.close();
  }
}

abstract class WithBlocStateless {
  LighthousePMBloc bloc(BuildContext context, {bool listen = true}) =>
      Provider.of<LighthousePMBloc>(context, listen: listen);

  LighthousePMBloc blocWithoutListen(BuildContext context) =>
      bloc(context, listen: false);
}

extension WithBlocState on State {
  LighthousePMBloc get bloc =>
      Provider.of<LighthousePMBloc>(context, listen: true);

  LighthousePMBloc get blocWithoutListen =>
      Provider.of<LighthousePMBloc>(context, listen: false);
}
