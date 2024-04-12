import 'package:lighthouse_pm/bloc.dart';
import 'package:rxdart/rxdart.dart';

class AppRouteSettings {
  const AppRouteSettings(final bool? debugEnabled)
      : debugEnabled = debugEnabled ?? false;

  const AppRouteSettings.withDefaults() : this(null);

  final bool debugEnabled;

  static Stream<AppRouteSettings> getStream(final LighthousePMBloc bloc) {
    return MergeStream(
            [Stream.value(false), bloc.settings.getDebugModeEnabledStream()])
        .map((final enabled) {
      return AppRouteSettings(enabled);
    });
  }
}
