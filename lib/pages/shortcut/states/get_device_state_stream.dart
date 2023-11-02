import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:lighthouse_pm/data/helper_structures/with_timeout.dart';
import 'package:lighthouse_pm/data/local/main_page_settings.dart';
import 'package:lighthouse_provider/lighthouse_provider.dart';
import 'package:lighthouse_providers/lighthouse_v2_device_provider.dart';
import 'package:lighthouse_pm/widgets/close_current_route_mixin.dart';
import 'package:lighthouse_pm/widgets/waterfall_widget.dart';
import 'package:rxdart/rxdart.dart';

class GetDeviceStateStream extends WaterfallStreamWidget<LighthousePowerState>
    with CloseCurrentRouteMixin {
  final int settingsIndex;

  GetDeviceStateStream(this.settingsIndex,
      {super.key,
      required super.upStream,
      super.downStreamBuilders});

  Stream<WithTimeout<LighthousePowerState>> getDeviceState(
      final StatefulLighthouseDevice device, final Duration timeout) {
    final timeoutStream = Stream.fromFutures([
      Future.value(false),
      Future.delayed(timeout).then(((final val) => true))
    ]);

    final stateStream = device.powerStateEnum;

    return CombineLatestStream.list<dynamic>([stateStream, timeoutStream])
        .map((final event) {
      if (event[0] != LighthousePowerState.unknown) {
        return WithTimeout(event[0] as LighthousePowerState, false);
      } else {
        return WithTimeout(LighthousePowerState.unknown, event[1] as bool);
      }
    });
  }

  @override
  Widget build(final BuildContext context) {
    if (upStream.last is! LighthouseDevice) {
      if (kReleaseMode) {
        closeCurrentRouteWithWait(context);
        return const Text('Could not find device');
      } else {
        throw Exception(
            'Illegal state, the last item in upstream isn\'t a lighthouse device!');
      }
    }
    if (settingsIndex >= upStream.length || settingsIndex < 0) {
      if (kReleaseMode) {
        closeCurrentRouteWithWait(context);
        return const Text('Could not find device');
      } else {
        throw Exception(
            'Illegal state, the settingsIndex is outside of the upStream items list');
      }
    }
    if (upStream[settingsIndex] is! MainPageSettings) {
      if (kReleaseMode) {
        closeCurrentRouteWithWait(context);
        return const Text('Could not find device');
      } else {
        throw Exception(
            'Illegal state, the settingsIndex isn\'t an instance of MainPageSettings. upStream[$settingsIndex]');
      }
    }
    final device = upStream.last as StatefulLighthouseDevice;
    final settings = upStream[settingsIndex] as MainPageSettings;
    return StreamBuilder<WithTimeout<LighthousePowerState>>(
        stream: getDeviceState(
            device, Duration(seconds: settings.scanDuration + 2)),
        initialData: WithTimeout(LighthousePowerState.unknown, false),
        builder: (final context, final powerStateSnapshot) {
          final powerState = powerStateSnapshot.requireData;
          if (powerState.timeoutExpired) {
            closeCurrentRouteWithWait(context);
            return const Text('Power state timeout reached!');
          }
          switch (powerState.data) {
            case LighthousePowerState.unknown:
              return const Text('Found Device! Reading current state!');
            case LighthousePowerState.on:
              if (device.hasStandbyExtension) {
                changeState(device, settings.sleepState, context);
              } else {
                debugPrint(
                    'The device doesn\'t support STANDBY so SLEEP will always be used.');
                changeState(device, LighthousePowerState.sleep, context);
              }
              return const Text('Device is on! turning it off!');
            case LighthousePowerState.standby:
            case LighthousePowerState.sleep:
              changeState(device, LighthousePowerState.on, context);
              return const Text('Device is off! turning it on!');
            default:
              return const Text('That wasn\'t supposed to happen');
          }
        });
  }

  Future changeState(final LighthouseDevice device,
      final LighthousePowerState newState, final BuildContext context) async {
    await device.changeState(newState);
    await device.disconnect();
    // ignore: use_build_context_synchronously
    await closeCurrentRouteWithWait(context);
  }

  static DownStreamBuilder createBuilder(final int settingsIndex) {
    if (settingsIndex < 0) {
      throw Exception('Settings index should be at least higher than 0');
    }
    return (final context, final upStream, final downStream) {
      return GetDeviceStateStream(
        settingsIndex,
        upStream: upStream,
        downStreamBuilders: downStream.cast<DownStreamBuilder>(),
      );
    };
  }
}
