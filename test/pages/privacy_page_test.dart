import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/pages/settings/privacy_page.dart';

void main() {
  test('Should generate correct super script', () {
    final script1 = PrivacyPage.toSuperScript(123);
    expect(script1, equals("¹²³"));

    final script2 = PrivacyPage.toSuperScript(9876543210);
    expect(script2, equals("⁹⁸⁷⁶⁵⁴³²¹⁰"));

    final script3 = PrivacyPage.toSuperScript(-40);
    expect(script3, equals("⁻⁴⁰"));
  });
}
