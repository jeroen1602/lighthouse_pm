import 'package:flutter_test/flutter_test.dart';
import 'package:fake_back_end/fake_back_end.dart';
import 'package:shared_platform/shared_platform_io.dart';

void main() {
  tearDown(() {
    SharedPlatform.overridePlatform = null;
  });

  test('Should return an empty intList', () {
    final list = intListFromNumber(0x00000000);
    expect(list, isEmpty);
  });

  test('Should only write a uint32 in web', () {
    SharedPlatform.overridePlatform = PlatformOverride.android;

    final list = intListFromNumber(0x1122334455667788);
    expect(list, [0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88]);

    // Only the lower part will be used. Because web doesn't support 64 bit ints.
    SharedPlatform.overridePlatform = PlatformOverride.web;
    final list2 = intListFromNumber(0x1122334455667788);
    expect(list2, [0x55, 0x66, 0x77, 0x88]);
  });

  test('Should convert a string to int list', () {
    const string = "ABCDEF";

    final list = intListFromString(string);
    expect(list, [0x41, 0x42, 0x43, 0x44, 0x45, 0x46]);
  });
}
