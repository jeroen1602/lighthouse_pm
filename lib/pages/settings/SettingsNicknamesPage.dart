import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lighthouse_pm/Theming.dart';
import 'package:lighthouse_pm/bloc.dart';
import 'package:lighthouse_pm/data/Database.dart';
import 'package:lighthouse_pm/data/tables/NicknameTable.dart';
import 'package:lighthouse_pm/lighthouseProvider/backEnd/fake/FakeDeviceIdentifier.dart';
import 'package:lighthouse_pm/lighthouseProvider/ble/DeviceIdentifier.dart';
import 'package:lighthouse_pm/widgets/ContentContainerWidget.dart';
import 'package:lighthouse_pm/widgets/NicknameAlertWidget.dart';
import 'package:toast/toast.dart';

import '../BasePage.dart';

class SettingsNicknamesPage extends BasePage {
  @override
  Widget buildPage(BuildContext context) {
    return _SettingsNicknamesPageContent();
  }
}

class _SettingsNicknamesPageContent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NicknamesPageState();
  }
}

class _NicknamesPageState extends State<_SettingsNicknamesPageContent> {
  final Set<LHDeviceIdentifier> selected = Set();

  void _selectItem(String deviceId) {
    setState(() {
      this.selected.add(LHDeviceIdentifier(deviceId));
    });
  }

  void _deselectItem(String deviceId) {
    setState(() {
      this.selected.remove(LHDeviceIdentifier(deviceId));
    });
  }

  bool _isSelected(String deviceId) {
    return this.selected.contains(LHDeviceIdentifier(deviceId));
  }

  Future _deleteItem(String deviceId) {
    return blocWithoutListen.nicknames.deleteNicknames([deviceId]);
  }

  Future _updateItem(Nickname nickname) {
    return blocWithoutListen.nicknames.insertNickname(nickname);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<NicknamesLastSeenJoin>>(
      stream: bloc.nicknames.watchSavedNicknamesWithLastSeen(),
      builder: (BuildContext _,
          AsyncSnapshot<List<NicknamesLastSeenJoin>> snapshot) {
        Widget body = const Center(
          child: CircularProgressIndicator(),
        );
        final data = snapshot.data;
        if (data != null) {
          data.sort((a, b) {
            return a.deviceId.compareTo(b.deviceId);
          });
          if (data.isEmpty) {
            body = const _EmptyNicknamePage();
          } else {
            body = _DataNicknamePage(
              nicknames: data,
              selecting: selected.isNotEmpty,
              selectItem: _selectItem,
              deselectItem: _deselectItem,
              isSelected: _isSelected,
              deleteItem: _deleteItem,
              updateItem: _updateItem,
            );
          }
        }

        if (snapshot.hasError) {
          debugPrint(snapshot.error.toString());
          body = Center(
            child: Container(
              color: Colors.red,
              child: ListTile(
                title: const Text('Error'),
                subtitle: Text(snapshot.error.toString()),
              ),
            ),
          );
        }

        final theming = Theming.of(context);

        final Color? scaffoldColor =
            selected.isNotEmpty ? theming.selectedRowColor : null;
        final List<Widget> actions = selected.isEmpty
            ? const []
            : [
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: 'Delete selected',
                  onPressed: () async {
                    await blocWithoutListen.nicknames
                        .deleteNicknames(selected.map((e) => e.id).toList());
                    setState(() {
                      selected.clear();
                    });
                    Toast.show('Nicknames have been removed', context);
                  },
                )
              ];
        final Widget? leading = selected.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Cancel selection',
                onPressed: () {
                  setState(() {
                    this.selected.clear();
                  });
                },
              );

        return Scaffold(
            appBar: AppBar(
              title: const Text('Nicknames'),
              backgroundColor: scaffoldColor,
              actions: actions,
              leading: leading,
            ),
            body: body);
      },
    );
  }
}

typedef void _SelectItem(String deviceId);
typedef bool _IsSelected(String deviceId);
typedef void _DeselectItem(String deviceId);
typedef Future _DeleteItem(String deviceId);
typedef Future _UpdateItem(Nickname nickname);

