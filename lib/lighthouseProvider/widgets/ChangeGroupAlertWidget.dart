import 'package:flutter/material.dart';
import 'package:lighthouse_pm/data/Database.dart';
import 'package:lighthouse_pm/data/tables/GroupTable.dart';

import 'ChangeGroupNameAlertWidget.dart';

/// Change the group for the items selected.
class ChangeGroupAlertWidget extends StatefulWidget {
  ChangeGroupAlertWidget(
      {required this.groups, required this.selectedGroup, Key? key})
      : super(key: key);

  static const int REMOVE_GROUP_ID = -1;
  static const int NEW_GROUP_ID = -2;

  final List<GroupWithEntries> groups;
  final Group? selectedGroup;

  @override
  State<StatefulWidget> createState() {
    return _ChangeGroupAlertWidgetContent();
  }

  ///
  /// Show this dialog.
  /// Will show a dialog where the user selects the group they want the selected
  /// items to have.
  /// Will return the [Group] if the user choose to select save.
  /// The group id may be negative, in that case the user selected a special case
  /// If the id is [ChangeGroupAlertWidget.REMOVE_GROUP_ID] then the user wants
  /// to remove the selected items from a group.
  /// If the id is [ChangeGroupAlertWidget.NEW_GROUP_ID] then the user wants
  /// to create a new group. The name of this group will be stored in [Group.name].
  ///
  /// The [groups] should contain the known groups.
  /// The [selectedGroup] can be the group that is already selected, may be `null`.
  static Future<Group?> showCustomDialog(BuildContext context,
      {required List<GroupWithEntries> groups, required Group? selectedGroup}) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return ChangeGroupAlertWidget(
              groups: groups, selectedGroup: selectedGroup);
        }).then((value) {
      if (value is Group) {
        return value;
      }
      return null;
    });
  }
}

/// The content for the
class _ChangeGroupAlertWidgetContent extends State<ChangeGroupAlertWidget> {
  final Group _removeGroup =
      Group(id: ChangeGroupAlertWidget.REMOVE_GROUP_ID, name: '');
  Group? selected;

  @override
  void initState() {
    if (widget.selectedGroup == null) {
      selected = _removeGroup;
    } else {
      selected = widget.selectedGroup;
    }
    super.initState();
  }

  List<DropdownMenuItem<Group>> _getGroupMenuItems() {
    final list = widget.groups
        .map((e) => DropdownMenuItem(
              child: Text(e.group.name),
              value: e.group,
            ))
        .toList();

    final localSelected = selected;
    if (localSelected != null &&
        localSelected.id != _removeGroup.id &&
        widget.groups
                .indexWhere((element) => element.group.id == localSelected.id) <
            0) {
      list.add(DropdownMenuItem(
          child: Text(localSelected.name), value: localSelected));
    }
    list.add(DropdownMenuItem(
        child: Row(
      children: [
        Icon(Icons.add),
        VerticalDivider(
          color: Colors.transparent,
        ),
        Text('Add item')
      ],
    )));

    list.insert(
        0,
        DropdownMenuItem(
            value: this._removeGroup,
            child: Row(
              children: [
                Icon(Icons.clear),
                VerticalDivider(
                  color: Colors.transparent,
                ),
                Text('No Group')
              ],
            )));

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Set the group'),
      content: IntrinsicHeight(
        child: Column(
          children: [
            DropdownButton<Group>(
              value: selected,
              items: _getGroupMenuItems(),
              onChanged: (newValue) async {
                if (newValue == null) {
                  final name =
                      await ChangeGroupNameAlertWidget.showCustomDialog(
                          context);
                  if (name != null) {
                    setState(() {
                      selected = Group(
                          id: ChangeGroupAlertWidget.NEW_GROUP_ID, name: name);
                    });
                  }
                  return;
                }
                setState(() {
                  selected = newValue;
                });
              },
            )
          ],
        ),
      ),
      actions: [
        SimpleDialogOption(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.pop(context, null);
          },
        ),
        SimpleDialogOption(
          child: Text('Save'),
          onPressed: () {
            Navigator.pop(context, selected);
          },
        )
      ],
    );
  }
}
