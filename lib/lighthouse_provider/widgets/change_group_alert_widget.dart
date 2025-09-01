import 'package:flutter/material.dart';
import 'package:lighthouse_pm/data/database.dart';
import 'package:lighthouse_pm/data/tables/group_table.dart';

import 'change_group_name_alert_widget.dart';

/// Change the group for the items selected.
class ChangeGroupAlertWidget extends StatefulWidget {
  const ChangeGroupAlertWidget({
    required this.groups,
    required this.selectedGroup,
    super.key,
  });

  static const int removeGroupId = -1;
  static const int newGroupId = -2;

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
  /// If the id is [ChangeGroupAlertWidget.removeGroupId] then the user wants
  /// to remove the selected items from a group.
  /// If the id is [ChangeGroupAlertWidget.newGroupId] then the user wants
  /// to create a new group. The name of this group will be stored in [Group.name].
  ///
  /// The [groups] should contain the known groups.
  /// The [selectedGroup] can be the group that is already selected, may be `null`.
  static Future<Group?> showCustomDialog(
    final BuildContext context, {
    required final List<GroupWithEntries> groups,
    required final Group? selectedGroup,
  }) {
    return showDialog(
      context: context,
      builder: (final BuildContext context) {
        return ChangeGroupAlertWidget(
          groups: groups,
          selectedGroup: selectedGroup,
        );
      },
    ).then((final value) {
      if (value is Group) {
        return value;
      }
      return null;
    });
  }
}

/// The content for the
class _ChangeGroupAlertWidgetContent extends State<ChangeGroupAlertWidget> {
  final Group _removeGroup = const Group(
    id: ChangeGroupAlertWidget.removeGroupId,
    name: '',
  );
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
        .map(
          (final e) =>
              DropdownMenuItem(value: e.group, child: Text(e.group.name)),
        )
        .toList();

    final localSelected = selected;
    if (localSelected != null &&
        localSelected.id != _removeGroup.id &&
        widget.groups.indexWhere(
              (final element) => element.group.id == localSelected.id,
            ) <
            0) {
      list.add(
        DropdownMenuItem(value: localSelected, child: Text(localSelected.name)),
      );
    }
    list.add(
      const DropdownMenuItem(
        child: Row(
          children: [
            Icon(Icons.add),
            VerticalDivider(color: Colors.transparent),
            Text('Add item'),
          ],
        ),
      ),
    );

    list.insert(
      0,
      DropdownMenuItem(
        value: _removeGroup,
        child: const Row(
          children: [
            Icon(Icons.clear),
            VerticalDivider(color: Colors.transparent),
            Text('No Group'),
          ],
        ),
      ),
    );

    return list;
  }

  @override
  Widget build(final BuildContext context) {
    return AlertDialog(
      title: const Text('Set the group'),
      content: IntrinsicHeight(
        child: Column(
          children: [
            DropdownButton<Group>(
              value: selected,
              items: _getGroupMenuItems(),
              onChanged: (final newValue) async {
                if (newValue == null) {
                  final name =
                      await ChangeGroupNameAlertWidget.showCustomDialog(
                        context,
                      );
                  if (name != null) {
                    setState(() {
                      selected = Group(
                        id: ChangeGroupAlertWidget.newGroupId,
                        name: name,
                      );
                    });
                  }
                  return;
                }
                setState(() {
                  selected = newValue;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        SimpleDialogOption(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.pop(context, null);
          },
        ),
        SimpleDialogOption(
          child: const Text('Save'),
          onPressed: () {
            Navigator.pop(context, selected);
          },
        ),
      ],
    );
  }
}
