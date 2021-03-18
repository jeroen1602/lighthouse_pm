import 'package:flutter/widgets.dart';
import 'package:lighthouse_pm/data/Database.dart';
import 'package:lighthouse_pm/data/bloc/NicknameBloc.dart';
import 'package:lighthouse_pm/data/bloc/ViveBaseStationBloc.dart';
import 'package:provider/provider.dart';

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

