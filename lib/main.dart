import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl_standalone.dart';
import 'package:lighthouse_pm/lighthouseProvider/LighthouseProvider.dart';
import 'package:lighthouse_pm/lighthouseProvider/deviceProviders/LighthouseV2DeviceProvider.dart';
import 'package:lighthouse_pm/pages/MainPage.dart';
import 'package:lighthouse_pm/lighthouseProvider/deviceProviders/ViveBaseStationDeviceProvider.dart';
import 'package:lighthouse_pm/pages/PrivacyPage.dart';
import 'package:lighthouse_pm/pages/SettingsPage.dart';
import 'package:lighthouse_pm/pages/TroubleshootingPage.dart';
import 'package:provider/provider.dart';

import 'bloc.dart';

void main() {
  findSystemLocale().then((locale) async {
    await initializeDateFormatting();
  });
  LighthouseProvider.instance
      .addBLEDeviceProvider(LighthouseV2DeviceProvider.instance);
  LighthouseProvider.instance
      .addBLEDeviceProvider(ViveBaseStationDeviceProvider.instance);
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider<LighthousePMBloc>(
      create: (_) => LighthousePMBloc(),
      dispose: (_, bloc) => bloc.close(),
      child: MaterialApp(
          debugShowCheckedModeBanner: true,
          title: 'Lighthouse PM',
          theme: ThemeData(
              primarySwatch: Colors.grey,
              visualDensity: VisualDensity.adaptivePlatformDensity),
          routes: {
            '/': (context) => MainPage(),
            '/settings': (context) => SettingsPage(),
            '/settings/privacy': (context) => PrivacyPage(),
            '/troubleshooting': (context) => TroubleshootingPage(),
          }
          // home: MainPage()
          ),
    );
  }
}
