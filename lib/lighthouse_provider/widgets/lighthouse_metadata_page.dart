import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lighthouse_pm/data/database.dart';
import 'package:lighthouse_pm/theming.dart';
import 'package:lighthouse_pm/widgets/nickname_alert_widget.dart';
import 'package:lighthouse_provider/device_extensions/device_extension.dart';
import 'package:lighthouse_provider/lighthouse_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:toast/toast.dart';
import 'package:vibration/vibration.dart';

import '../../bloc.dart';
import 'widget_for_extension.dart';

class LighthouseMetadataPage extends StatefulWidget {
  LighthouseMetadataPage(this.device, {super.key});

  final LighthouseDevice device;
  final BehaviorSubject<int> _updateSubject = BehaviorSubject.seeded(0);

  @override
  State<StatefulWidget> createState() {
    return LighthouseMetadataState();
  }
}

class LighthouseMetadataState extends State<LighthouseMetadataPage> {
  Future<void> changeNicknameHandler(final String? currentNickname) async {
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
    final Map<String, String?> map = {};
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
          widget._updateSubject
              .add((widget._updateSubject.valueOrNull ?? 0) + 1);
        },
      ));
    }

    for (int i = 0; i < entries.length; i++) {
      body.add(_MetadataInkWell(name: entries[i].key, value: entries[i].value));
    }

    body.add(StreamBuilder<Nickname?>(
      stream: bloc.nicknames
          .watchNicknameForDeviceIds(widget.device.deviceIdentifier.toString()),
      builder: (final BuildContext context,
          final AsyncSnapshot<Nickname?> snapshot) {
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
              title: const Text('Nickname'),
              subtitle: Text(
                'Not set',
                style: theming.bodyMedium?.copyWith(
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
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lighthouse Metadata')),
      body: StreamBuilder<int>(
        stream: widget._updateSubject.stream,
        builder: (final c, final s) => ListView(
          children: _generateBody(),
        ),
      ),
    );
  }
}

class _MetadataInkWell extends StatelessWidget {
  const _MetadataInkWell(
      {required this.name, this.value, this.onTap});

  final String name;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(final BuildContext context) {
    final theming = Theming.of(context);
    return InkWell(
      onLongPress: () async {
        if (value != null) {
          Clipboard.setData(ClipboardData(text: value!));
        }
        if (await Vibration.hasVibrator() ?? false) {
          Vibration.vibrate(duration: 200);
        }
        Toast.show('Copied to clipboard',
            duration: Toast.lengthShort, gravity: Toast.bottom);
      },
      onTap: onTap,
      child: ListTile(
        title: Text(name),
        subtitle: Text(
          value ?? 'Not set',
          style: value != null
              ? null
              : theming.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic, color: theming.disabledColor),
        ),
      ),
    );
  }
}

class _ExtraActionsWidget extends StatelessWidget {
  const _ExtraActionsWidget(this.device, {this.updateList});

  final DeviceWithExtensions device;
  final VoidCallback? updateList;

  @override
  Widget build(final BuildContext context) {
    final extensions = device.deviceExtensions.toList(growable: false);
    final theming = Theming.of(context);

    return SizedBox(
        height: 165.0,
        child: Column(
          children: [
            Flexible(
              child: ListTile(
                title: Text(
                  'Extra actions',
                  style: theming.headlineSmall,
                ),
              ),
            ),
            const Divider(),
            SizedBox(
              height: 85.0,
              child: ListView.builder(
                itemBuilder: (final c, final index) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 60.0,
                          child: StreamBuilder<bool>(
                            stream: extensions[index].enabledStream,
                            initialData: false,
                            builder: (final c, final snapshot) {
                              final enabled = snapshot.data ?? false;
                              return ElevatedButton(
                                onPressed: enabled
                                    ? () async {
                                        await extensions[index].onTap();
                                        if (extensions[index].updateListAfter) {
                                          updateList?.call();
                                        }
                                      }
                                    : null,
                                style: getButtonStyleFromDeviceExtension(
                                    theming, extensions[index]),
                                child: getWidgetFromDeviceExtension(
                                    extensions[index]),
                              );
                            },
                          ),
                        ),
                        Container(
                          height: 5,
                        ),
                        Text(extensions[index].toolTip),
                      ],
                    ),
                  );
                },
                itemCount: extensions.length,
                scrollDirection: Axis.horizontal,
              ),
            ),
            const Divider(
              thickness: 1.5,
            ),
          ],
        ));
  }
}
