import 'package:flutter/material.dart';
import 'package:lighthouse_pm/widgets/ContentContainerWidget.dart';

import '../BasePage.dart';

class PrivacyPage extends BasePage {
  @override
  Widget buildPage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy'),
      ),
      body: ContentContainerWidget(builder: (context) {
        return ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(24.0),
              child: Text('This app does not collect any user information. '
                  'In fact this app doesn\'t even have the internet permission, '
                  'so it can\'t make any internet connections to share any data.'
                  '\n\n'
                  'Android:\n'
                  'For Android, in order for an app to use Bluetooth Low Energy '
                  '(BLE), the technology used to communicate with the lighthouses, '
                  'it needs to request location permissions. This is because '
                  'an app that uses BLE could technically triangulate a '
                  'device\'s location. An app that has the location permissions'
                  ' could also use the GPS module in the device. Lighthouse PM '
                  'does not use the GPS module in a device and only uses the '
                  'BLE functionality. It also only searches for the lighthouses '
                  'and ignores any other devices the area.'),
            )
          ],
        );
      }),
    );
  }
}
