import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/pages/settings/privacy_page.dart';
import 'package:lighthouse_pm/widgets/content_container_widget.dart';

import '../helpers/widget_helpers.dart';

void main() {
  test('Should generate correct super script', () {
    final script1 = PrivacyPage.toSuperScript(123);
    expect(script1, equals("¹²³"));

    final script2 = PrivacyPage.toSuperScript(9876543210);
    expect(script2, equals("⁹⁸⁷⁶⁵⁴³²¹⁰"));

    final script3 = PrivacyPage.toSuperScript(-40);
    expect(script3, equals("⁻⁴⁰"));
  });

  testWidgets('Should create privacy page', (final WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp((final context) {
      return const PrivacyPage();
    }));

    await tester.pumpAndSettle();

    expect(find.text("Privacy"), findsOneWidget, reason: "Should find heading");
    expect(find.textContaining(PrivacyPage.version1_1Date), findsOneWidget,
        reason: "Should find privacy versions");
  });

  testWidgets('Should open links', (final WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp((final context) {
      return const PrivacyPage();
    }));

    await tester.pumpAndSettle();

    final list = tester.firstWidget(find.byType(ListView));

    final containerWidget = tester
        .widgetList(find.descendant(
            of: find.byWidget(list),
            matching: find.byType(ContentContainerWidget)))
        .toList()[1];
    expect(containerWidget, isNotNull);

    final RichText richText = tester
        .widgetList<RichText>(find.descendant(
            of: find.byWidget(containerWidget),
            matching: find.byType(RichText)))
        .toList()[0];

    final TextSpan text = richText.text as TextSpan;

    // print(text.toPlainText());

    TextSpan? githubPrivacyLink;
    TextSpan? switchNewPhoneLink;
    TextSpan? googlePrivacyLink;

    for (final element in text.children!) {
      if (element is TextSpan) {
        if (element.text == "Github privacy statement") {
          githubPrivacyLink = element;
        } else if (element.text == "Switch to a new Android phone") {
          switchNewPhoneLink = element;
        } else if (element.text == "Google privacy Statement") {
          googlePrivacyLink = element;
        }
      }
    }

    expect(githubPrivacyLink, isNotNull,
        reason: "Github privacy link should exist");
    expect(switchNewPhoneLink, isNotNull,
        reason: "Switch new phone link should exist");
    expect(googlePrivacyLink, isNotNull,
        reason: "Google privacy link should exist");

    expect(githubPrivacyLink!.recognizer, isA<TapGestureRecognizer>());
    expect(switchNewPhoneLink!.recognizer, isA<TapGestureRecognizer>());
    expect(googlePrivacyLink!.recognizer, isA<TapGestureRecognizer>());

    expect((githubPrivacyLink.recognizer as TapGestureRecognizer).onTap,
        isNotNull);
    expect((switchNewPhoneLink.recognizer as TapGestureRecognizer).onTap,
        isNotNull);
    expect((googlePrivacyLink.recognizer as TapGestureRecognizer).onTap,
        isNotNull);

    (githubPrivacyLink.recognizer as TapGestureRecognizer).onTap!();
    (switchNewPhoneLink.recognizer as TapGestureRecognizer).onTap!();
    (googlePrivacyLink.recognizer as TapGestureRecognizer).onTap!();
  });
}
