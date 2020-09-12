import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:lighthouse_pm/lighthouseProvider/LighthouseDevice.dart';
import 'package:toast/toast.dart';
import 'package:vibration/vibration.dart';

class LighthouseMetadataPage extends StatelessWidget {
  LighthouseMetadataPage(this.device, {Key key}) : super(key: key);

  final LighthouseDevice device;

  @override
  Widget build(BuildContext context) {
    Map<String, String> map = Map();
    map["Device type"] = "${device.runtimeType}";
    map["Name"] = device.name;
    map["Firmware version"] = device.firmwareVersion;
    map.addAll(device.otherMetadata);
    final entries = map.entries.toList(growable: false);

    return Scaffold(
      appBar: AppBar(title: Text('Lighthouse Metadata')),
      body: ListView.builder(
        itemBuilder: (BuildContext c, int index) {
          return InkWell(
            child: ListTile(
              title: Text(entries[index].key),
              subtitle: Text(entries[index].value),
            ),
            onLongPress: () async {
              Clipboard.setData(ClipboardData(text: entries[index].value));
              if (await Vibration.hasVibrator()) {
                Vibration.vibrate(duration: 200);
              }
              Toast.show('Copied to clipboard', context,
                  duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
            },
          );
        },
        itemCount: entries.length,
      ),
    );
  }
}
