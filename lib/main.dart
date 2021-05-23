import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lighthouse_pm/data/Database.dart';
import 'package:lighthouse_pm/lighthouseProvider/LighthouseProvider.dart';
import 'package:lighthouse_pm/lighthouseProvider/backEnd/FlutterBlueLighthouseBackEnd.dart';
import 'package:lighthouse_pm/lighthouseProvider/backEnd/FlutterWebBluetoothBackEnd.dart';
import 'package:lighthouse_pm/lighthouseProvider/deviceProviders/LighthouseV2DeviceProvider.dart';
import 'package:lighthouse_pm/lighthouseProvider/deviceProviders/ViveBaseStationDeviceProvider.dart';
import 'package:lighthouse_pm/pages/BasePage.dart';
import 'package:lighthouse_pm/pages/DatabaseTestPage.dart';
import 'package:lighthouse_pm/pages/HelpPage.dart';
import 'package:lighthouse_pm/pages/MainPage.dart';
import 'package:lighthouse_pm/pages/NotFoundPage.dart';
import 'package:lighthouse_pm/pages/SettingsPage.dart';
import 'package:lighthouse_pm/pages/ShortcutHandlerPage.dart';
import 'package:lighthouse_pm/pages/SimpleBasePage.dart';
import 'package:lighthouse_pm/pages/TroubleshootingPage.dart';
import 'package:lighthouse_pm/platformSpecific/mobile/android/androidLauncherShortcut/AndroidLauncherShortcut.dart';
import 'package:lighthouse_pm/platformSpecific/shared/Intl.dart';
import 'package:lighthouse_pm/platformSpecific/shared/LocalPlatform.dart';
import 'package:provider/provider.dart';

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
    if (!kReleaseMode) {
      // Add this back if you need to test for devices you don't own.
      // you'll also need to
      // import 'package:lighthouse_pm/lighthouseProvider/backEnd/FakeBLEBackEnd.dart';

      // LighthouseProvider.instance.addBackEnd(FakeBLEBackEnd.instance);
    }

    LighthouseProvider.instance
        .addProvider(LighthouseV2DeviceProvider.instance);

    ViveBaseStationDeviceProvider.instance
        .setViveBaseStationDao(mainBloc.viveBaseStation);
    LighthouseV2DeviceProvider.instance.setLighthousePMBloc(mainBloc);

    return mainBloc;
  }
}

class LighthousePMApp extends StatelessWidget with WithBlocStateless {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ThemeMode>(
      stream: blocWithoutListen(context).settings.getPreferredThemeAsStream(),
      initialData: ThemeMode.system,
      builder: (BuildContext context, AsyncSnapshot<ThemeMode> themeSnapshot) =>
          MaterialApp(
        debugShowCheckedModeBanner: true,
        title: 'Lighthouse PM',
        theme: ThemeData(
          colorScheme: ColorScheme.light(),
          primarySwatch: Colors.blueGrey,
          selectedRowColor: Colors.grey,
          disabledColor: Colors.grey.shade400,
          appBarTheme:
              AppBarTheme(iconTheme: IconThemeData(color: Colors.white)),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.dark(),
          primarySwatch: Colors.blueGrey,
          selectedRowColor: Colors.blueGrey,
          appBarTheme:
              AppBarTheme(iconTheme: IconThemeData(color: Colors.white)),
        ),
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
            routes.addAll(DatabaseTestPage.getSubPages('/databaseTest'));
            routes['/404'] = (context) => NotFoundPage();
          }

          if (LocalPlatform.isWeb || !kReleaseMode) {
            WidgetBuilder? builder = routes[settings.name];
            return MaterialPageRoute(
                builder: (ctx) => builder?.call(ctx) ?? NotFoundPage(),
                settings: settings);
          } else {
            WidgetBuilder builder = routes[settings.name]!;
            return MaterialPageRoute(
                builder: (ctx) => builder(ctx), settings: settings);
          }
        },
      ),
    );
  }
}

///
/// A simple shortcut handle debug page. Change the mac address if you need to
/// test it.
///
BasePage _createShortcutDebugPage(BuildContext context) {
  if (!kReleaseMode) {
    return ShortcutHandlerPage(
        ShortcutHandle(ShortcutTypes.MAC_TYPE, "00:00:00:00:00:00"));
  }
  return SimpleBasePage(Text('This should not be here.'));
}
