import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl_standalone.dart';
import 'package:lighthouse_pm/data/Database.dart';
import 'package:lighthouse_pm/lighthouseProvider/LighthouseProvider.dart';
import 'package:lighthouse_pm/lighthouseProvider/backEnd/FlutterBlueLighthouseBackEnd.dart';
import 'package:lighthouse_pm/lighthouseProvider/deviceProviders/LighthouseV2DeviceProvider.dart';
import 'package:lighthouse_pm/lighthouseProvider/deviceProviders/ViveBaseStationDeviceProvider.dart';
import 'package:lighthouse_pm/pages/BasePage.dart';
import 'package:lighthouse_pm/pages/HelpPage.dart';
import 'package:lighthouse_pm/pages/MainPage.dart';
import 'package:lighthouse_pm/pages/PrivacyPage.dart';
import 'package:lighthouse_pm/pages/SettingsPage.dart';
import 'package:lighthouse_pm/pages/ShortcutHandlerPage.dart';
import 'package:lighthouse_pm/pages/SimpleBasePage.dart';
import 'package:lighthouse_pm/pages/TroubleshootingPage.dart';
import 'package:lighthouse_pm/platformSpecific/android/Shortcut.dart';
import 'package:provider/provider.dart';

import 'bloc.dart';

void main() {
  findSystemLocale().then((locale) async {
    await initializeDateFormatting();
  });

  LighthouseProvider.instance.addBackEnd(FlutterBlueLighthouseBackEnd.instance);
  if (!kReleaseMode) {
    // Add this back if you need to test for devices you don't own.
    // you'll also need to
    // import 'package:lighthouse_pm/lighthouseProvider/backEnd/FakeBLEBackEnd.dart';

    // LighthouseProvider.instance.addBackEnd(FakeBLEBackEnd.instance);
  }

  LighthouseProvider.instance.addProvider(LighthouseV2DeviceProvider.instance);

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
    final db = LighthouseDatabase();
    final mainBloc = LighthousePMBloc(db);
    ViveBaseStationDeviceProvider.instance
        .setViveBaseStationBloc(mainBloc.viveBaseStation);

    return mainBloc;
  }
}

/// The same as a [WidgetBuilder] only require it to return a [BasePage].
typedef PageBuilder = BasePage Function(BuildContext context);

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
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.dark(),
          primarySwatch: Colors.blueGrey,
          selectedRowColor: Colors.blueGrey,
        ),
        themeMode: themeSnapshot.data,
        onGenerateRoute: (RouteSettings settings) {
          // Make sure all these pages extend the Base page or else shortcut
          // handling won't work!
          final routes = <String, PageBuilder>{
            '/': (context) => MainPage(),
            // '/': _createShortcutDebugPage,
            // Uncomment the line above if you need to debug the shortcut handler.
            '/settings': (context) => SettingsPage(),
            '/settings/privacy': (context) => PrivacyPage(),
            '/troubleshooting': (context) => TroubleshootingPage(),
            '/help': (context) => HelpPage(),
            '/shortcutHandler': (context) =>
                ShortcutHandlerPage(settings.arguments),
          };
          WidgetBuilder builder = routes[settings.name];
          return MaterialPageRoute(builder: (ctx) => builder(ctx));
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
