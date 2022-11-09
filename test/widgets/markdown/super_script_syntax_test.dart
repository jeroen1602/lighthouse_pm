import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/widgets/markdown/super_script_syntax.dart';

void main() {
  test('Should generate correct super script', () {
    final script1 = SuperscriptSyntax.toSuperScript("123");
    expect(script1, equals("¹²³"));

    final script2 = SuperscriptSyntax.toSuperScript("9876543210");
    expect(script2, equals("⁹⁸⁷⁶⁵⁴³²¹⁰"));

    final script3 = SuperscriptSyntax.toSuperScript("-40");
    expect(script3, equals("⁻⁴⁰"));
  });
}
