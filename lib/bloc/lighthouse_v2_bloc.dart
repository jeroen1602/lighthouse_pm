import 'package:lighthouse_pm/bloc.dart';
import 'package:lighthouse_pm/lighthouse_providers/lighthouse_v2_device_provider.dart';

class LighthouseV2Bloc implements LighthouseV2Persistence {
  LighthouseV2Bloc(this.bloc);

  final LighthousePMBloc bloc;

  @override
  Future<bool> areShortcutsEnabled() {
    return bloc.settings.getShortcutsEnabledStream().first;
  }
}
