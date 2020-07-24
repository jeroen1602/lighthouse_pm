import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

import 'PrivacyPage.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('About'),
        ),
        body: FutureBuilder<PackageInfo>(
          future: PackageInfo.fromPlatform(),
          builder: (context, snapshot) {
            final List<Widget> children = [
              ListTile(
                leading: Icon(Icons.ac_unit),
                title: Text('Lighthouse Power management',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headline5
                        .copyWith(color: Colors.black)),
              ),
              Divider(),
              ListTile(title: Text('AAAA')),
              Divider(),
              ListTile(
                title: Text(
                  'Licences',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headline6
                      .copyWith(color: Colors.black),
                ),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () => {showLicensePage(context: context)},
              ),
              Divider(),
              ListTile(
                title: Text('Privacy',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headline6
                        .copyWith(color: Colors.black)),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () => {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => PrivacyPage()))
                },
              ),
              Divider(),
            ];
            if (snapshot.hasData) {
              final data = snapshot.data;
              children.add(ListTile(
                title: Text('version'),
                subtitle: Text('${data.version}'),
              ));
            } else if (snapshot.hasError) {
              children.add(ListTile(
                  title: Text('Version'),
                  subtitle: Text(
                    '${snapshot.error}',
                  )));
            } else {
              children.add(CircularProgressIndicator());
            }

            return ListView(children: children);
          },
        ));
  }
}
