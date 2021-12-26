import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/lighthouse_back_ends/fake/fake_back_end.dart';
import 'package:lighthouse_pm/platform_specific/mobile/local_platform.dart';

void main() {
  test('Should generate correct Android identifiers', () {
    final identifier1 = FakeDeviceIdentifier.generateDeviceIdentifierAndroid(1);
    expect(identifier1.toString(), "00:00:00:00:00:01");

    final identifier2 =
        FakeDeviceIdentifier.generateDeviceIdentifierAndroid(10);
    expect(identifier2.toString(), "00:00:00:00:00:0A");

    final identifier3 =
        FakeDeviceIdentifier.generateDeviceIdentifierAndroid(16);
    expect(identifier3.toString(), "00:00:00:00:00:10");
  });

  test('Should generate correct Linux identifiers', () {
    final identifier1 = FakeDeviceIdentifier.generateDeviceIdentifierLinux(1);
    expect(identifier1.toString(), "00:00:00:00:00:01");

    final identifier2 = FakeDeviceIdentifier.generateDeviceIdentifierLinux(10);
    expect(identifier2.toString(), "00:00:00:00:00:0A");

    final identifier3 = FakeDeviceIdentifier.generateDeviceIdentifierLinux(16);
    expect(identifier3.toString(), "00:00:00:00:00:10");
  });

  test('Should wrap mac identifiers', () {
    final identifier1 =
        FakeDeviceIdentifier.generateBasicMacIdentifier(0xFF + 1);
    expect(identifier1.toString(), "00:00:00:00:01:00");

    final identifier2 = FakeDeviceIdentifier.generateBasicMacIdentifier(0xFFFF);
    expect(identifier2.toString(), "00:00:00:00:FF:FF");
  });

  test('Should generate correct web identifiers', () {
    final identifier1 = FakeDeviceIdentifier.generateDeviceIdentifierWeb(1);
    expect(identifier1.toString(), "AAAAAAAAAAAAAAAAAAAAAQ==");
    final decoded1 = base64Decode(identifier1.toString());
    expect(decoded1.length, 16);
    expect(decoded1[0], 0);
    expect(decoded1[1], 0);
    expect(decoded1[2], 0);
    expect(decoded1[3], 0);
    expect(decoded1[4], 0);
    expect(decoded1[5], 0);
    expect(decoded1[6], 0);
    expect(decoded1[7], 0);
    expect(decoded1[8], 0);
    expect(decoded1[9], 0);
    expect(decoded1[10], 0);
    expect(decoded1[11], 0);
    expect(decoded1[12], 0);
    expect(decoded1[13], 0);
    expect(decoded1[14], 0);
    expect(decoded1[15], 1);

    final identifier2 = FakeDeviceIdentifier.generateDeviceIdentifierWeb(0xFF);
    expect(identifier2.toString(), "AAAAAAAAAAAAAAAAAAAA/w==");
    final decoded2 = base64Decode(identifier2.toString());
    expect(decoded2.length, 16);
    expect(decoded2[0], 0);
    expect(decoded2[1], 0);
    expect(decoded2[2], 0);
    expect(decoded2[3], 0);
    expect(decoded2[4], 0);
    expect(decoded2[5], 0);
    expect(decoded2[6], 0);
    expect(decoded2[7], 0);
    expect(decoded2[8], 0);
    expect(decoded2[9], 0);
    expect(decoded2[10], 0);
    expect(decoded2[11], 0);
    expect(decoded2[12], 0);
    expect(decoded2[13], 0);
    expect(decoded2[14], 0);
    expect(decoded2[15], 0xFF);

    final identifier3 =
        FakeDeviceIdentifier.generateDeviceIdentifierWeb(0xFFFF);
    expect(identifier3.toString(), "AAAAAAAAAAAAAAAAAAD//w==");
    final decoded3 = base64Decode(identifier3.toString());
    expect(decoded3.length, 16);
    expect(decoded3[0], 0);
    expect(decoded3[1], 0);
    expect(decoded3[2], 0);
    expect(decoded3[3], 0);
    expect(decoded3[4], 0);
    expect(decoded3[5], 0);
    expect(decoded3[6], 0);
    expect(decoded3[7], 0);
    expect(decoded3[8], 0);
    expect(decoded3[9], 0);
    expect(decoded3[10], 0);
    expect(decoded3[11], 0);
    expect(decoded3[12], 0);
    expect(decoded3[13], 0);
    expect(decoded3[14], 0xFF);
    expect(decoded3[15], 0xFF);
  });

  test('Should generate correct iOS identifiers', () {
    expect(() => FakeDeviceIdentifier.generateDeviceIdentifierIOS(0),
        throwsA(TypeMatcher<UnimplementedError>()));
  });

  test('Should generate correct identifier for os', () {
    LocalPlatform.overridePlatform = PlatformOverride.unsupported;
    // Unsupported platform should error.
    try {
      FakeDeviceIdentifier.generateDeviceIdentifier(0);
      fail("Should error");
    } catch (e) {
      expect(e, TypeMatcher<UnsupportedError>());
    }

    // Should generate Android identifier
    LocalPlatform.overridePlatform = PlatformOverride.android;
    expect(FakeDeviceIdentifier.generateDeviceIdentifier(0).toString(),
        '00:00:00:00:00:00');

    //Should genereat Linux identifier
    LocalPlatform.overridePlatform = PlatformOverride.linux;
    expect(FakeDeviceIdentifier.generateDeviceIdentifier(1).toString(),
        '00:00:00:00:00:01');

    // Should generate web identifier
    LocalPlatform.overridePlatform = PlatformOverride.web;
    final identifier1 = FakeDeviceIdentifier.generateDeviceIdentifier(1);
    expect(identifier1.toString(), "AAAAAAAAAAAAAAAAAAAAAQ==");
    final decoded1 = base64Decode(identifier1.toString());
    expect(decoded1.length, 16);
    expect(decoded1[0], 0);
    expect(decoded1[1], 0);
    expect(decoded1[2], 0);
    expect(decoded1[3], 0);
    expect(decoded1[4], 0);
    expect(decoded1[5], 0);
    expect(decoded1[6], 0);
    expect(decoded1[7], 0);
    expect(decoded1[8], 0);
    expect(decoded1[9], 0);
    expect(decoded1[10], 0);
    expect(decoded1[11], 0);
    expect(decoded1[12], 0);
    expect(decoded1[13], 0);
    expect(decoded1[14], 0);
    expect(decoded1[15], 1);

    // Should generate ios identifier
    LocalPlatform.overridePlatform = PlatformOverride.ios;
    expect(() => FakeDeviceIdentifier.generateDeviceIdentifier(0),
        throwsA(TypeMatcher<UnimplementedError>()));
  });
}
