import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lighthouse_pm/lighthouseProvider/LighthouseDevice.dart';

class LighthouseMetadataPage extends StatelessWidget {
  LighthouseMetadataPage(this.device, {Key key}) : super(key: key);

  final LighthouseDevice device;

  @override
  Widget build(BuildContext context) {
    Map<String, String> map = Map();
    map["Name"] = device.name;
    map["Firmware version"] = device.firmwareVersion;
    map.addAll(device.otherMetadata);
    final entries = map.entries.toList(growable: false);

    return Scaffold(
      appBar: AppBar(title: Text('Lighthouse Metadata')),
      body: ListView.builder(
        itemBuilder: (BuildContext c, int index) {
          return ListTile(
            title: Text(entries[index].key),
            subtitle: Text(entries[index].value),
          );
        },
        itemCount: entries.length,
      ),
    );
  }
}
