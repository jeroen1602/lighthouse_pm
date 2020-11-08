import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl_standalone.dart';
import 'package:lighthouse_pm/data/Database.dart';
import 'package:lighthouse_pm/lighthouseProvider/LighthouseProvider.dart';
import 'package:lighthouse_pm/lighthouseProvider/backEnd/FlutterBlueLighthouseBackEnd.dart';
import 'package:lighthouse_pm/lighthouseProvider/deviceProviders/LighthouseV2DeviceProvider.dart';
import 'package:lighthouse_pm/lighthouseProvider/deviceProviders/ViveBaseStationDeviceProvider.dart';
import 'package:lighthouse_pm/pages/HelpPage.dart';
import 'package:lighthouse_pm/pages/MainPage.dart';
import 'package:lighthouse_pm/pages/PrivacyPage.dart';
import 'package:lighthouse_pm/pages/SettingsPage.dart';
import 'package:lighthouse_pm/pages/TroubleshootingPage.dart';
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

class LighthousePMApp extends StatelessWidget {
  LighthousePMBloc _bloc(BuildContext context) =>
      Provider.of<LighthousePMBloc>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ThemeMode>(
      stream: _bloc(context).settings.getPreferedThemeAsStream(),
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
              routes: {
            '/': (context) => MainPage(),
            '/settings': (context) => SettingsPage(),
            '/settings/privacy': (context) => PrivacyPage(),
            '/troubleshooting': (context) => TroubleshootingPage(),
            '/help': (context) => HelpPage(),
          }),
    );
  }
}
