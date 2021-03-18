import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:lighthouse_pm/data/local/MainPageSettings.dart';
import 'package:lighthouse_pm/lighthouseProvider/LighthouseDevice.dart';
import 'package:lighthouse_pm/lighthouseProvider/LighthouseProvider.dart';
import 'package:lighthouse_pm/lighthouseProvider/ble/DeviceIdentifier.dart';
import 'package:lighthouse_pm/widgets/CloseCurrentRouteMixin.dart';
import 'package:lighthouse_pm/widgets/ScanningMixin.dart';
import 'package:lighthouse_pm/widgets/WaterfallWidget.dart';
import 'package:rxdart/streams.dart';

import '../../../data/helperStructures/WithTimeout.dart';

class GetDeviceStream extends WaterfallStreamWidget<LighthouseDevice>
    with ScanningMixin, CloseCurrentRouteMixin {
  final String macAddress;
  final int settingsIndex;

  GetDeviceStream(this.macAddress, this.settingsIndex,
      {required List<Object?> upStream,
      required List<DownStreamBuilder> downStreamBuilders})
      : super(upStream: upStream, downStreamBuilders: downStreamBuilders);

  Stream<WithTimeout<LighthouseDevice?>> listenForDevice(Duration timeout) {
    LHDeviceIdentifier identifier = LHDeviceIdentifier(macAddress);

    final timeoutStream = Stream.fromFutures(
        [Future.value(false), Future.delayed(timeout).then((value) => true)]);

    final deviceStream =
        LighthouseProvider.instance.lighthouseDevices.map((devices) {
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
        .map((event) {
      if (event[0] != null) {
        return WithTimeout(event[0] as LighthouseDevice, false);
      } else {
        return WithTimeout(null, event[1] as bool);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
    final settings = upStream[settingsIndex] as MainPageSettings;
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      startScanWithCheck(Duration(seconds: settings.scanDuration),
          failMessage:
              "Could not start scan because the permission has not been granted at shortcut handler.");
    });
    return StreamBuilder<WithTimeout<LighthouseDevice?>>(
        stream: listenForDevice(Duration(seconds: settings.scanDuration + 2)),
        initialData: WithTimeout.empty(),
        builder: (BuildContext context,
            AsyncSnapshot<WithTimeout<LighthouseDevice?>> snapshot) {
          if (snapshot.requireData.timeoutExpired) {
            stopScan().then((_) {
              closeCurrentRouteWithWait(context);
            });
            return Text('Scan timeout reached!');
          }
          final data = snapshot.requireData.data;
          if (data != null) {
            return getNextStreamDown(context, data);
          } else {
            return Text('Searching!');
          }
        });
  }

  static DownStreamBuilder createBuilder(String macAddress, int settingsIndex) {
    if (settingsIndex < 0) {
      throw Exception('Settings index should be at least higher than 0');
    }
    return (context, upStream, downStream) {
      return GetDeviceStream(
        macAddress,
        settingsIndex,
        upStream: upStream,
        downStreamBuilders: downStream.cast<DownStreamBuilder>(),
      );
    };
  }
}
