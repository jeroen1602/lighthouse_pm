import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:lighthouse_pm/data/helper_structures/with_timeout.dart';
import 'package:lighthouse_pm/data/local/main_page_settings.dart';
import 'package:lighthouse_provider/lighthouse_provider.dart';
import 'package:lighthouse_pm/widgets/close_current_route_mixin.dart';
import 'package:lighthouse_pm/widgets/scanning_mixin.dart';
import 'package:lighthouse_pm/widgets/waterfall_widget.dart';
import 'package:rxdart/streams.dart';

class GetDeviceStream extends WaterfallStreamWidget<LighthouseDevice>
    with ScanningMixin, CloseCurrentRouteMixin {
  final String deviceId;
  final int settingsIndex;

  GetDeviceStream(this.deviceId, this.settingsIndex,
      {required final List<Object?> upStream,
      required final List<DownStreamBuilder> downStreamBuilders,
      final Key? key})
      : super(
            key: key,
            upStream: upStream,
            downStreamBuilders: downStreamBuilders);

  Stream<WithTimeout<LighthouseDevice?>> listenForDevice(
      final Duration timeout) {
    final LHDeviceIdentifier identifier = LHDeviceIdentifier(deviceId);

    final timeoutStream = Stream.fromFutures([
      Future.value(false),
      Future.delayed(timeout).then((final value) => true)
    ]);

    final deviceStream =
        LighthouseProvider.instance.lighthouseDevices.map((final devices) {
      LighthouseDevice? foundDevice;
      for (final device in devices) {
        if (device.deviceIdentifier == identifier) {
          foundDevice = device;
        } else {
          device.disconnect();
        }
      }
      return foundDevice;
    });

    return CombineLatestStream.list<dynamic>([deviceStream, timeoutStream])
        .map((final event) {
      if (event[0] != null) {
        return WithTimeout(event[0] as LighthouseDevice, false);
      } else {
        return WithTimeout(null, event[1] as bool);
      }
    });
  }

  @override
  Widget build(final BuildContext context) {
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
    final settings = upStream[settingsIndex] as MainPageSettings;
    WidgetsBinding.instance?.addPostFrameCallback((final timeStamp) {
      startScanWithCheck(Duration(seconds: settings.scanDuration),
          failMessage:
              "Could not start scan because the permission has not been granted at shortcut handler.");
    });
    return StreamBuilder<WithTimeout<LighthouseDevice?>>(
        stream: listenForDevice(Duration(seconds: settings.scanDuration + 2)),
        initialData: WithTimeout.empty(),
        builder: (final BuildContext context,
            final AsyncSnapshot<WithTimeout<LighthouseDevice?>> snapshot) {
          if (snapshot.requireData.timeoutExpired) {
            stopScan().then((final _) {
              closeCurrentRouteWithWait(context);
            });
            return const Text('Scan timeout reached!');
          }
          final data = snapshot.requireData.data;
          if (data != null) {
            return getNextStreamDown(context, data);
          } else {
            return const Text('Searching!');
          }
        });
  }

  static DownStreamBuilder createBuilder(
      final String deviceId, final int settingsIndex) {
    if (settingsIndex < 0) {
      throw Exception('Settings index should be at least higher than 0');
    }
    return (final context, final upStream, final downStream) {
      return GetDeviceStream(
        deviceId,
        settingsIndex,
        upStream: upStream,
        downStreamBuilders: downStream.cast<DownStreamBuilder>(),
      );
    };
  }
}
