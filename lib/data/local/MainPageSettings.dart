import 'package:lighthouse_pm/bloc.dart';
import 'package:lighthouse_pm/lighthouseProvider/LighthousePowerState.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

class MainPageSettings {
  const MainPageSettings(this.sleepState);

  final LighthousePowerState sleepState;

  static const DEFAULT_MAIN_PAGE_SETTINGS = MainPageSettings(LighthousePowerState.SLEEP);
  
  static Stream<MainPageSettings> mainPageSettingsStream(LighthousePMBloc bloc) {
    LighthousePowerState sleepState = DEFAULT_MAIN_PAGE_SETTINGS.sleepState;
    return MergeStream<Tuple2<int, dynamic>>([
      bloc.settings
          .getSleepStateAsStream()
          .map((state) => Tuple2(SettingsBloc.DEFAULT_SLEEP_STATE_ID, state))
    ]).map((event) {
      switch (event.item1) {
        case SettingsBloc.DEFAULT_SLEEP_STATE_ID:
          if (event.item2 != null) {
            sleepState = event.item2 as LighthousePowerState;
          }
      }
      return MainPageSettings(sleepState);
    });
  }
}
