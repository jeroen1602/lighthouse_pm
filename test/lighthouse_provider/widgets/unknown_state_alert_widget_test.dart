import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/lighthouse_provider/widgets/unknown_state_alert_widget.dart';
import 'package:lighthouse_provider/lighthouse_provider.dart';
import 'package:lighthouse_providers/lighthouse_v2_device_provider.dart';
import 'package:lighthouse_test_helper/lighthouse_test_helper.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_platform/shared_platform_io.dart';

import '../../helpers/widget_helpers.dart';

void main() {
  tearDown(() {
    SharedPlatform.overridePlatform = null;
  });

  testWidgets("Should create an universal unknown state alert widget",
      (final WidgetTester tester) async {
    SharedPlatform.overridePlatform = PlatformOverride.android;
    final device = FakeHighLevelDevice.simple();
    SharedPlatform.overridePlatform = null;

    await tester.pumpWidget(buildTestAppForWidgets((final context) {
      UnknownStateAlertWidget.showCustomDialog(context, device, 0xFF);
    }));

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text("Unknown state"), findsOneWidget);

    final richText = (tester.widgetList<RichText>(find.descendant(
            of: find.byType(Dialog), matching: find.byType(RichText))))
        .toList()[1];
    final text = richText.text.toPlainText();

    expect(
        text,
        contains(
            "The state of this device is unknown. What do you want to do?"));
    expect(text, contains("Help out."));

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets("Should create actions for unknown state alert widget",
      (final WidgetTester tester) async {
    SharedPlatform.overridePlatform = PlatformOverride.android;
    final device = FakeHighLevelDevice.simple();
    SharedPlatform.overridePlatform = null;

    await tester.pumpWidget(buildTestAppForWidgets((final context) {
      UnknownStateAlertWidget.showCustomDialog(context, device, 0xFF);
    }));

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text("Unknown state"), findsOneWidget);

    expect(find.text("Cancel"), findsOneWidget);
    expect(find.text("Standby"), findsNothing);
    expect(find.text("Sleep"), findsOneWidget);
    expect(find.text("On"), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets("Should add standby if supported for unknown state alert widget",
      (final WidgetTester tester) async {
    SharedPlatform.overridePlatform = PlatformOverride.android;
    final device = FakeHighLevelDevice.simple();
    device.extensions.add(StandbyExtension(
        changeState: (final LighthousePowerState newState) async {},
        powerStateStream: () => Stream.value(LighthousePowerState.unknown)));
    SharedPlatform.overridePlatform = null;

    await tester.pumpWidget(buildTestAppForWidgets((final context) {
      UnknownStateAlertWidget.showCustomDialog(context, device, 0xFF);
    }));

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text("Unknown state"), findsOneWidget);

    expect(find.text("Cancel"), findsOneWidget);
    expect(find.text("Standby"), findsOneWidget);
    expect(find.text("Sleep"), findsOneWidget);
    expect(find.text("On"), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets("Should return null on cancel unknown state alert widget",
      (final WidgetTester tester) async {
    Future<LighthousePowerState?>? future;
    SharedPlatform.overridePlatform = PlatformOverride.android;
    final device = FakeHighLevelDevice.simple();
    device.extensions.add(StandbyExtension(
        changeState: (final LighthousePowerState newState) async {},
        powerStateStream: () => Stream.value(LighthousePowerState.unknown)));
    SharedPlatform.overridePlatform = null;

    await tester.pumpWidget(buildTestAppForWidgets((final context) {
      future = UnknownStateAlertWidget.showCustomDialog(context, device, 0xFF);
    }));

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text("Unknown state"), findsOneWidget);
    expect(future, isNotNull);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
    final value = await future!.timeout(const Duration(seconds: 1));
    expect(value, isNull);
  });

  testWidgets("Should return on state on 'on' unknown state alert widget",
      (final WidgetTester tester) async {
    Future<LighthousePowerState?>? future;
    SharedPlatform.overridePlatform = PlatformOverride.android;
    final device = FakeHighLevelDevice.simple();
    device.extensions.add(StandbyExtension(
        changeState: (final LighthousePowerState newState) async {},
        powerStateStream: () => Stream.value(LighthousePowerState.unknown)));
    SharedPlatform.overridePlatform = null;

    await tester.pumpWidget(buildTestAppForWidgets((final context) {
      future = UnknownStateAlertWidget.showCustomDialog(context, device, 0xFF);
    }));

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text("Unknown state"), findsOneWidget);
    expect(future, isNotNull);

    await tester.tap(find.text('On'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
    final value = await future!.timeout(const Duration(seconds: 1));
    expect(value, isNotNull);
    expect(value, LighthousePowerState.on);
  });

  testWidgets("Should return sleep state on 'sleep' unknown state alert widget",
      (final WidgetTester tester) async {
    Future<LighthousePowerState?>? future;
    SharedPlatform.overridePlatform = PlatformOverride.android;
    final device = FakeHighLevelDevice.simple();
    device.extensions.add(StandbyExtension(
        changeState: (final LighthousePowerState newState) async {},
        powerStateStream: () => Stream.value(LighthousePowerState.unknown)));
    SharedPlatform.overridePlatform = null;

    await tester.pumpWidget(buildTestAppForWidgets((final context) {
      future = UnknownStateAlertWidget.showCustomDialog(context, device, 0xFF);
    }));

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text("Unknown state"), findsOneWidget);
    expect(future, isNotNull);

    await tester.tap(find.text('Sleep'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
    final value = await future!.timeout(const Duration(seconds: 1));
    expect(value, isNotNull);
    expect(value, LighthousePowerState.sleep);
  });

  testWidgets(
      "Should return standby state on 'standby' unknown state alert widget",
      (final WidgetTester tester) async {
    Future<LighthousePowerState?>? future;
    SharedPlatform.overridePlatform = PlatformOverride.android;
    final device = FakeHighLevelDevice.simple();
    device.extensions.add(StandbyExtension(
        changeState: (final LighthousePowerState newState) async {},
        powerStateStream: () => Stream.value(LighthousePowerState.unknown)));
    SharedPlatform.overridePlatform = null;

    await tester.pumpWidget(buildTestAppForWidgets((final context) {
      future = UnknownStateAlertWidget.showCustomDialog(context, device, 0xFF);
    }));

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text("Unknown state"), findsOneWidget);
    expect(future, isNotNull);

    await tester.tap(find.text('Standby'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
    final value = await future!.timeout(const Duration(seconds: 1));
    expect(value, isNotNull);
    expect(value, LighthousePowerState.standby);
  });

  testWidgets("Open help out alert widget unknown state alert widget",
      (final WidgetTester tester) async {
    SharedPlatform.overridePlatform = PlatformOverride.android;
    final device = FakeHighLevelDevice.simple();
    SharedPlatform.overridePlatform = null;

    await tester.pumpWidget(buildTestAppForWidgets((final context) {
      UnknownStateAlertWidget.showCustomDialog(context, device, 0xFF);
    }));

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text("Unknown state"), findsOneWidget);

    final richText =
        tester.widgetList<RichText>(find.byType(RichText)).toList()[2];

    final tapped = tapTextSpan(richText, "Help out.");
    expect(tapped, isTrue);
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNWidgets(2));

    //Close the dialog
    await tester.tap(find.descendant(
        of: find.byType(Dialog).last, matching: find.text("Cancel")));
    await tester.pumpAndSettle();

    await tester.tap(find.text("Cancel"));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets("Should create unknown state help out alert widget",
      (final WidgetTester tester) async {
    SharedPlatform.overridePlatform = PlatformOverride.android;
    final device = FakeHighLevelDevice.simple();
    SharedPlatform.overridePlatform = null;

    PackageInfo.setMockInitialValues(
        appName: "Lighthouse pm",
        packageName: "com.jeroen1602.lighthouse_pm",
        version: "fake-version",
        buildNumber: "-9",
        buildSignature: "SIGN_HERE_PLEASE");

    await tester.pumpWidget(buildTestAppForWidgets((final context) {
      UnknownStateHelpOutAlertWidget.showCustomDialog(context, device, 0xFF);
    }));

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    final text = tester
        .widgetList<RichText>(find.byType(RichText))
        .toList()[2]
        .text
        .toPlainText();

    expect(text, contains("fake-version"));
    expect(text, contains("FakeHighLevelDevice"));

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets("Should open issue for unknown state help out alert widget",
      (final WidgetTester tester) async {
    SharedPlatform.overridePlatform = PlatformOverride.android;
    final device = FakeHighLevelDevice.simple();
    SharedPlatform.overridePlatform = null;

    PackageInfo.setMockInitialValues(
        appName: "Lighthouse pm",
        packageName: "com.jeroen1602.lighthouse_pm",
        version: "fake-version",
        buildNumber: "-9",
        buildSignature: "SIGN_HERE_PLEASE");

    await tester.pumpWidget(buildTestAppForWidgets((final context) {
      UnknownStateHelpOutAlertWidget.showCustomDialog(context, device, 0xFF);
    }));

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    final text = tester
        .widgetList<RichText>(find.byType(RichText))
        .toList()[2]
        .text
        .toPlainText();

    expect(text, contains("fake-version"));
    expect(text, contains("FakeHighLevelDevice"));

    await tester.tap(find.text('Open issue'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets(
      "Should copy to clipboard for unknown state help out alert widget",
      (final WidgetTester tester) async {
    SharedPlatform.overridePlatform = PlatformOverride.android;
    final device = FakeHighLevelDevice.simple();
    SharedPlatform.overridePlatform = null;

    PackageInfo.setMockInitialValues(
        appName: "Lighthouse pm",
        packageName: "com.jeroen1602.lighthouse_pm",
        version: "fake-version",
        buildNumber: "-9",
        buildSignature: "SIGN_HERE_PLEASE");

    await tester.pumpWidget(buildTestAppForWidgets((final context) {
      UnknownStateHelpOutAlertWidget.showCustomDialog(context, device, 0xFF);
    }));

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    final textWidget =
        tester.widgetList<RichText>(find.byType(RichText)).toList()[2];
    final text = textWidget.text.toPlainText();

    expect(text, contains("fake-version"));
    expect(text, contains("FakeHighLevelDevice"));

    final held = holdTextSpan(textWidget, "App version: ");
    expect(held, isTrue);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
  });
}
