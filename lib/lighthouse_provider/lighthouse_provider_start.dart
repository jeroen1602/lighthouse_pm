import 'dart:async';

import 'package:bluez_back_end/bluez_back_end.dart';
import 'package:fake_back_end/fake_back_end.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_blue_plus_back_end/flutter_blue_plus_back_end.dart';
import 'package:flutter_web_bluetooth_back_end/flutter_web_bluetooth_back_end.dart';
import 'package:lighthouse_back_end/lighthouse_back_end.dart';
import 'package:lighthouse_logger/lighthouse_logger.dart';
import 'package:lighthouse_pm/bloc.dart';
import 'package:lighthouse_pm/bloc/lighthouse_v2_bloc.dart';
import 'package:lighthouse_pm/bloc/vive_base_station_bloc.dart';
import 'package:lighthouse_pm/data/helper_structures/lighthouse_providers.dart';
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

  static BehaviorSubject<List<LogRecord>> logs = BehaviorSubject.seeded(
    <LogRecord>[],
  );

  static StreamSubscription? loggerSubscription;

  static void loadLibrary() {
    if (SharedPlatform.isIOS || SharedPlatform.isAndroid) {
      LighthouseProvider.instance.addBackEnd(
        FlutterBluePlusLighthouseBackEnd.instance,
      );
    }
    if (SharedPlatform.isWeb) {
      LighthouseProvider.instance.addBackEnd(
        FlutterWebBluetoothBackEnd.instance,
      );
    }
    if (SharedPlatform.isLinux) {
      LighthouseProvider.instance.addBackEnd(BlueZBackEnd.instance);
    }

    assert(() {
      lighthouseLogger.onRecord.listen((final record) {
        debugPrint("${record.loggerName}|${record.time}: ${record.message}");
        if (record.error != null) {
          debugPrint("Error: ${record.error}");
        }
        if (record.stackTrace != null) {
          debugPrint("Trace: ${record.stackTrace.toString()}");
        }
      });

      return true;
    }());
  }

  static void setupPersistence(final LighthousePMBloc bloc) {
    ViveBaseStationDeviceProvider.instance.setPersistence(
      ViveBaseStationBloc(bloc),
    );
    LighthouseV2DeviceProvider.instance.setPersistence(LighthouseV2Bloc(bloc));
  }

  static void setupCallbacks() {
    ViveBaseStationDeviceProvider.instance
        .setRequestPairIdCallback<BuildContext>((
          final BuildContext? context,
          final pairIdHint,
        ) async {
          assert(context != null, "Context should not be null");
          assert(
            context is BuildContext,
            "context should be of the type BuildContext",
          );
          if (context == null) {
            return null;
          }
          return ViveBaseStationExtraInfoAlertWidget.showCustomDialog(
            context,
            pairIdHint,
          );
        });

    LighthouseV2DeviceProvider.instance.setCreateShortcutCallback((
      final mac,
      final name,
    ) async {
      if (SharedPlatform.isAndroid) {
        await AndroidLauncherShortcut.instance.requestShortcutLighthouse(
          mac,
          name,
        );
      }
    });
  }

  ///
  /// Start listening to certain settings to help set everything up.
  ///
  static void startBlocListening(final LighthousePMBloc bloc) {
    bloc.settings.getDebugModeEnabledStream().listen((final enabled) {
      if (enabled) {
        loggerSubscription = lighthouseLogger.onRecord.listen((final record) {
          logs.add([...logs.value, record]);
        });
      } else {
        logs.add([]);
        final subscription = loggerSubscription;
        loggerSubscription = null;
        subscription?.cancel();
      }
    });

    bloc.settings.getUseFakeBackEndStream().listen((final useFake) {
      if (useFake) {
        LighthouseProvider.instance.addBackEnd(FakeBLEBackEnd.instance);
      } else {
        LighthouseProvider.instance.removeBackEnd(FakeBLEBackEnd.instance);
      }
    });

    bloc.settings.getEnabledDeviceProvidersStream().listen((final providers) {
      _addOrRemoveProvider(providers, LighthouseV2DeviceProvider.instance);
      _addOrRemoveProvider(providers, ViveBaseStationDeviceProvider.instance);
    });
  }

  static void _addOrRemoveProvider(
    final List<LighthouseProviders> providers,
    final DeviceProvider provider,
  ) {
    final contains =
        providers.indexWhere((final element) => element.provider == provider) >=
        0;
    if (contains) {
      LighthouseProvider.instance.addProvider(provider);
    } else {
      LighthouseProvider.instance.removeProvider(provider);
    }
  }
}
