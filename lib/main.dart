import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lighthouse_pm/lighthouseProvider/LighthouseProvider.dart';
import 'package:lighthouse_pm/lighthouseProvider/deviceProviders/LighthouseV2DeviceProvider.dart';
import 'package:lighthouse_pm/pages/AboutPage.dart';
import 'package:lighthouse_pm/pages/PrivacyPage.dart';
import 'package:lighthouse_pm/pages/SettingsPage.dart';
import 'package:lighthouse_pm/pages/TroubleshootingPage.dart';
import 'package:provider/provider.dart';

import 'bloc.dart';
import 'pages/MainPage.dart';

//region LICENSE
class SimpleLicense extends LicenseEntry {
  SimpleLicense(this.packages, this.paragraphs);

  final packages;
  final paragraphs;
}

Stream<LicenseEntry> licenses() async* {
  yield SimpleLicense([
    'Lighthouse Power Management'
  ], [
    LicenseParagraph("""Lighthouse power management
Copyright (C) 2020 Jeroen1602

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.""", 0)
  ]);
}
//endregion

void main() {
  LicenseRegistry.addLicense(licenses);
  LighthouseProvider.instance
      .addBLEDeviceProvider(LighthouseV2DeviceProvider.instance);
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
            '/about': (context) => AboutPage(),
            '/about/privacy': (context) => PrivacyPage(),
            '/troubleshooting': (context) => TroubleshootingPage(),
          }
          // home: MainPage()
          ),
    );
  }
}
