import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

const _github_url = "https://github.com/jeroen1602/lighthouse_pm";

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
                leading: SvgPicture.asset("assets/images/app-icon.svg"),
                title: Text('Lighthouse Power management',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headline5
                        .copyWith(color: Colors.black)),
              ),
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
                onTap: () => Navigator.pushNamed(context, '/about/privacy'),
              ),
              Divider(),
              ListTile(
                title: Text('Fork me on Github',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headline6
                        .copyWith(color: Colors.black)),
                trailing: Icon(Icons.arrow_forward_ios),
                leading: SvgPicture.asset(
                  "assets/images/github-dark.svg",
                  width: 24,
                  height: 24,
                ),
                onTap: () async {
                  if (await canLaunch(_github_url)) {
                    await launch(_github_url);
                  }
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
