import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:lighthouse_pm/data/helperStructures/WithTimeout.dart';
import 'package:lighthouse_pm/data/local/MainPageSettings.dart';
import 'package:lighthouse_pm/lighthouseProvider/LighthouseDevice.dart';
import 'package:lighthouse_pm/lighthouseProvider/LighthousePowerState.dart';
import 'package:lighthouse_pm/lighthouseProvider/deviceExtensions/StandbyExtension.dart';
import 'package:lighthouse_pm/widgets/CloseCurrentRouteMixin.dart';
import 'package:lighthouse_pm/widgets/WaterfallWidget.dart';
import 'package:rxdart/rxdart.dart';

class GetDeviceStateStream extends WaterfallStreamWidget<LighthousePowerState>
    with CloseCurrentRouteMixin {
  final int settingsIndex;

  GetDeviceStateStream(this.settingsIndex,
      {Key? key,
      required List<Object?> upStream,
      List<DownStreamBuilder> downStreamBuilders = const []})
      : super(
            key: key,
            upStream: upStream,
            downStreamBuilders: downStreamBuilders);

  Stream<WithTimeout<LighthousePowerState>> getDeviceState(
      LighthouseDevice device, Duration timeout) {
    final timeoutStream = Stream.fromFutures(
        [Future.value(false), Future.delayed(timeout).then(((val) => true))]);

    final stateStream = device.powerStateEnum;

    return CombineLatestStream.list<dynamic>([stateStream, timeoutStream])
        .map((event) {
      if (event[0] != LighthousePowerState.UNKNOWN) {
        return WithTimeout(event[0] as LighthousePowerState, false);
      } else {
        return WithTimeout(LighthousePowerState.UNKNOWN, event[1] as bool);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!(upStream.last is LighthouseDevice)) {
      if (kReleaseMode) {
        closeCurrentRouteWithWait(context);
        return Text('Could not find device');
      } else {
        throw Exception(
            'Illegal state, the last item in upstream isn\'t a lighthouse device!');
      }
    }
    if (settingsIndex >= upStream.length || settingsIndex < 0) {
      if (kReleaseMode) {
        closeCurrentRouteWithWait(context);
        return Text('Could not find device');
      } else {
        throw Exception(
            'Illegal state, the settingsIndex is outside of the upStream items list');
      }
    }
    if (!(upStream[settingsIndex] is MainPageSettings)) {
      if (kReleaseMode) {
        closeCurrentRouteWithWait(context);
        return Text('Could not find device');
      } else {
        throw Exception(
            'Illegal state, the settingsIndex isn\'t an instance of MainPageSettings. upStream[$settingsIndex]');
      }
    }
    final device = upStream.last as LighthouseDevice;
    final settings = upStream[settingsIndex] as MainPageSettings;
    return StreamBuilder<WithTimeout<LighthousePowerState>>(
        stream: getDeviceState(
            device, Duration(seconds: settings.scanDuration + 2)),
        initialData: WithTimeout(LighthousePowerState.UNKNOWN, false),
        builder: (context, powerStateSnapshot) {
          final powerState = powerStateSnapshot.requireData;
          if (powerState.timeoutExpired) {
            closeCurrentRouteWithWait(context);
            return Text('Power state timeout reached!');
          }
          switch (powerState.data) {
            case LighthousePowerState.UNKNOWN:
              return Text('Found Device! Reading current state!');
            case LighthousePowerState.ON:
              if (device.hasStandbyExtension) {
                changeState(device, settings.sleepState, context);
              } else {
                debugPrint(
                    'The device doesn\'t support STANDBY so SLEEP will always be used.');
                changeState(device, LighthousePowerState.SLEEP, context);
              }
              return Text('Device is on! turning it off!');
            case LighthousePowerState.STANDBY:
            case LighthousePowerState.SLEEP:
              changeState(device, LighthousePowerState.ON, context);
              return Text('Device is off! turning it on!');
            default:
              return Text('That wasn\'t supposed to happen');
          }
        });
  }

  Future changeState(LighthouseDevice device, LighthousePowerState newState,
      BuildContext context) async {
    await device.changeState(newState);
    await device.disconnect();
    await closeCurrentRouteWithWait(context);
  }

  static DownStreamBuilder createBuilder(int settingsIndex) {
    if (settingsIndex < 0) {
      throw Exception('Settings index should be at least higher than 0');
    }
    return (context, upStream, downStream) {
      return GetDeviceStateStream(
        settingsIndex,
        upStream: upStream,
        downStreamBuilders: downStream.cast<DownStreamBuilder>(),
      );
    };
  }
}
