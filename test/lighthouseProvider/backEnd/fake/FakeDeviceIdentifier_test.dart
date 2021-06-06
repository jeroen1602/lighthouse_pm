import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/lighthouseProvider/backEnd/fake/FakeDeviceIdentifier.dart';
import 'package:lighthouse_pm/platformSpecific/mobile/LocalPlatform.dart';

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

  test('Should wrap Android identifier', () {
    final identifier1 =
        FakeDeviceIdentifier.generateDeviceIdentifierAndroid(0xFF + 1);
    expect(identifier1.toString(), "00:00:00:00:01:00");

    final identifier2 =
        FakeDeviceIdentifier.generateDeviceIdentifierAndroid(0xFFFF);
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
    // Test platform is probably linux so it should crash for now.
    expect(() => FakeDeviceIdentifier.generateDeviceIdentifier(0),
        throwsA(TypeMatcher<UnsupportedError>()));

    // Should generate Android identifier
    LocalPlatform.overridePlatform = PlatformOverride.android;
    expect(FakeDeviceIdentifier.generateDeviceIdentifier(0).toString(),
        '00:00:00:00:00:00');

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
