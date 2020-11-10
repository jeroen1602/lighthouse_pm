import 'package:lighthouse_pm/data/Database.dart';
import 'package:lighthouse_pm/data/bloc/NicknameBloc.dart';
import 'package:lighthouse_pm/data/bloc/ViveBaseStationBloc.dart';

import 'data/bloc/SettingsBloc.dart';

class LighthousePMBloc {
  final LighthouseDatabase db;
  final SettingsBloc settings;
  final ViveBaseStationBloc viveBaseStation;
  final NicknameBloc nicknames;

  LighthousePMBloc(LighthouseDatabase db)
      : db = db,
        settings = SettingsBloc(db),
        viveBaseStation = ViveBaseStationBloc(db),
        nicknames = NicknameBloc(db);

  void close() {
    db.close();
  }
}


