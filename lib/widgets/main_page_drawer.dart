import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lighthouse_pm/widgets/scanning_mixin.dart';

class MainPageDrawer extends StatelessWidget with ScanningMixin {
  const MainPageDrawer(this.scanDuration, this.updateInterval, {super.key});

  final Duration scanDuration;
  final Duration updateInterval;

  @override
  Widget build(final BuildContext context) {
    final children = <Widget>[
      DrawerHeader(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/drawer-image.png'),
                  fit: BoxFit.cover)),
          child: SvgPicture.asset('assets/images/app-icon.svg')),
      ListTile(
          leading: const Icon(Icons.report),
          title: const Text('Troubleshooting'),
          onTap: () async {
            Navigator.pop(context);
            cleanUp();
            await Navigator.pushNamed(context, '/troubleshooting');
            startScanWithCheck(scanDuration,
                updateInterval: updateInterval,
                failMessage:
                    "Could not start scan because permission has not been granted. On navigator pop");
          }),
      ListTile(
        leading: const Icon(Icons.info),
        title: const Text('Help'),
        onTap: () async {
          Navigator.pop(context);
          cleanUp();
          await Navigator.pushNamed(context, '/help');
          startScanWithCheck(scanDuration,
              updateInterval: updateInterval,
              failMessage:
                  "Could not start scan because permission has not been granted. On navigator pop");
        },
      ),
      ListTile(
        leading: const Icon(Icons.settings),
        title: const Text('Settings'),
        onTap: () async {
          Navigator.pop(context);
          cleanUp();
          await Navigator.pushNamed(context, '/settings');
          startScanWithCheck(scanDuration,
              updateInterval: updateInterval,
              failMessage:
                  "Could not start scan because permission has not been granted. On navigator pop");
        },
      ),
      if (!kReleaseMode) ...[
        ListTile(
            leading: const Icon(CommunityMaterialIcons.database),
            title: const Text('Database test'),
            onTap: () async {
              Navigator.pop(context);
              cleanUp();
              await Navigator.pushNamed(context, '/databaseTest');
              startScanWithCheck(scanDuration,
                  updateInterval: updateInterval,
                  failMessage:
                      "Could not start scan because permission has not been granted. On navigator pop");
            }),
        ListTile(
          leading: const Icon(CommunityMaterialIcons.material_design),
          title: const Text('Material test page'),
          onTap: () async {
            Navigator.pop(context);
            cleanUp();
            await Navigator.pushNamed(context, '/material');
            startScanWithCheck(scanDuration,
                updateInterval: updateInterval,
                failMessage:
                    "Could not start scan because permission has not been granted. On navigator pop");
          },
        ),
        ListTile(
            leading: const Icon(CommunityMaterialIcons.pulse),
            title: const Text('Activity log'),
            onTap: () async {
              Navigator.pop(context);
              cleanUp();
              await Navigator.pushNamed(context, '/log');
              startScanWithCheck(scanDuration,
                  updateInterval: updateInterval,
                  failMessage:
                      "Could not start scan because permission has not been granted. On navigator pop");
            })
      ]
    ];

    return Drawer(
        child: ListView(
      children: children,
    ));
  }
}
