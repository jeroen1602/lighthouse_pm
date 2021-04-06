import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lighthouse_pm/widgets/ScanningMixin.dart';

class MainPageDrawer extends StatelessWidget with ScanningMixin {
  MainPageDrawer(this.scanDuration, {Key? key}) : super(key: key);

  final Duration scanDuration;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      DrawerHeader(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/drawer-image.png'),
                  fit: BoxFit.cover)),
          child: SvgPicture.asset('assets/images/app-icon.svg')),
      ListTile(
          leading: Icon(Icons.report),
          title: Text('Troubleshooting'),
          onTap: () async {
            Navigator.pop(context);
            cleanUp();
            await Navigator.pushNamed(context, '/troubleshooting');
            startScanWithCheck(scanDuration,
                failMessage:
                    "Could not start scan because permission has not been granted. On navigator pop");
          }),
      ListTile(
        leading: Icon(Icons.info),
        title: Text('Help'),
        onTap: () async {
          Navigator.pop(context);
          cleanUp();
          await Navigator.pushNamed(context, '/help');
          startScanWithCheck(scanDuration,
              failMessage:
                  "Could not start scan because permission has not been granted. On navigator pop");
        },
      ),
      ListTile(
        leading: Icon(Icons.settings),
        title: Text('Settings'),
        onTap: () async {
          Navigator.pop(context);
          cleanUp();
          await Navigator.pushNamed(context, '/settings');
          startScanWithCheck(scanDuration,
              failMessage:
                  "Could not start scan because permission has not been granted. On navigator pop");
        },
      ),
    ];
    if (!kReleaseMode) {
      children.addAll([
        ListTile(
            leading: Icon(CommunityMaterialIcons.database),
            title: Text('Database test'),
            onTap: () async {
              Navigator.pop(context);
              cleanUp();
              await Navigator.pushNamed(context, '/databaseTest');
              startScanWithCheck(scanDuration,
                  failMessage:
                      "Could not start scan because permission has not been granted. On navigator pop");
            }),
      ]);
    }

    return Drawer(
        child: ListView(
      children: children,
    ));
  }
}
