import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:lighthouse_pm/data/helper_structures/with_timeout.dart';
import 'package:lighthouse_pm/data/local/main_page_settings.dart';
import 'package:lighthouse_pm/lighthouse_provider/lighthouse_provider.dart';
import 'package:lighthouse_pm/lighthouse_providers/lighthouse_v2_device_provider.dart';
import 'package:lighthouse_pm/widgets/close_current_route_mixin.dart';
import 'package:lighthouse_pm/widgets/waterfall_widget.dart';
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
      if (event[0] != LighthousePowerState.unknown) {
        return WithTimeout(event[0] as LighthousePowerState, false);
      } else {
        return WithTimeout(LighthousePowerState.unknown, event[1] as bool);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (upStream.last is! LighthouseDevice) {
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
    if (upStream[settingsIndex] is! MainPageSettings) {
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
        initialData: WithTimeout(LighthousePowerState.unknown, false),
        builder: (context, powerStateSnapshot) {
          final powerState = powerStateSnapshot.requireData;
          if (powerState.timeoutExpired) {
            closeCurrentRouteWithWait(context);
            return Text('Power state timeout reached!');
          }
          switch (powerState.data) {
            case LighthousePowerState.unknown:
              return Text('Found Device! Reading current state!');
            case LighthousePowerState.on:
              if (device.hasStandbyExtension) {
                changeState(device, settings.sleepState, context);
              } else {
                debugPrint(
                    'The device doesn\'t support STANDBY so SLEEP will always be used.');
                changeState(device, LighthousePowerState.sleep, context);
              }
              return Text('Device is on! turning it off!');
            case LighthousePowerState.standby:
            case LighthousePowerState.sleep:
              changeState(device, LighthousePowerState.on, context);
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
