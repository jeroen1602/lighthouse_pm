import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lighthouse_pm/data/database.dart';
import 'package:lighthouse_pm/lighthouse_provider/lighthouse_provider.dart';
import 'package:lighthouse_pm/lighthouse_provider/back_end/bluez_back_end.dart';
import 'package:lighthouse_pm/lighthouse_provider/back_end/flutter_blue_lighthouse_back_end.dart';
import 'package:lighthouse_pm/lighthouse_provider/back_end/flutter_web_bluetooth_back_end.dart';
import 'package:lighthouse_pm/lighthouse_provider/device_providers/lighthouse_v2_device_provider.dart';
import 'package:lighthouse_pm/lighthouse_provider/device_providers/vive_base_station_device_provider.dart';
import 'package:lighthouse_pm/pages/base_page.dart';
import 'package:lighthouse_pm/pages/database_test_page.dart';
import 'package:lighthouse_pm/pages/help_page.dart';
import 'package:lighthouse_pm/pages/main_page.dart';
import 'package:lighthouse_pm/pages/not_found_page.dart';
import 'package:lighthouse_pm/pages/settings_page.dart';
import 'package:lighthouse_pm/pages/shortcut_handler_page.dart';
import 'package:lighthouse_pm/pages/simple_base_page.dart';
import 'package:lighthouse_pm/pages/troubleshooting_page.dart';
import 'package:lighthouse_pm/platform_specific/mobile/in_app_purchases.dart';
import 'package:lighthouse_pm/platform_specific/mobile/android/android_launcher_shortcut/android_launcher_shortcut.dart';
import 'package:lighthouse_pm/platform_specific/shared/intl.dart';
import 'package:lighthouse_pm/platform_specific/shared/local_platform.dart';
import 'package:lighthouse_pm/widgets/content_container_widget.dart';
import 'package:provider/provider.dart';

import 'build_options.dart';
import 'bloc.dart';

void main() {
  loadIntlStrings();

  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider<LighthousePMBloc>(
      create: (_) => _initializeDataBase(),
      dispose: (_, bloc) => bloc.close(),
      child: LighthousePMApp(),
    );
  }

  LighthousePMBloc _initializeDataBase() {
    final db = constructDb();
    final mainBloc = LighthousePMBloc(db);

    if (LocalPlatform.isIOS || LocalPlatform.isAndroid) {
      LighthouseProvider.instance
          .addBackEnd(FlutterBlueLighthouseBackEnd.instance);
    }
    if (LocalPlatform.isWeb) {
      LighthouseProvider.instance
          .addBackEnd(FlutterWebBluetoothBackend.instance);
    }
    if (LocalPlatform.isLinux) {
      LighthouseProvider.instance.addBackEnd(BlueZBackEnd.instance);
    }
    if (!kReleaseMode) {
      // Add this back if you need to test for devices you don't own.
      // you'll also need to
      // import 'package:lighthouse_pm/lighthouse_provider/backEnd/fake_ble_back_end.dart';

      // LighthouseProvider.instance.addBackEnd(FakeBLEBackEnd.instance);
    }

    LighthouseProvider.instance
        .addProvider(LighthouseV2DeviceProvider.instance);

    ViveBaseStationDeviceProvider.instance.setBloc(mainBloc);
    LighthouseV2DeviceProvider.instance.setBloc(mainBloc);

    if (BuildOptions.includeGooglePlayInAppPurchases) {
      InAppPurchases.instance.handlePendingPurchases().catchError((error) {
        debugPrint(error.toString());
      });
    }

    return mainBloc;
  }
}

class LighthousePMApp extends StatelessWidget with WithBlocStateless {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
        initialData: false,
        stream: ContentScrollbar.alwaysShowScrollbarStream,
        builder: (BuildContext context,
            AsyncSnapshot<bool> desktopScrollbarSnapshot) {
          final scrollbarDesktop = desktopScrollbarSnapshot.requireData;

          return StreamBuilder<ThemeMode>(
              stream: blocWithoutListen(context)
                  .settings
                  .getPreferredThemeAsStream(),
              initialData: ThemeMode.system,
              builder: (BuildContext context,
                  AsyncSnapshot<ThemeMode> themeSnapshot) {
                final scrollbarTheme = ScrollbarThemeData(
                  isAlwaysShown: scrollbarDesktop,
                  radius: scrollbarDesktop ? Radius.zero : null,
                );

                return MaterialApp(
                  debugShowCheckedModeBanner: true,
                  title: 'Lighthouse PM',
                  theme: ThemeData(
                      colorScheme: ColorScheme.light(),
                      primarySwatch: Colors.blueGrey,
                      selectedRowColor: Colors.grey,
                      disabledColor: Colors.grey.shade400,
                      appBarTheme: AppBarTheme(
                          iconTheme: IconThemeData(color: Colors.white)),
                      scrollbarTheme: scrollbarTheme.copyWith()),
                  darkTheme: ThemeData(
                      colorScheme: ColorScheme.dark(),
                      primarySwatch: Colors.blueGrey,
                      selectedRowColor: Colors.blueGrey,
                      appBarTheme: AppBarTheme(
                          iconTheme: IconThemeData(color: Colors.white)),
                      scrollbarTheme: scrollbarTheme.copyWith()),
                  themeMode: themeSnapshot.data,
                  initialRoute: '/',
                  onGenerateRoute: (RouteSettings settings) {
                    // Make sure all these pages extend the Base page or else shortcut
                    // handling won't work!
                    final routes = <String, PageBuilder>{
                      '/': (context) => MainPage(),
                      // '/': _createShortcutDebugPage,
                      // Uncomment the line above if you need to debug the shortcut handler.
                      '/settings': (context) => SettingsPage(),
                      '/troubleshooting': (context) => TroubleshootingPage(),
                      '/help': (context) => HelpPage(),
                      '/shortcutHandler': (context) =>
                          ShortcutHandlerPage(settings.arguments),
                    };

                    routes.addAll(SettingsPage.getSubPages('/settings'));

                    if (!kReleaseMode) {
                      routes.addAll(<String, PageBuilder>{
                        '/databaseTest': (context) => DatabaseTestPage()
                      });
                      routes.addAll(
                          DatabaseTestPage.getSubPages('/databaseTest'));
                      routes['/404'] = (context) => NotFoundPage();
                    }

                    if (LocalPlatform.isWeb || !kReleaseMode) {
                      WidgetBuilder? builder = routes[settings.name];
                      return MaterialPageRoute(
                          builder: (ctx) =>
                              builder?.call(ctx) ?? NotFoundPage(),
                          settings: settings);
                    } else {
                      WidgetBuilder builder = routes[settings.name]!;
                      return MaterialPageRoute(
                          builder: (ctx) => builder(ctx), settings: settings);
                    }
                  },
                );
              });
        });
  }
}

///
/// A simple shortcut handle debug page. Change the mac address if you need to
/// test it.
///
/// ignore: unused_element
BasePage _createShortcutDebugPage(BuildContext context) {
  if (!kReleaseMode) {
    return ShortcutHandlerPage(
        ShortcutHandle(ShortcutTypes.macType, "00:00:00:00:00:00"));
  }
  return SimpleBasePage(Text('This should not be here.'));
}