class _DataNicknamePage extends StatelessWidget {
  _DataNicknamePage(
      {Key? key,
      required this.selecting,
      required this.nicknames,
      required this.selectItem,
      required this.isSelected,
      required this.deselectItem,
      required this.deleteItem,
      required this.updateItem})
      : super(key: key);

  final bool selecting;
  final List<NicknamesLastSeenJoin> nicknames;
  final _SelectItem selectItem;
  final _IsSelected isSelected;
  final _DeselectItem deselectItem;
  final _DeleteItem deleteItem;
  final _UpdateItem updateItem;

  Future _changeNickname(
      BuildContext context, NicknamesLastSeenJoin oldNickname) async {
    final newNickname = await NicknameAlertWidget.showCustomDialog(context,
        deviceId: oldNickname.deviceId, nickname: oldNickname.nickname);
    if (newNickname != null) {
      if (newNickname.nickname == null) {
        await deleteItem(newNickname.deviceId);
      } else {
        await updateItem(newNickname.toNickname()!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ContentContainerListView.builder(
      itemBuilder: (context, index) {
        final item = nicknames[index];
        final selected = isSelected(item.deviceId);
        final lastSeen = item.lastSeen;
        final theming = Theming.of(context);

        return Column(
          children: [
            Container(
              color: selected ? theming.selectedRowColor : Colors.transparent,
              child: ListTile(
                title: Text(item.nickname),
                subtitle: Text(
                    '${item.deviceId}${lastSeen != null ? ' | last seen: ' + DateFormat.yMd(Intl.systemLocale).format(lastSeen) : ''}'),
                onLongPress: () {
                  if (!selecting) {
                    selectItem(item.deviceId);
                  } else {
                    _changeNickname(context, item);
                  }
                },
                onTap: () {
                  if (selecting) {
                    if (selected) {
                      deselectItem(item.deviceId);
                    } else {
                      selectItem(item.deviceId);
                    }
                  } else {
                    _changeNickname(context, item);
                  }
                },
              ),
            ),
            const Divider(),
          ],
        );
      },
      itemCount: nicknames.length,
    );
  }
}

class _EmptyNicknamePage extends StatefulWidget {
  const _EmptyNicknamePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _EmptyNicknameState();
  }
}

class _EmptyNicknameState extends State<_EmptyNicknamePage> {
  static const int _TAP_TOP = 10;
  int tapCounter = 0;

  @override
  Widget build(BuildContext context) {
    final theming = Theming.of(context);

    final Widget blockIcon = kReleaseMode
        ? const Icon(Icons.block, size: 120.0)
        : GestureDetector(
            onTap: () {
              if (tapCounter < _TAP_TOP) {
                tapCounter++;
              }
              if (tapCounter < _TAP_TOP && tapCounter > _TAP_TOP - 3) {
                Toast.show(
                    'Just ${_TAP_TOP - tapCounter} left until a fake nicknames are created',
                    context);
              }
              if (tapCounter == _TAP_TOP) {
                blocWithoutListen.nicknames.insertNickname(Nickname(
                    deviceId: FakeDeviceIdentifier.generateDeviceIdentifier(
                            0xFFFFFFFF)
                        .toString(),
                    nickname: "This is a test nickname1"));
                blocWithoutListen.nicknames.insertNickname(Nickname(
                    deviceId: FakeDeviceIdentifier.generateDeviceIdentifier(
                            0xFFFFFFFE)
                        .toString(),
                    nickname: "This is a test nickname2"));
                blocWithoutListen.nicknames.insertNickname(Nickname(
                    deviceId: FakeDeviceIdentifier.generateDeviceIdentifier(
                            0xFFFFFFFD)
                        .toString(),
                    nickname: "This is a test nickname3"));
                blocWithoutListen.nicknames.insertNickname(Nickname(
                    deviceId: FakeDeviceIdentifier.generateDeviceIdentifier(
                            0xFFFFFFFC)
                        .toString(),
                    nickname: "This is a test nickname4"));
                Toast.show('Fake nickname created!', context,
                    duration: Toast.lengthShort);
                tapCounter++;
              }
            },
            child: const Icon(Icons.block, size: 120.0),
          );
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          blockIcon,
          Text(
            'No nicknames given (yet).',
            style: theming.headline6,
          )
        ],
      ),
    );
  }
}
