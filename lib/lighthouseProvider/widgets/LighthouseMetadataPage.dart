import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:lighthouse_pm/data/Database.dart';
import 'package:lighthouse_pm/lighthouseProvider/LighthouseDevice.dart';
import 'package:lighthouse_pm/widgets/NicknameAlertWidget.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import 'package:vibration/vibration.dart';

import '../../bloc.dart';

class LighthouseMetadataPage extends StatefulWidget {
  LighthouseMetadataPage(this.device, {Key key}) : super(key: key);

  final LighthouseDevice device;

  @override
  State<StatefulWidget> createState() {
    return LighthouseMetadataState();
  }
}

class LighthouseMetadataState extends State<LighthouseMetadataPage> {
  LighthousePMBloc get _bloc => Provider.of<LighthousePMBloc>(context);

  LighthousePMBloc get _blocWithoutListen =>
      Provider.of<LighthousePMBloc>(context, listen: false);

  Future<void> changeNicknameHandler(String currentNickname) async {
    final newNickname = await NicknameAlertWidget.showCustomDialog(context,
        macAddress: widget.device.deviceIdentifier.toString(),
        deviceName: widget.device.name,
        nickname: currentNickname);
    if (newNickname != null) {
      if (newNickname.nickname == null) {
        await _blocWithoutListen.deleteNicknames([newNickname.macAddress]);
      } else {
        await _blocWithoutListen.insertNewNickname(newNickname);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, String> map = Map();
    map["Device type"] = "${widget.device.runtimeType}";
    map["Name"] = widget.device.name;
    map["Firmware version"] = widget.device.firmwareVersion;
    map.addAll(widget.device.otherMetadata);
    final entries = map.entries.toList(growable: false);

    return Scaffold(
      appBar: AppBar(title: Text('Lighthouse Metadata')),
      body: ListView.builder(
        itemBuilder: (BuildContext c, int index) {
          if (index == entries.length) {
            return StreamBuilder<Nickname>(
              stream: _bloc.watchNicknameForMacAddress(
                  widget.device.deviceIdentifier.toString()),
              builder:
                  (BuildContext context, AsyncSnapshot<Nickname> snapshot) {
                if (snapshot.hasData) {
                  return _MetadataInkWell(
                    name: 'Nickname',
                    value: snapshot.data.nickname,
                    onTap: () {
                      changeNicknameHandler(snapshot.data.nickname);
                    },
                  );
                } else {
                  final theme = Theme.of(context);
                  return InkWell(
                    child: ListTile(
                      title: Text('Nickname'),
                      subtitle: Text(
                        'Not set',
                        style: theme.textTheme.bodyText2.copyWith(
                            fontStyle: FontStyle.italic,
                            color: theme.textTheme.caption.color),
                      ),
                      onTap: () {
                        changeNicknameHandler(null);
                      },
                    ),
                  );
                }
              },
            );
          }
          return _MetadataInkWell(
              name: entries[index].key, value: entries[index].value);
        },
        itemCount: entries.length + 1,
      ),
    );
  }
}

class _MetadataInkWell extends StatelessWidget {
  _MetadataInkWell({Key key, this.name, this.value, this.onTap})
      : super(key: key);

  final String name;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: ListTile(
        title: Text(name),
        subtitle: Text(value),
      ),
      onLongPress: () async {
        Clipboard.setData(ClipboardData(text: value));
        if (await Vibration.hasVibrator()) {
          Vibration.vibrate(duration: 200);
        }
        Toast.show('Copied to clipboard', context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      },
      onTap: onTap,
    );
  }
}
