import 'package:fake_back_end/fake_back_end.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lighthouse_pm/bloc.dart';
import 'package:lighthouse_pm/data/database.dart';
import 'package:lighthouse_pm/theming.dart';
import 'package:lighthouse_pm/widgets/content_container_widget.dart';
import 'package:lighthouse_pm/widgets/material/selectable_app_bar.dart';
import 'package:lighthouse_pm/widgets/material/selectable_list_tile.dart';
import 'package:toast/toast.dart';

import '../base_page.dart';

class SettingsViveBaseStationIdsPage extends BasePage {
  const SettingsViveBaseStationIdsPage({final Key? key}) : super(key: key);

  @override
  Widget buildPage(final BuildContext context) {
    return _SettingsViveBaseStationIdsPageContent();
  }
}

class _SettingsViveBaseStationIdsPageContent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SettingsViveBaseStationIdsPageState();
  }
}

class _SettingsViveBaseStationIdsPageState
    extends State<_SettingsViveBaseStationIdsPageContent> {
  final Set<String> selected = {};

  void _selectItem(final String deviceId) {
    setState(() {
      selected.add(deviceId);
    });
  }

  void _deselectItem(final String deviceId) {
    setState(() {
      selected.remove(deviceId);
    });
  }

  bool _isSelected(final String deviceId) {
    return selected.contains(deviceId);
  }

  Future _deleteItem(final String deviceId) {
    return blocWithoutListen.viveBaseStation.deleteId(deviceId);
  }

  @override
  Widget build(final BuildContext context) {
    return StreamBuilder<List<ViveBaseStationId>>(
      stream: bloc.viveBaseStation.getViveBaseStationIdsAsStream(),
      builder: (final BuildContext _,
          final AsyncSnapshot<List<ViveBaseStationId>> snapshot) {
        Widget body = const Center(
          child: CircularProgressIndicator(),
        );
        final data = snapshot.data;
        if (data != null) {
          data.sort((final a, final b) {
            return a.deviceId.compareTo(b.deviceId);
          });
          if (data.isEmpty) {
            body = const _EmptyPage();
          } else {
            body = _DataPage(
              ids: data,
              selecting: selected.isNotEmpty,
              selectItem: _selectItem,
              deselectItem: _deselectItem,
              isSelected: _isSelected,
              deleteItem: _deleteItem,
            );
          }
        }

        final List<Widget> actions = selected.isEmpty
            ? const []
            : [
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: 'Delete selected',
                  onPressed: () async {
                    for (final id in selected) {
                      await blocWithoutListen.viveBaseStation.deleteId(id);
                    }
                    setState(() {
                      selected.clear();
                    });
                    Toast.show('Ids have been removed!');
                  },
                )
              ];

        return Scaffold(
            appBar: createSelectableAppBar(context,
                numberOfSelections: selected.length,
                title: const Text('Vive Base station ids'),
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

class _DataPage extends StatelessWidget {
  const _DataPage(
      {final Key? key,
      required this.selecting,
      required this.ids,
      required this.selectItem,
      required this.isSelected,
      required this.deselectItem,
      required this.deleteItem})
      : super(key: key);

  final bool selecting;
  final List<ViveBaseStationId> ids;
  final _SelectItem selectItem;
  final _IsSelected isSelected;
  final _DeselectItem deselectItem;
  final _DeleteItem deleteItem;

  @override
  Widget build(final BuildContext context) {
    return ContentContainerListView.builder(
      itemBuilder: (final context, final index) {
        final id = ids[index];
        final selected = isSelected(id.deviceId);
        return Column(
          children: [
            createSelectableListTile(context,
                selected: selected,
                selecting: selecting,
                title: Text(id.baseStationId
                    .toRadixString(16)
                    .padLeft(8, '0')
                    .toUpperCase()),
                subtitle: Text(id.deviceId), onSelect: (final newState) {
              if (newState) {
                selectItem(id.deviceId);
              } else {
                deselectItem(id.deviceId);
              }
            }),
            const Divider(
              height: 0,
            ),
          ],
        );
      },
      itemCount: ids.length,
    );
  }
}

class _EmptyPage extends StatefulWidget {
  const _EmptyPage({final Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _EmptyState();
  }
}

class _EmptyState extends State<_EmptyPage> {
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
                Toast.show(
                    'Just ${_tapTop - tapCounter} left until a fake ids are created');
              }
              if (tapCounter == _tapTop) {
                blocWithoutListen.viveBaseStation.insertId(
                    FakeDeviceIdentifier.generateDeviceIdentifier(0xFFFFFFFF)
                        .toString(),
                    0xFFFFFFFF);
                blocWithoutListen.viveBaseStation.insertId(
                    FakeDeviceIdentifier.generateDeviceIdentifier(0xFFFFFFFE)
                        .toString(),
                    0xFFFFFFFE);
                blocWithoutListen.viveBaseStation.insertId(
                    FakeDeviceIdentifier.generateDeviceIdentifier(0xFFFFFFFD)
                        .toString(),
                    0xFFFFFFFD);
                blocWithoutListen.viveBaseStation.insertId(
                    FakeDeviceIdentifier.generateDeviceIdentifier(0xFFFFFFFC)
                        .toString(),
                    0xFFFFFFFC);
                Toast.show('Fake ids created!', duration: Toast.lengthShort);
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
            'No ids set (yet).',
            style: theming.headline6,
          )
        ],
      ),
    );
  }
}
