import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';

typedef Future _StartScanCallback({String failMessage});

class MainPageDrawer extends StatelessWidget {
  MainPageDrawer(VoidCallback cleanUp, _StartScanCallback startScanWithCheck,
      {Key key})
      : _cleanUp = cleanUp,
        _startScanWithCheck = startScanWithCheck,
        super(key: key);

  final VoidCallback _cleanUp;
  final _StartScanCallback _startScanWithCheck;

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
                decoration: BoxDecoration(image: DecorationImage(
                  image: AssetImage('assets/images/drawer-image.png'),
                  fit: BoxFit.cover
                )),
                child: SvgPicture.asset('assets/images/app-icon.svg')),
            ListTile(
                leading: Icon(Icons.report),
                title: Text('Troubleshooting'),
                onTap: () async {
                  Navigator.pop(context);
                  _cleanUp();
                  await Navigator.pushNamed(context, '/troubleshooting');
                  _startScanWithCheck(
                      failMessage:
                      "Could not start scan because permission has not been granted. On navigator pop");
                }),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () async {
                Navigator.pop(context);
                _cleanUp();
                await Navigator.pushNamed(context, '/settings');
                _startScanWithCheck(
                    failMessage:
                    "Could not start scan because permission has not been granted. On navigator pop");
              },
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('Help'),
              onTap: () async {
                Navigator.pop(context);
                _cleanUp();
                await Navigator.pushNamed(context, '/help');
                _startScanWithCheck(
                    failMessage:
                    "Could not start scan because permission has not been granted. On navigator pop");
              },
            ),
          ],
        ));
  }
}
