import 'package:bluez_back_end/bluez_back_end.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_blue_plus_back_end/flutter_blue_plus_back_end.dart';
import 'package:flutter_web_bluetooth_back_end/flutter_web_bluetooth_back_end.dart';
import 'package:lighthouse_logger/lighthouse_logger.dart';
import 'package:lighthouse_pm/bloc.dart';
import 'package:lighthouse_pm/bloc/lighthouse_v2_bloc.dart';
import 'package:lighthouse_pm/bloc/vive_base_station_bloc.dart';
import 'package:lighthouse_pm/lighthouse_provider/widgets/vive_base_station_extra_info_alert_widget.dart';
import 'package:lighthouse_pm/platform_specific/mobile/android/android_launcher_shortcut/android_launcher_shortcut.dart';
import 'package:lighthouse_provider/lighthouse_provider.dart';
import 'package:lighthouse_providers/lighthouse_v2_device_provider.dart';
import 'package:lighthouse_providers/vive_base_station_device_provider.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_platform/shared_platform.dart';

class LighthouseProviderStart {
  LighthouseProviderStart._();

  static BehaviorSubject<List<LogRecord>>? logs;

  static void loadLibrary() {
    if (SharedPlatform.isIOS || SharedPlatform.isAndroid) {
      LighthouseProvider.instance
          .addBackEnd(FlutterBluePlusLighthouseBackEnd.instance);
    }
    if (SharedPlatform.isWeb) {
      // LighthouseProvider.instance
      //     .addBackEnd(FlutterWebBluetoothBackEnd.instance);
    }
    if (SharedPlatform.isLinux) {
      // LighthouseProvider.instance.addBackEnd(BlueZBackEnd.instance);
    }

    assert(() {

      logs = BehaviorSubject.seeded(<LogRecord>[]);

      lighthouseLogger.onRecord.listen((final record) {
        debugPrint("${record.loggerName}|${record.time}: ${record.message}");
        if (record.error != null) {
          debugPrint("Error: ${record.error}");
        }
        if (record.stackTrace != null) {
          debugPrint("Trace: ${record.stackTrace.toString()}");
        }

        logs!.add([
          ...logs!.value,
          record
        ]);
      });
      // Add this back if you need to test for devices you don't own.
      // you'll also need to
      // import 'package:lighthouse_pm/lighthouse_back_ends/fake/fake_back_end.dart';

      // LighthouseProvider.instance.addBackEnd(FakeBLEBackEnd.instance);
      return true;
    }());

    LighthouseProvider.instance
        .addProvider(LighthouseV2DeviceProvider.instance);
    // LighthouseProvider.instance
    //     .addProvider(ViveBaseStationDeviceProvider.instance);
  }

  static void setupPersistence(final LighthousePMBloc bloc) {
    // ViveBaseStationDeviceProvider.instance
    //     .setPersistence(ViveBaseStationBloc(bloc));
    LighthouseV2DeviceProvider.instance.setPersistence(LighthouseV2Bloc(bloc));
  }

  static void setupCallbacks() {
    /*ViveBaseStationDeviceProvider.instance
        .setRequestPairIdCallback<BuildContext>(
            (final BuildContext? context, final pairIdHint) async {
      assert(context != null, "Context should not be null");
      assert(context is BuildContext,
          "context should be of the type BuildContext");
      if (context == null) {
        return null;
      }
      return ViveBaseStationExtraInfoAlertWidget.showCustomDialog(
          context, pairIdHint);
    });*/

    LighthouseV2DeviceProvider.instance
        .setCreateShortcutCallback((final mac, final name) async {
      if (SharedPlatform.isAndroid) {
        await AndroidLauncherShortcut.instance
            .requestShortcutLighthouse(mac, name);
      }
    });
  }
}
