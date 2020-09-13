import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lighthouse_pm/pages/settings/SettingsNicknamesPage.dart';
import 'package:package_info/package_info.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

const _GITHUB_URL = "https://github.com/jeroen1602/lighthouse_pm";

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
              leading: SvgPicture.asset(
                "assets/images/app-icon.svg",
                width: 24.0,
                height: 24.0,
              ),
              title: Text('Lighthouse Power management',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headline6
                      .copyWith(fontWeight: FontWeight.bold)),
            ),
            Divider(
              thickness: 1.5,
            ),
            ListTile(
              title: Text('Lighthouses with nicknames'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => SettingsNicknamesPage())),
            ),
            Divider(),
            ListTile(
              title: Text('About',
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      .copyWith(fontWeight: FontWeight.bold)),
            ),
            Divider(
              thickness: 1.5,
            ),
            ListTile(
              title: Text('Licences'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () => {showLicensePage(context: context)},
            ),
            Divider(),
            ListTile(
              title: Text('Privacy'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () => Navigator.pushNamed(context, '/settings/privacy'),
            ),
            Divider(),
            ListTile(
              title: Text('Fork me on Github'),
              trailing: Icon(Icons.arrow_forward_ios),
              leading: SvgPicture.asset(
                "assets/images/github-dark.svg",
                width: 24,
                height: 24,
              ),
              onTap: () async {
                if (await canLaunch(_GITHUB_URL)) {
                  await launch(_GITHUB_URL);
                }
              },
            ),
            Divider(),
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (_, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return ListTile(
                    title: Text('Version'),
                    subtitle: Text('${snapshot.error}'),
                  );
                }
                final data = snapshot.data;
                return ListTile(
                  title: Text('Version'),
                  subtitle: Text('${data.version}'),
                  onLongPress: () async {
                    await Clipboard.setData(ClipboardData(text: data.version));
                    Toast.show('Copied to clipboard', context,
                        duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
                  },
                );
              },
            ),
            Divider()
          ],
        ));
  }
}
