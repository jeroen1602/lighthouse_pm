import 'package:flutter/widgets.dart';
import 'package:lighthouse_pm/data/database.dart';
import 'package:lighthouse_pm/data/dao/group_dao.dart';
import 'package:lighthouse_pm/data/dao/nickname_dao.dart';
import 'package:lighthouse_pm/data/dao/settings_dao.dart';
import 'package:lighthouse_pm/data/dao/vive_base_station_dao.dart';
import 'package:provider/provider.dart';

class LighthousePMBloc {
  final LighthouseDatabase db;

  SettingsDao get settings => db.settingsDao;

  ViveBaseStationDao get viveBaseStation => db.viveBaseStationDao;

  NicknameDao get nicknames => db.nicknameDao;

  GroupDao get groups => db.groupDao;

  LighthousePMBloc(this.db);

  Future<List<String>> getInstalledTables() {
    return db
        .customSelect(
            'SELECT `name` FROM `sqlite_master` WHERE `type` IN (\'table\',\'view\') AND `name` NOT LIKE \'sqlite_%\' ORDER BY 1;')
        .get()
        .then((final rows) {
      return rows.map((final row) => row.read<String>('name')).toList()
        ..sort((final a, final b) => a.compareTo(b));
    });
  }

  List<String> getKnownTables() {
    return db.allTables
        .map((final e) => e.actualTableName.replaceAll('"', ''))
        .toList()
      ..sort((final a, final b) => a.compareTo(b));
  }

  void close() {
    db.close();
  }
}

abstract class WithBlocStateless {
  LighthousePMBloc bloc(final BuildContext context,
          {final bool listen = true}) =>
      Provider.of<LighthousePMBloc>(context, listen: listen);

  LighthousePMBloc blocWithoutListen(final BuildContext context) =>
      bloc(context, listen: false);

  static blocStatic(final BuildContext context, {final bool listen = true}) =>
      Provider.of<LighthousePMBloc>(context, listen: listen);
}

extension WithBlocState on State {
  LighthousePMBloc get bloc =>
      Provider.of<LighthousePMBloc>(context, listen: true);

  LighthousePMBloc get blocWithoutListen =>
      Provider.of<LighthousePMBloc>(context, listen: false);
}
