import 'package:flutter/material.dart';
import 'package:lighthouse_pm/pages/settings/SettingsNicknamesPage.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
        ),
        body: Column(
          children: [
            ListTile(
              title: Text('Settings',
                  style: Theme.of(context).textTheme.headline5),
            ),
            Divider(),
            ListTile(
              title: Text('Lighthouses with nicknames'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => SettingsNicknamesPage())),
            ),
            Divider(),
          ],
        ));
  }
}
