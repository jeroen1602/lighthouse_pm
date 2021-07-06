import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/lighthouseProvider/deviceExtensions/ShortcutExtension.dart';

void main() {
  test('Should be able to create shortcut extension', () async {
    final extension = ShortcutExtension("00:00:00:00:00:00", () {
      return "DEVICE_NAME";
    });

    expect(extension.icon, TypeMatcher<Icon>());
    expect(extension.toolTip, 'Create shortcut');
    expect(extension.updateListAfter, false);
  });

  test('Should be able to create shortcut', () async {
    final extension = ShortcutExtension("00:00:00:00:00:00", () {
      return "DEVICE_NAME";
    });

    // For now do this because the extension method channel doesn't work.
    expect(
        () async => await extension.onTap(), throwsA(TypeMatcher<TypeError>()));
  });
}
