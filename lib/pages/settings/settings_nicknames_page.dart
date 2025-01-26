import 'package:fake_back_end/fake_back_end.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lighthouse_pm/bloc.dart';
import 'package:lighthouse_pm/data/database.dart';
import 'package:lighthouse_pm/data/tables/nickname_table.dart';
import 'package:lighthouse_pm/theming.dart';
import 'package:lighthouse_pm/widgets/content_container_widget.dart';
import 'package:lighthouse_pm/widgets/material/selectable_app_bar.dart';
import 'package:lighthouse_pm/widgets/material/selectable_list_tile.dart';
import 'package:lighthouse_pm/widgets/nickname_alert_widget.dart';
import 'package:lighthouse_provider/lighthouse_provider.dart';
import 'package:toast/toast.dart';

import '../base_page.dart';

class SettingsNicknamesPage extends BasePage {
  const SettingsNicknamesPage({super.key});

  @override
  Widget buildPage(final BuildContext context) {
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
  final Set<LHDeviceIdentifier> selected = {};

  void _selectItem(final String deviceId) {
    setState(() {
      selected.add(LHDeviceIdentifier(deviceId));
    });
  }

  void _deselectItem(final String deviceId) {
    setState(() {
      selected.remove(LHDeviceIdentifier(deviceId));
    });
  }

  bool _isSelected(final String deviceId) {
    return selected.contains(LHDeviceIdentifier(deviceId));
  }

  Future _deleteItem(final String deviceId) {
    return blocWithoutListen.nicknames.deleteNicknames([deviceId]);
  }

  Future _updateItem(final Nickname nickname) {
    return blocWithoutListen.nicknames.insertNickname(nickname);
  }

  @override
  Widget build(final BuildContext context) {
    return StreamBuilder<List<NicknamesLastSeenJoin>>(
      stream: bloc.nicknames.watchSavedNicknamesWithLastSeen(),
      builder: (final BuildContext _,
          final AsyncSnapshot<List<NicknamesLastSeenJoin>> snapshot) {
        Widget body = const Center(
          child: CircularProgressIndicator(),
        );
        final data = snapshot.data;
        if (data != null) {
          data.sort((final a, final b) {
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

        final List<Widget> actions = selected.isEmpty
            ? const []
            : [
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: 'Delete selected',
                  onPressed: () async {
                    await blocWithoutListen.nicknames.deleteNicknames(
                        selected.map((final e) => e.id).toList());
                    setState(() {
                      selected.clear();
                    });
                    if (context.mounted) {
                      ToastContext().init(context);
                      Toast.show('Nicknames have been removed');
                    }
                  },
                )
              ];

        return Scaffold(
            appBar: createSelectableAppBar(context,
                numberOfSelections: selected.length,
                title: const Text('Nicknames'),
                actions: actions, onClearSelection: () {
              setState(() {
                selected.clear();
              });
            }),
            body: body);
      },
    );
  }
}

typedef _SelectItem = void Function(String deviceId);
typedef _IsSelected = bool Function(String deviceId);
typedef _DeselectItem = void Function(String deviceId);
typedef _DeleteItem = Future Function(String deviceId);
typedef _UpdateItem = Future Function(Nickname nickname);

class _DataNicknamePage extends StatelessWidget {
  const _DataNicknamePage(
      {required this.selecting,
      required this.nicknames,
      required this.selectItem,
      required this.isSelected,
      required this.deselectItem,
      required this.deleteItem,
      required this.updateItem});

  final bool selecting;
  final List<NicknamesLastSeenJoin> nicknames;
  final _SelectItem selectItem;
  final _IsSelected isSelected;
  final _DeselectItem deselectItem;
  final _DeleteItem deleteItem;
  final _UpdateItem updateItem;

  Future _changeNickname(final BuildContext context,
      final NicknamesLastSeenJoin oldNickname) async {
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
  Widget build(final BuildContext context) {
    return ContentContainerListView.builder(
      itemBuilder: (final context, final index) {
        final item = nicknames[index];
        final selected = isSelected(item.deviceId);
        final lastSeen = item.lastSeen;

        return Column(
          children: [
            createSelectableListTile(context,
                selected: selected,
                selecting: selecting,
                title: Text(item.nickname),
                subtitle: Text(
                    '${item.deviceId}${lastSeen != null ? ' | last seen: ${DateFormat.yMd(Intl.systemLocale).format(lastSeen)}' : ''}'),
                onTap: () {
              _changeNickname(context, item);
            }, onSelect: (final newState) {
              if (newState) {
                selectItem(item.deviceId);
              } else {
                deselectItem(item.deviceId);
              }
            }),
            const Divider(
              height: 0,
            ),
          ],
        );
      },
      itemCount: nicknames.length,
    );
  }
}

class _EmptyNicknamePage extends StatefulWidget {
  const _EmptyNicknamePage();

  @override
  State<StatefulWidget> createState() {
    return _EmptyNicknameState();
  }
}

class _EmptyNicknameState extends State<_EmptyNicknamePage> {
  static const int _tapTop = 10;
  int tapCounter = 0;

  @override
  Widget build(final BuildContext context) {
    final theming = Theming.of(context);

    final Widget blockIcon = kReleaseMode
        ? const Icon(Icons.block, size: 120.0)
        : GestureDetector(
            onTap: () {
              if (tapCounter < _tapTop) {
                tapCounter++;
              }
              if (tapCounter < _tapTop && tapCounter > _tapTop - 3) {
                if (context.mounted) {
                  ToastContext().init(context);
                  Toast.show(
                      'Just ${_tapTop - tapCounter} left until a fake nicknames are created');
                }
              }
              if (tapCounter == _tapTop) {
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
                if (context.mounted) {
                  ToastContext().init(context);
                  Toast.show('Fake nickname created!',
                      duration: Toast.lengthShort);
                }
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
            style: theming.titleLarge,
          )
        ],
      ),
    );
  }
}
