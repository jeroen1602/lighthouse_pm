import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lighthouse_pm/data/database.dart';
import 'package:lighthouse_pm/theming.dart';
import 'package:lighthouse_pm/widgets/nickname_alert_widget.dart';
import 'package:rxdart/rxdart.dart';
import 'package:toast/toast.dart';
import 'package:vibration/vibration.dart';

import '../../bloc.dart';
import '../device_extensions/device_with_extensions.dart';
import '../lighthouse_device.dart';

class LighthouseMetadataPage extends StatefulWidget {
  LighthouseMetadataPage(this.device, {Key? key}) : super(key: key);

  final LighthouseDevice device;
  final BehaviorSubject<int> _updateSubject = BehaviorSubject.seeded(0);

  @override
  State<StatefulWidget> createState() {
    return LighthouseMetadataState();
  }
}

class LighthouseMetadataState extends State<LighthouseMetadataPage> {
  Future<void> changeNicknameHandler(String? currentNickname) async {
    final newNickname = await NicknameAlertWidget.showCustomDialog(context,
        deviceId: widget.device.deviceIdentifier.toString(),
        deviceName: widget.device.name,
        nickname: currentNickname);
    if (newNickname != null) {
      if (newNickname.nickname == null) {
        await blocWithoutListen.nicknames
            .deleteNicknames([newNickname.deviceId]);
      } else {
        await blocWithoutListen.nicknames
            .insertNickname(newNickname.toNickname()!);
      }
    }
  }

  List<Widget> _generateBody() {
    Map<String, String?> map = {};
    map["Device type"] = "${widget.device.runtimeType}";
    map["Name"] = widget.device.name;
    map["Firmware version"] = widget.device.firmwareVersion;
    map.addAll(widget.device.otherMetadata);
    final entries = map.entries.toList(growable: false);
    final List<Widget> body = [];

    if (widget.device is DeviceWithExtensions &&
        (widget.device as DeviceWithExtensions).deviceExtensions.isNotEmpty) {
      body.add(_ExtraActionsWidget(
        widget.device as DeviceWithExtensions,
        updateList: () {
          widget._updateSubject.add((widget._updateSubject.value ?? 0) + 1);
        },
      ));
    }

    for (int i = 0; i < entries.length; i++) {
      body.add(_MetadataInkWell(name: entries[i].key, value: entries[i].value));
    }

    body.add(StreamBuilder<Nickname?>(
      stream: bloc.nicknames
          .watchNicknameForDeviceIds(widget.device.deviceIdentifier.toString()),
      builder: (BuildContext context, AsyncSnapshot<Nickname?> snapshot) {
        final nickname = snapshot.data;
        if (nickname != null) {
          return _MetadataInkWell(
            name: 'Nickname',
            value: nickname.nickname,
            onTap: () {
              changeNicknameHandler(nickname.nickname);
            },
          );
        } else {
          final theming = Theming.of(context);
          return InkWell(
            child: ListTile(
              title: Text('Nickname'),
              subtitle: Text(
                'Not set',
                style: theming.bodyText?.copyWith(
                    fontStyle: FontStyle.italic, color: theming.disabledColor),
              ),
              onTap: () {
                changeNicknameHandler(null);
              },
            ),
          );
        }
      },
    ));

    return body;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lighthouse Metadata')),
      body: StreamBuilder<int>(
        stream: widget._updateSubject.stream,
        builder: (c, s) => ListView(
          children: _generateBody(),
        ),
      ),
    );
  }
}

class _MetadataInkWell extends StatelessWidget {
  _MetadataInkWell({Key? key, required this.name, this.value, this.onTap})
      : super(key: key);

  final String name;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theming = Theming.of(context);
    return InkWell(
      child: ListTile(
        title: Text(name),
        subtitle: Text(
          value ?? 'Not set',
          style: value != null
              ? null
              : theming.bodyText?.copyWith(
                  fontStyle: FontStyle.italic, color: theming.disabledColor),
        ),
      ),
      onLongPress: () async {
        Clipboard.setData(ClipboardData(text: value));
        if (await Vibration.hasVibrator() == true) {
          Vibration.vibrate(duration: 200);
        }
        Toast.show('Copied to clipboard', context,
            duration: Toast.lengthShort, gravity: Toast.bottom);
      },
      onTap: onTap,
    );
  }
}

class _ExtraActionsWidget extends StatelessWidget {
  _ExtraActionsWidget(this.device, {Key? key, this.updateList})
      : super(key: key);

  final DeviceWithExtensions device;
  final VoidCallback? updateList;

  @override
  Widget build(BuildContext context) {
    final extensions = device.deviceExtensions.toList(growable: false);
    final theming = Theming.of(context);

    return Container(
        height: 165.0,
        child: Column(
          children: [
            Flexible(
              child: ListTile(
                title: Text(
                  'Extra actions',
                  style: theming.headline5,
                ),
              ),
            ),
            Divider(),
            Container(
              height: 85.0,
              child: ListView.builder(
                itemBuilder: (c, index) {
                  return Column(
                    children: [
                      Container(
                        height: 60.0,
                        child: StreamBuilder<bool>(
                          stream: extensions[index].enabledStream,
                          initialData: false,
                          builder: (c, snapshot) {
                            final enabled = snapshot.data == true;
                            return RawMaterialButton(
                              onPressed: () async {
                                await extensions[index].onTap();
                                if (extensions[index].updateListAfter) {
                                  updateList?.call();
                                }
                              },
                              enableFeedback: enabled,
                              elevation: 2.0,
                              fillColor: enabled
                                  ? theming.buttonColor
                                  : theming.disabledColor,
                              padding: const EdgeInsets.all(2.0),
                              shape: CircleBorder(),
                              child: extensions[index].icon,
                            );
                          },
                        ),
                      ),
                      Container(
                        height: 5,
                      ),
                      Text(extensions[index].toolTip),
                    ],
                  );
                },
                itemCount: extensions.length,
                scrollDirection: Axis.horizontal,
              ),
            ),
            Divider(
              thickness: 1.5,
            ),
          ],
        ));
  }
}
