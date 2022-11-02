import 'package:bluez_back_end/bluez_back_end.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_back_end/flutter_blue_back_end.dart';
import 'package:flutter_web_bluetooth_back_end/flutter_web_bluetooth_back_end.dart';
import 'package:lighthouse_logger/lighthouse_logger.dart';
import 'package:lighthouse_pm/bloc/lighthouse_v2_bloc.dart';
import 'package:lighthouse_pm/bloc/vive_base_station_bloc.dart';
import 'package:lighthouse_pm/data/database.dart';
import 'package:lighthouse_pm/data/local/app_style.dart';
import 'package:lighthouse_pm/data/local/theme_data_and_app_style_stream.dart';
import 'package:lighthouse_pm/lighthouse_provider/widgets/vive_base_station_extra_info_alert_widget.dart';
import 'package:lighthouse_pm/pages/base_page.dart';
import 'package:lighthouse_pm/pages/database_test_page.dart';
import 'package:lighthouse_pm/pages/help_page.dart';
import 'package:lighthouse_pm/pages/main_page.dart';
import 'package:lighthouse_pm/pages/not_found_page.dart';
import 'package:lighthouse_pm/pages/settings_page.dart';
import 'package:lighthouse_pm/pages/shortcut_handler_page.dart';
import 'package:lighthouse_pm/pages/simple_base_page.dart';
import 'package:lighthouse_pm/pages/troubleshooting_page.dart';
import 'package:lighthouse_pm/platform_specific/mobile/android/android_launcher_shortcut/android_launcher_shortcut.dart';
import 'package:lighthouse_pm/platform_specific/mobile/in_app_purchases.dart';
import 'package:lighthouse_pm/platform_specific/shared/intl.dart';
import 'package:lighthouse_provider/lighthouse_provider.dart';
import 'package:lighthouse_providers/lighthouse_v2_device_provider.dart';
import 'package:lighthouse_providers/vive_base_station_device_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_platform/shared_platform.dart';

import 'bloc.dart';
import 'build_options.dart';
import 'color_schemes.dart';
import 'pages/material_test_page.dart';

void main() {
  loadIntlStrings();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context) {
    return Provider<LighthousePMBloc>(
      create: (final _) => _initializeDataBase(),
      dispose: (final _, final bloc) => bloc.close(),
      child: const LighthousePMApp(),
    );
  }

  LighthousePMBloc _initializeDataBase() {
    final db = constructDb();
    final mainBloc = LighthousePMBloc(db);

    if (SharedPlatform.isIOS || SharedPlatform.isAndroid) {
      LighthouseProvider.instance
          .addBackEnd(FlutterBlueLighthouseBackEnd.instance);
    }
    if (SharedPlatform.isWeb) {
      LighthouseProvider.instance
          .addBackEnd(FlutterWebBluetoothBackEnd.instance);
    }
    if (SharedPlatform.isLinux) {
      LighthouseProvider.instance.addBackEnd(BlueZBackEnd.instance);
    }
    if (!kReleaseMode) {
      lighthouseLogger.onRecord.listen((final record) {
        debugPrint("${record.loggerName}|${record.time}: ${record.message}");
        if (record.error != null) {
          debugPrint("Error: ${record.error}");
        }
        if (record.stackTrace != null) {
          debugPrint("Trace: ${record.stackTrace.toString()}");
        }
      });
      // Add this back if you need to test for devices you don't own.
      // you'll also need to
      // import 'package:lighthouse_pm/lighthouse_back_ends/fake/fake_back_end.dart';

      // LighthouseProvider.instance.addBackEnd(FakeBLEBackEnd.instance);
    }

    LighthouseProvider.instance
        .addProvider(LighthouseV2DeviceProvider.instance);

    ViveBaseStationDeviceProvider.instance
        .setPersistence(ViveBaseStationBloc(mainBloc));
    ViveBaseStationDeviceProvider.instance
        .setRequestPairIdCallback<BuildContext>(
            (final BuildContext? context, final pairIdHint) async {
      assert(context != null);
      if (context == null) {
        return null;
      }
      return ViveBaseStationExtraInfoAlertWidget.showCustomDialog(
          context, pairIdHint);
    });
    LighthouseV2DeviceProvider.instance
        .setPersistence(LighthouseV2Bloc(mainBloc));
    LighthouseV2DeviceProvider.instance
        .setCreateShortcutCallback((final mac, final name) async {
      if (SharedPlatform.isAndroid) {
        await AndroidLauncherShortcut.instance
            .requestShortcutLighthouse(mac, name);
      }
    });

    if (BuildOptions.includeGooglePlayInAppPurchases) {
      InAppPurchases.instance
          .handlePendingPurchases()
          .catchError((final error) {
        debugPrint(error.toString());
      });
    }

    return mainBloc;
  }
}

