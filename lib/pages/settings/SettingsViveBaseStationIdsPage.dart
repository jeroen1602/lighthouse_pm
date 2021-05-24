import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lighthouse_pm/bloc.dart';
import 'package:lighthouse_pm/data/Database.dart';
import 'package:lighthouse_pm/widgets/ContentContainerWidget.dart';
import 'package:toast/toast.dart';

import '../BasePage.dart';

class SettingsViveBaseStationIdsPage extends BasePage {
  @override
  Widget buildPage(BuildContext context) {
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
  final Set<String> selected = Set();

  void _selectItem(String deviceId) {
    setState(() {
      this.selected.add(deviceId);
    });
  }

  void _deselectItem(String deviceId) {
    setState(() {
      this.selected.remove(deviceId);
    });
  }

  bool _isSelected(String deviceId) {
    return this.selected.contains(deviceId);
  }

  Future _deleteItem(String deviceId) {
    return blocWithoutListen.viveBaseStation.deleteId(deviceId);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ViveBaseStationId>>(
      stream: bloc.viveBaseStation.getViveBaseStationIdsAsStream(),
      builder:
          (BuildContext _, AsyncSnapshot<List<ViveBaseStationId>> snapshot) {
        Widget body = Center(
          child: CircularProgressIndicator(),
        );
        final data = snapshot.data;
        if (data != null) {
          data.sort((a, b) {
            return a.deviceId.compareTo(b.deviceId);
          });
          if (data.isEmpty) {
            body = _EmptyPage();
          } else {
            body = ContentContainerWidget(builder: (context) {
              return _DataPage(
                ids: data,
                selecting: selected.isNotEmpty,
                selectItem: _selectItem,
                deselectItem: _deselectItem,
                isSelected: _isSelected,
                deleteItem: _deleteItem,
              );
            });
          }
        }

        final Color? scaffoldColor =
            selected.isNotEmpty ? Theme.of(context).selectedRowColor : null;
        final List<Widget> actions = selected.isEmpty
            ? const []
            : [
                IconButton(
                  icon: Icon(Icons.delete),
                  tooltip: 'Delete selected',
                  onPressed: () async {
                    for (final id in selected) {
                      await blocWithoutListen.viveBaseStation.deleteId(id);
                    }
                    setState(() {
                      selected.clear();
                    });
                    Toast.show('Ids have been removed!', context);
                  },
                )
              ];
        final Widget? leading = selected.isEmpty
            ? null
            : IconButton(
                tooltip: 'Cancel selection',
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    this.selected.clear();
                  });
                },
              );

        return Scaffold(
            appBar: AppBar(
              title: Text('Vive Base station ids'),
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

class _DataPage extends StatelessWidget {
  _DataPage(
      {Key? key,
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
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        final id = ids[index];
        final selected = isSelected(id.deviceId);
        return Column(
          children: [
            Container(
              color: selected
                  ? Theme.of(context).selectedRowColor
                  : Colors.transparent,
              child: ListTile(
                title: Text(
                    '${id.baseStationId.toRadixString(16).padLeft(8, '0').toUpperCase()}'),
                subtitle: Text(id.deviceId),
                onLongPress: () {
                  selectItem(id.deviceId);
                },
                onTap: () {
                  if (selecting) {
                    if (selected) {
                      deselectItem(id.deviceId);
                    } else {
                      selectItem(id.deviceId);
                    }
                  }
                },
              ),
            ),
            Divider()
          ],
        );
      },
      itemCount: ids.length,
    );
  }
}

class _EmptyPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _EmptyState();
  }
}

class _EmptyState extends State<_EmptyPage> {
  static const int _TAP_TOP = 10;
  int tapCounter = 0;

  @override
  Widget build(BuildContext context) {
    final Widget blockIcon = kReleaseMode
        ? Icon(Icons.block, size: 120.0)
        : GestureDetector(
            onTap: () {
              if (tapCounter < _TAP_TOP) {
                tapCounter++;
              }
              if (tapCounter < _TAP_TOP && tapCounter > _TAP_TOP - 3) {
                Toast.show(
                    'Just ${_TAP_TOP - tapCounter} left until a fake ids are created',
                    context);
              }
              if (tapCounter == _TAP_TOP) {
                blocWithoutListen.viveBaseStation
                    .insertId("FF:FF:FF:FF:FF:FF", 0xFFFFFFFF);
                blocWithoutListen.viveBaseStation
                    .insertId("FF:FF:FF:FF:FF:FE", 0xFFFFFFFE);
                blocWithoutListen.viveBaseStation
                    .insertId("FF:FF:FF:FF:FF:FD", 0xFFFFFFFD);
                blocWithoutListen.viveBaseStation
                    .insertId("FF:FF:FF:FF:FF:FC", 0xFFFFFFFC);
                Toast.show('Fake ids created!', context,
                    duration: Toast.lengthShort);
                tapCounter++;
              }
            },
            child: Icon(Icons.block, size: 120.0),
          );
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          blockIcon,
          Text(
            'No ids set (yet).',
            style: Theme.of(context).textTheme.headline6,
          )
        ],
      ),
    );
  }
}
