import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/data/database.dart';
import 'package:lighthouse_pm/data/tables/group_table.dart';
import 'package:lighthouse_pm/lighthouse_provider/widgets/change_group_alert_widget.dart';

import '../../helpers/widget_helpers.dart';

void main() {
  testWidgets("Should create a group alert widget",
      (final WidgetTester tester) async {
    await tester.pumpWidget(buildTestAppForWidgets((final context) {
      ChangeGroupAlertWidget.showCustomDialog(context,
          groups: [], selectedGroup: null);
    }));

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text("Set the group"), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets("Should show groups in group alert widget",
      (final WidgetTester tester) async {
    final groups = <GroupWithEntries>[
      GroupWithEntries(const Group(id: 1, name: "Test group 1"), []),
      GroupWithEntries(const Group(id: 2, name: "Test group 2"), []),
      GroupWithEntries(const Group(id: 3, name: "Test group 3"), []),
      GroupWithEntries(const Group(id: 4, name: "Test group 4"), []),
    ];

    await tester.pumpWidget(buildTestAppForWidgets((final context) {
      ChangeGroupAlertWidget.showCustomDialog(context,
          groups: groups, selectedGroup: null);
    }));

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text("Set the group"), findsOneWidget);
    expect(
        find.descendant(
            of: find.byType(Dialog),
            matching: find.byType(typeOf<DropdownButton<Group>>())),
        findsOneWidget);

    await tester.tap(find.descendant(
        of: find.byType(Dialog),
        matching: find.byType(typeOf<DropdownButton<Group>>())));
    await tester.pumpAndSettle();

    expect(find.text("Test group 1"), findsNWidgets(2));
    expect(find.text("Test group 2"), findsNWidgets(2));
    expect(find.text("Test group 3"), findsNWidgets(2));
    expect(find.text("Test group 4"), findsNWidgets(2));
    expect(find.text("Add item"), findsNWidgets(2));
    expect(find.text("No Group"), findsNWidgets(2));

    await tester.scrollUntilVisible(find.text("No Group").last, 1.0);
    await tester.tap(find
        .ancestor(
            of: find.text("No Group"),
            matching: find.byType(typeOf<DropdownMenuItem<Group>>()))
        .last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets("Should show selected group in group alert widget",
      (final WidgetTester tester) async {
    final groups = <GroupWithEntries>[
      GroupWithEntries(const Group(id: 1, name: "Test group 1"), []),
      GroupWithEntries(const Group(id: 2, name: "Test group 2"), []),
      GroupWithEntries(const Group(id: 3, name: "Test group 3"), []),
      GroupWithEntries(const Group(id: 4, name: "Test group 4"), []),
    ];

    await tester.pumpWidget(buildTestAppForWidgets((final context) {
      ChangeGroupAlertWidget.showCustomDialog(context,
          groups: groups, selectedGroup: groups[1].group);
    }));

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text("Set the group"), findsOneWidget);
    expect(
        find.descendant(
            of: find.byType(Dialog),
            matching: find.byType(typeOf<DropdownButton<Group>>())),
        findsOneWidget);

    final dropDown = tester.widget<DropdownButton<Group>>(find.descendant(
        of: find.byType(Dialog),
        matching: find.byType(typeOf<DropdownButton<Group>>())));

    expect(dropDown.value, groups[1].group);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets("Should create a new group in group alert widget",
      (final WidgetTester tester) async {
    final groups = <GroupWithEntries>[
      GroupWithEntries(const Group(id: 1, name: "Test group 1"), []),
      GroupWithEntries(const Group(id: 2, name: "Test group 2"), []),
      GroupWithEntries(const Group(id: 3, name: "Test group 3"), []),
      GroupWithEntries(const Group(id: 4, name: "Test group 4"), []),
    ];

    Future<Group?>? future;
    await tester.pumpWidget(buildTestAppForWidgets((final context) {
      future = ChangeGroupAlertWidget.showCustomDialog(context,
          groups: groups, selectedGroup: groups[1].group);
    }));

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    expect(future, isNotNull);
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text("Set the group"), findsOneWidget);
    expect(
        find.descendant(
            of: find.byType(Dialog),
            matching: find.byType(typeOf<DropdownButton<Group>>())),
        findsOneWidget);

    await scrollIntoViewAndTap(tester, "Add item", openSelector: true);

    expect(find.byType(Dialog), findsNWidgets(2));

    // Set the name.
    await tester.enterText(find.byType(TextField), "New group");
    await tester.pumpAndSettle();

    await tester.tap(find.text("Set"));
    await tester.pumpAndSettle();

    final dropDown = tester.widget<DropdownButton<Group>>(find.descendant(
        of: find.byType(Dialog),
        matching: find.byType(typeOf<DropdownButton<Group>>())));

    expect(dropDown.value, isNotNull);
    expect(dropDown.value!.id, ChangeGroupAlertWidget.newGroupId);
    expect(dropDown.value!.name, "New group");

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
    final value = await future;
    expect(value, isNotNull);
    expect(value!.id, ChangeGroupAlertWidget.newGroupId);
    expect(value.name, "New group");
  });

  testWidgets("Should select no group in group alert widget",
      (final WidgetTester tester) async {
    final groups = <GroupWithEntries>[
      GroupWithEntries(const Group(id: 1, name: "Test group 1"), []),
      GroupWithEntries(const Group(id: 2, name: "Test group 2"), []),
      GroupWithEntries(const Group(id: 3, name: "Test group 3"), []),
      GroupWithEntries(const Group(id: 4, name: "Test group 4"), []),
    ];

    Future<Group?>? future;
    await tester.pumpWidget(buildTestAppForWidgets((final context) {
      future = ChangeGroupAlertWidget.showCustomDialog(context,
          groups: groups, selectedGroup: groups[1].group);
    }));

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    expect(future, isNotNull);
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text("Set the group"), findsOneWidget);
    expect(
        find.descendant(
            of: find.byType(Dialog),
            matching: find.byType(typeOf<DropdownButton<Group>>())),
        findsOneWidget);

    await scrollIntoViewAndTap(tester, "No Group", openSelector: true);

    final dropDown = tester.widget<DropdownButton<Group>>(find.descendant(
        of: find.byType(Dialog),
        matching: find.byType(typeOf<DropdownButton<Group>>())));

    expect(dropDown.value, isNotNull);
    expect(dropDown.value!.id, ChangeGroupAlertWidget.removeGroupId);
    expect(dropDown.value!.name, "");

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
    final value = await future;
    expect(value, isNotNull);
    expect(value!.id, ChangeGroupAlertWidget.removeGroupId);
    expect(value.name, "");
  });

  testWidgets("Should select a group in group alert widget",
      (final WidgetTester tester) async {
    final groups = <GroupWithEntries>[
      GroupWithEntries(const Group(id: 1, name: "Test group 1"), []),
      GroupWithEntries(const Group(id: 2, name: "Test group 2"), []),
      GroupWithEntries(const Group(id: 3, name: "Test group 3"), []),
      GroupWithEntries(const Group(id: 4, name: "Test group 4"), []),
    ];

    Future<Group?>? future;
    await tester.pumpWidget(buildTestAppForWidgets((final context) {
      future = ChangeGroupAlertWidget.showCustomDialog(context,
          groups: groups, selectedGroup: null);
    }));

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    expect(future, isNotNull);
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text("Set the group"), findsOneWidget);
    expect(
        find.descendant(
            of: find.byType(Dialog),
            matching: find.byType(typeOf<DropdownButton<Group>>())),
        findsOneWidget);

    await scrollIntoViewAndTap(tester, "Test group 3", openSelector: true);

    final dropDown = tester.widget<DropdownButton<Group>>(find.descendant(
        of: find.byType(Dialog),
        matching: find.byType(typeOf<DropdownButton<Group>>())));

    expect(dropDown.value, isNotNull);
    expect(dropDown.value!.id, 3);
    expect(dropDown.value!.name, "Test group 3");

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
    final value = await future;
    expect(value, isNotNull);
    expect(value!.id, 3);
    expect(value.name, "Test group 3");
  });
}

Future<void> scrollIntoViewAndTap(final WidgetTester tester, final String item,
    {final bool openSelector = true}) async {
  if (openSelector) {
    await tester.tap(find.descendant(
        of: find.byType(Dialog),
        matching: find.byType(typeOf<DropdownButton<Group>>())));
    await tester.pumpAndSettle();
  }

  await tester.scrollUntilVisible(find.text(item).last, 1.0);
  await tester.tap(find
      .ancestor(
          of: find.text(item),
          matching: find.byType(typeOf<DropdownMenuItem<Group>>()))
      .last);
  await tester.pumpAndSettle();
}
