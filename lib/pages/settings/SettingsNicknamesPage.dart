import 'package:flutter/material.dart';
import 'package:lighthouse_pm/bloc.dart';
import 'package:lighthouse_pm/data/Database.dart';
import 'package:lighthouse_pm/lighthouseProvider/ble/DeviceIdentifier.dart';
import 'package:lighthouse_pm/widgets/NicknameAlertWidget.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class SettingsNicknamesPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NicknamesPage();
  }
}

class _NicknamesPage extends State<SettingsNicknamesPage> {
  final Set<LHDeviceIdentifier> selected = Set();

  LighthousePMBloc get bloc => Provider.of<LighthousePMBloc>(context);

  LighthousePMBloc get blocWithoutListen =>
      Provider.of<LighthousePMBloc>(context, listen: false);

  void _selectItem(String macAddress) {
    setState(() {
      this.selected.add(LHDeviceIdentifier(macAddress));
    });
  }

  void _deselectItem(String macAddress) {
    setState(() {
      this.selected.remove(LHDeviceIdentifier(macAddress));
    });
  }

  bool _isSelected(String macAddress) {
    return this.selected.contains(LHDeviceIdentifier(macAddress));
  }

  Future _deleteItem(String macAddress) {
    return blocWithoutListen.deleteNicknames([macAddress]);
  }

  Future _updateItem(Nickname nickname) {
    return blocWithoutListen.insertNewNickname(nickname);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Nickname>>(
      stream: bloc.watchSavedNicknames,
      builder: (BuildContext _, AsyncSnapshot<List<Nickname>> snapshot) {
        Widget body = Center(
          child: CircularProgressIndicator(),
        );
        if (snapshot.hasData) {
          final data = snapshot.data;
          data.sort((a, b) {
            return a.macAddress.compareTo(b.macAddress);
          });
          if (data.isEmpty) {
            body = _EmptyNicknamePage();
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

        final Color scaffoldColor = selected.isNotEmpty ? Colors.orange : null;
        final List<Widget> actions = selected.isEmpty
            ? const []
            : [
                IconButton(
                  icon: Icon(Icons.delete),
                  tooltip: 'Delete selected',
                  onPressed: () async {
                    await blocWithoutListen
                        .deleteNicknames(selected.map((e) => e.id).toList());
                    setState(() {
                      selected.clear();
                    });
                    Toast.show('Nicknames have been removed!', context);
                  },
                )
              ];
        final Widget leading = selected.isEmpty
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
              title: Text('Nicknames'),
              backgroundColor: scaffoldColor,
              actions: actions,
              leading: leading,
            ),
            body: body);
      },
    );
  }
}

typedef void _SelectItem(String macAddress);
typedef bool _IsSelected(String macAddress);
typedef void _DeselectItem(String macAddress);
typedef Future _DeleteItem(String macAddress);
typedef Future _UpdateItem(Nickname nickname);

class _DataNicknamePage extends StatelessWidget {
  _DataNicknamePage(
      {Key key,
      this.selecting,
      this.nicknames,
      this.selectItem,
      this.isSelected,
      this.deselectItem,
      this.deleteItem,
      this.updateItem})
      : super(key: key);

  final bool selecting;
  final List<Nickname> nicknames;
  final _SelectItem selectItem;
  final _IsSelected isSelected;
  final _DeselectItem deselectItem;
  final _DeleteItem deleteItem;
  final _UpdateItem updateItem;

  Future _changeNickname(BuildContext context, Nickname oldNickname) async {
    final newNickname = await NicknameAlertWidget.showCustomDialog(context,
        macAddress: oldNickname.macAddress, nickname: oldNickname.nickname);
    if (newNickname != null) {
      if (newNickname.nickname == null) {
        await deleteItem(newNickname.macAddress);
      } else {
        await updateItem(newNickname);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        final item = nicknames[index];
        final selected = isSelected(item.macAddress);
        return Column(
          children: [
            Container(
                color: selected ? Colors.black12 : Colors.transparent,
                child: InkWell(
                  onLongPress: () {
                    if (!selecting) {
                      selectItem(item.macAddress);
                    } else {
                      _changeNickname(context, item);
                    }
                  },
                  onTap: () {
                    if (selecting) {
                      if (selected) {
                        deselectItem(item.macAddress);
                      } else {
                        selectItem(item.macAddress);
                      }
                    } else {
                      _changeNickname(context, item);
                    }
                  },
                  child: ListTile(
                    title: Text(item.nickname),
                    subtitle: Text(item.macAddress),
                  ),
                )),
            Divider()
          ],
        );
      },
      itemCount: nicknames.length,
    );
  }
}

class _EmptyNicknamePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _EmptyNicknameState();
  }
}

class _EmptyNicknameState extends State<_EmptyNicknamePage> {
  static const int _TAP_TOP = 10;

  LighthousePMBloc get bloc =>
      Provider.of<LighthousePMBloc>(context, listen: false);
  int tapCounter = 0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              if (tapCounter < _TAP_TOP) {
                tapCounter++;
              }
              if (tapCounter < _TAP_TOP && tapCounter > _TAP_TOP - 3) {
                Toast.show(
                    'Just ${_TAP_TOP - tapCounter} left until a fake nickname is created',
                    context);
              }
              if (tapCounter == _TAP_TOP) {
                bloc.insertNewNickname(Nickname(
                    macAddress: "FF:FF:FF:FF:FF:FF",
                    nickname: "This is a test nickname1"));
                bloc.insertNewNickname(Nickname(
                    macAddress: "FF:FF:FF:FF:FF:FE",
                    nickname: "This is a test nickname2"));
                bloc.insertNewNickname(Nickname(
                    macAddress: "FF:FF:FF:FF:FF:FD",
                    nickname: "This is a test nickname3"));
                bloc.insertNewNickname(Nickname(
                    macAddress: "FF:FF:FF:FF:FF:FC",
                    nickname: "This is a test nickname4"));
                Toast.show('Fake nickname created!', context,
                    duration: Toast.LENGTH_LONG);
                tapCounter++;
              }
            },
            child: Icon(Icons.block, size: 120.0),
          ),
          Text(
            'No nicknames given (yet).',
            style: Theme.of(context).textTheme.headline6,
          )
        ],
      ),
    );
  }
}
