import 'package:flutter/widgets.dart';
import 'package:lighthouse_pm/data/Database.dart';
import 'package:lighthouse_pm/data/dao/GroupDao.dart';
import 'package:lighthouse_pm/data/dao/NicknameDao.dart';
import 'package:lighthouse_pm/data/dao/SettingsDao.dart';
import 'package:lighthouse_pm/data/dao/ViveBaseStationDao.dart';
import 'package:provider/provider.dart';

class LighthousePMBloc {
  final LighthouseDatabase db;

  SettingsDao get settings => db.settingsDao;

  ViveBaseStationDao get viveBaseStation => db.viveBaseStationDao;

  NicknameDao get nicknames => db.nicknameDao;

  GroupDao get groups => db.groupDao;

  LighthousePMBloc(LighthouseDatabase db) : db = db;

  Future<List<String>> getInstalledTables() {
    return db
        .customSelect(
            'SELECT `name` FROM `sqlite_master` WHERE `type` IN (\'table\',\'view\') AND `name` NOT LIKE \'sqlite_%\' ORDER BY 1;')
        .get()
        .then((rows) {
      return rows.map((row) => row.read<String>('name')).toList()
        ..sort((a, b) => a.compareTo(b));
    });
  }

  List<String> getKnownTables() {
    return db.allTables
        .map((e) => e.actualTableName.replaceAll('"', ''))
        .toList()
          ..sort((a, b) => a.compareTo(b));
  }

  void close() {
    db.close();
  }
}

abstract class WithBlocStateless {
  LighthousePMBloc bloc(BuildContext context, {bool listen = true}) =>
      Provider.of<LighthousePMBloc>(context, listen: listen);

  LighthousePMBloc blocWithoutListen(BuildContext context) =>
      bloc(context, listen: false);

  static blocStatic(BuildContext context, {bool listen = true}) => Provider.of<LighthousePMBloc>(context, listen: listen);

}

extension WithBlocState on State {
  LighthousePMBloc get bloc =>
      Provider.of<LighthousePMBloc>(context, listen: true);

  LighthousePMBloc get blocWithoutListen =>
      Provider.of<LighthousePMBloc>(context, listen: false);
}