class LighthousePMApp extends StatelessWidget with WithBlocStateless {
  const LighthousePMApp({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context) {
    return DynamicColorBuilder(builder: (final lightColor, final darkColor) {
      return StreamBuilder<ThemeDataAndAppStyleStream>(
        stream:
            ThemeDataAndAppStyleStream.getStream(blocWithoutListen(context)),
        initialData: const ThemeDataAndAppStyleStream(null, null, null),
        builder: (final BuildContext context,
            final AsyncSnapshot<ThemeDataAndAppStyleStream>
                themeAndStyleSnapshot) {
          final data = themeAndStyleSnapshot.data;
          final themeMode = data?.themeMode ?? ThemeMode.system;
          final useDynamicColors = data?.style == AppStyle.materialDynamic;
          final dynamicColorsLight = lightColor ?? lightColorScheme;
          final dynamicColorsDark = darkColor ?? darkColorScheme;
          final scrollbarDesktop = data?.alwaysShowScrollbar ?? false;

          final scrollbarTheme = ScrollbarThemeData(
            thumbVisibility: MaterialStateProperty.all(scrollbarDesktop),
            radius: scrollbarDesktop ? Radius.zero : null,
          );

          return MaterialApp(
            debugShowCheckedModeBanner: true,
            title: 'Lighthouse PM',
            theme: ThemeData(
                colorScheme:
                    useDynamicColors ? dynamicColorsLight : lightColorScheme,
                useMaterial3: true,
                scrollbarTheme: scrollbarTheme.copyWith()),
            darkTheme: ThemeData(
                colorScheme:
                    useDynamicColors ? dynamicColorsDark : darkColorScheme,
                useMaterial3: true,
                scrollbarTheme: scrollbarTheme.copyWith()),
            themeMode: themeMode,
            initialRoute: '/',
            onGenerateRoute: (final RouteSettings settings) {
              // Make sure all these pages extend the Base page or else shortcut
              // handling won't work!
              final routes = <String, PageBuilder>{
                '/': (final context) => MainPage(),
                // '/': _createShortcutDebugPage,
                // Uncomment the line above if you need to debug the shortcut handler.
                '/settings': (final context) => const SettingsPage(),
                '/troubleshooting': (final context) =>
                    const TroubleshootingPage(),
                '/help': (final context) => const HelpPage(),
                '/shortcutHandler': (final context) =>
                    ShortcutHandlerPage(settings.arguments),
              };

              routes.addAll(SettingsPage.getSubPages('/settings'));

              if (!kReleaseMode) {
                routes.addAll(<String, PageBuilder>{
                  '/databaseTest': (final context) => DatabaseTestPage()
                });
                routes.addAll(DatabaseTestPage.getSubPages('/databaseTest'));
                routes['/material'] =
                    (final context) => const MaterialTestPage();
                routes['/404'] = (final context) => const NotFoundPage();
              }

              if (SharedPlatform.isWeb || !kReleaseMode) {
                final WidgetBuilder? builder = routes[settings.name];
                return MaterialPageRoute(
                    builder: (final ctx) =>
                        builder?.call(ctx) ?? const NotFoundPage(),
                    settings: settings);
              } else {
                final WidgetBuilder builder = routes[settings.name]!;
                return MaterialPageRoute(
                    builder: (final ctx) => builder(ctx), settings: settings);
              }
            },
          );
        },
      );
    });
  }
}

///
/// A simple shortcut handle debug page. Change the mac address if you need to
/// test it.
///
/// ignore: unused_element
BasePage _createShortcutDebugPage(final BuildContext context) {
  if (!kReleaseMode) {
    return const ShortcutHandlerPage(
        ShortcutHandle(ShortcutTypes.macType, "00:00:00:00:00:00"));
  }
  return const SimpleBasePage(Text('This should not be here.'));
}
