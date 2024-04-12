import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/widgets/markdown/markdown.dart';

import '../../helpers/widget_helpers.dart';

void main() {
  group('markdown', () {
    group('super_script_syntax', () {
      test('Should generate correct super script', () {
        final script1 = SuperscriptSyntax.toSuperScript("123");
        expect(script1, equals("¹²³"));

        final script2 = SuperscriptSyntax.toSuperScript("9876543210");
        expect(script2, equals("⁹⁸⁷⁶⁵⁴³²¹⁰"));

        final script3 = SuperscriptSyntax.toSuperScript("-40");
        expect(script3, equals("⁻⁴⁰"));
      });

      testWidgets('Should convert into superscript',
          (final WidgetTester tester) async {
        const exampleText = '# wow a test\n\n'
            'Now with super script!<sup>123</sup>\n';

        await tester.pumpWidget(buildTestApp((final context) {
          return Markdown(data: exampleText, inlineSyntaxes: [
            SuperscriptSyntax(),
          ]);
        }));

        await tester.pumpAndSettle();

        final richTexts = tester
            .widgetList(find.descendant(
                of: find.byType(Markdown), matching: find.byType(RichText)))
            .toList(growable: false);

        expect(richTexts, hasLength(2),
            reason: 'Should contain two rich text blocks');

        final text = (richTexts[1] as RichText).text.toPlainText();
        expect(text, contains('¹²³'), reason: 'Should contain super script');
        expect(text, isNot(contains('<sup>')),
            reason: 'Should not contain the original <sup> html tag');
        expect(text, isNot(contains('</sup>')),
            reason: 'Should not contain the original <sup> html tag');
      });
    });
  });
}
