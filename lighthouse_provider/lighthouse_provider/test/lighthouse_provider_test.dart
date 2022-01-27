import 'dart:async';

import 'package:fake_back_end/fake_back_end.dart';
import 'package:lighthouse_provider/lighthouse_provider.dart';
import 'package:lighthouse_providers/lighthouse_v2_device_provider.dart';
import 'package:lighthouse_providers/vive_base_station_device_provider.dart';
import 'package:test/test.dart';

import 'helpers/fake_bloc.dart';
import 'lighthouse_back_ends/fake/fake_pair_back_end.dart';

void main() {
  test("Should always get the same provider instance", () {
    final instance1 = LighthouseProvider.instance;
    final instance2 = LighthouseProvider.instance;

    expect(instance1, isNotNull);
    expect(instance2, isNotNull);
    expect(instance1, equals(instance2));
  });

  test("Should not scan if no back end is installed", () async {
    final instance = LighthouseProvider.instance;

    try {
      await instance.startScan(
          timeout: Duration(milliseconds: 10),
          updateInterval: Duration(milliseconds: 2));
      fail("Start scan should have thrown");
    } catch (err) {
      expect(err, isA<StateError>());
      expect((err as StateError).message,
          equals("No back ends added, please add back ends first!"));
    }
  });

  test("Should not add provider if no back end is installed", () async {
    final instance = LighthouseProvider.instance;

    try {
      instance.addProvider(LighthouseV2DeviceProvider.instance);
      fail("Add provider should have thrown");
    } catch (err) {
      expect(err, isA<UnsupportedError>());
      expect(
          (err as UnsupportedError).message,
          equals(
              "No back end found for device provider: \"LighthouseV2DeviceProvider\". Did you forget to add the back end first?"));
    }
  });

  test("Should not remove provider if no back end is installed", () async {
    final instance = LighthouseProvider.instance;

    try {
      instance.removeProvider(LighthouseV2DeviceProvider.instance);
      fail("Remove provider should have thrown");
    } catch (err) {
      expect(err, isA<UnsupportedError>());
      expect(
          (err as UnsupportedError).message,
          equals(
              "No back ends installed. Did you forget to add the back end first?"));
    }
  });

  test("Should be able to add and remove a back end", () async {
    final instance = LighthouseProvider.instance;
    final backEnd = FakePairBackEnd([]);

    expect(instance.backEndSet, isEmpty,
        reason: "Should not have any back ends installed");

    instance.addBackEnd(backEnd);

    final backEnds = instance.backEndSet.toList(growable: false);

    expect(backEnds.length, equals(1),
        reason: "Should have exactly 1 back ends installed");
    expect(backEnds[0], isA<FakePairBackEnd>(),
        reason: "Back end should be fake pair back end");

    instance.removeBackEnd(backEnd);

    expect(instance.backEndSet, isEmpty,
        reason: "Should not have any back ends anymore");
  });

  test("Should be able to add and remove a provider", () async {
    final instance = LighthouseProvider.instance;
    final backEnd = FakePairBackEnd([]);

    // First add a back end
    expect(instance.backEndSet, isEmpty,
        reason: "Should not have any back ends installed");

    instance.addBackEnd(backEnd);

    final backEnds = instance.backEndSet.toList(growable: false);

    expect(backEnds.length, equals(1),
        reason: "Should have exactly 1 back ends installed");
    expect(backEnds[0], isA<FakePairBackEnd>(),
        reason: "Back end should be fake pair back end");

    expect(backEnd.providers, isEmpty,
        reason: "Back end should not have any providers");

    instance.addProvider(LighthouseV2DeviceProvider.instance);

    expect(backEnd.providers.length, equals(1),
        reason: "Should have a provider");
    expect(backEnd.providers.first, isA<LighthouseV2DeviceProvider>(),
        reason: "Provider should be lighthouse v2 device Provider");

    instance.removeProvider(LighthouseV2DeviceProvider.instance);

    expect(backEnd.providers, isEmpty,
        reason: "Back end should not have any providers anymore");

    instance.removeBackEnd(backEnd);

    expect(instance.backEndSet, isEmpty,
        reason: "Should not have any back ends anymore");
  });

  test("Should return false if there is no back end", () async {
    final instance = LighthouseProvider.instance;

    // First add a back end
    expect(instance.backEndSet, isEmpty,
        reason: "Should not have any back ends installed");

    final pairedBackends = instance.hasOnlyPairBackends();

    expect(pairedBackends, isFalse,
        reason:
            "Should not only have pair back ends if there are no back ends");

    final pairBackEnds = instance.getPairBackEnds();

    expect(pairBackEnds, isEmpty, reason: "Should not have any pair back end");
  });

  // region pair back ends
  test("Should return false if there is no pair back end", () async {
    final instance = LighthouseProvider.instance;

    // First add a back end
    expect(instance.backEndSet, isEmpty,
        reason: "Should not have any back ends installed");

    instance.addBackEnd(FakeBLEBackEnd.instance);

    final backEnds = instance.backEndSet.toList(growable: false);

    expect(backEnds.length, equals(1),
        reason: "Should have exactly 1 back end installed");
    expect(backEnds[0], isA<FakeBLEBackEnd>(),
        reason: "Back end should be fake pair back end");

    final pairedBackends = instance.hasOnlyPairBackends();

    expect(pairedBackends, isFalse, reason: "Should not have any back ends");

    final pairBackEnds = instance.getPairBackEnds();

    expect(pairBackEnds, isEmpty, reason: "Should not have any pair back end");

    instance.removeBackEnd(FakeBLEBackEnd.instance);

    expect(instance.backEndSet, isEmpty,
        reason: "Should not have any back ends anymore");
  });

  test("Should return true if there are only pair back ends", () async {
    final instance = LighthouseProvider.instance;
    final backEnd = FakePairBackEnd([]);

    // First add a back end
    expect(instance.backEndSet, isEmpty,
        reason: "Should not have any back ends installed");

    instance.addBackEnd(backEnd);

    final backEnds = instance.backEndSet.toList(growable: false);

    expect(backEnds.length, equals(1),
        reason: "Should have exactly 1 back end installed");
    expect(backEnds[0], isA<FakePairBackEnd>(),
        reason: "Back end should be fake pair back end");

    final pairedBackends = instance.hasOnlyPairBackends();

    expect(pairedBackends, isTrue, reason: "Should only have paired back ends");

    final pairBackEnds = instance.getPairBackEnds();

    expect(pairBackEnds.length, equals(1),
        reason: "Should have exactly 1 pair back end installed");
    expect(pairBackEnds[0], isA<FakePairBackEnd>(),
        reason: "Back end should be fake pair back end");

    instance.removeBackEnd(backEnd);

    expect(instance.backEndSet, isEmpty,
        reason: "Should not have any back ends anymore");
  });

  test("Should return false if there are not only pair back ends", () async {
    final instance = LighthouseProvider.instance;
    final backEnd = FakePairBackEnd([]);

    // First add a back end
    expect(instance.backEndSet, isEmpty,
        reason: "Should not have any back ends installed");

    instance.addBackEnd(backEnd);
    instance.addBackEnd(FakeBLEBackEnd.instance);

    final backEnds = instance.backEndSet.toList(growable: false);

    expect(backEnds.length, equals(2),
        reason: "Should have exactly 2 back ends installed");
    expect(backEnds[0], isA<FakePairBackEnd>(),
        reason: "Back end should be fake pair back end");
    expect(backEnds[1], isA<FakeBLEBackEnd>(),
        reason: "Back end should be fake back end");

    final pairedBackends = instance.hasOnlyPairBackends();

    expect(pairedBackends, isFalse, reason: "Should have mixed back end");

    final pairBackEnds = instance.getPairBackEnds();

    expect(pairBackEnds.length, equals(1),
        reason: "There should be only 1 pair back end installed");
    expect(pairBackEnds[0], isA<FakePairBackEnd>(),
        reason: "The only pair back end should be of type fake pair back end");

    instance.removeBackEnd(backEnd);
    instance.removeBackEnd(FakeBLEBackEnd.instance);

    expect(instance.backEndSet, isEmpty,
        reason: "Should not have any back ends anymore");
  });
  // endregion

  test("Should get devices from scan", () async {
    final instance = LighthouseProvider.instance;
    final backEnd = FakePairBackEnd([
      FakeLighthouseV2Device(0, 0),
      FakeViveBaseStationDevice(1, 1),
    ]);

    instance.addBackEnd(backEnd);
    instance.addProvider(LighthouseV2DeviceProvider.instance);
    instance.addProvider(ViveBaseStationDeviceProvider.instance);

    LighthouseV2DeviceProvider.instance.setPersistence(FakeLighthouseV2Bloc());
    ViveBaseStationDeviceProvider.instance
        .setPersistence(FakeViveBaseStationBloc());

    // Wait for the state to update;
    await Future.delayed(Duration(milliseconds: 10));

    final state = await instance.state.first;

    expect(state, equals(BluetoothAdapterState.on),
        reason: "Fake back end should report an on state!");

    await instance.startScan(timeout: Duration(milliseconds: 100));

    try {
      final devices = await instance.lighthouseDevices
          .firstWhere((element) => element.length == 2)
          .timeout(Duration(seconds: 5));

      expect(devices.length, equals(2),
          reason: "Should have returned 2 devices");
      expect(devices.firstWhere((element) => element is LighthouseV2Device),
          isNotNull,
          reason: "One device should be a lighthouse v2");
      expect(devices.firstWhere((element) => element is ViveBaseStationDevice),
          isNotNull,
          reason: "One device should be a lighthouse v2");
    } on TimeoutException {
      fail("Could not get the required 2 device within the timeout!");
    }

    LighthouseV2DeviceProvider.instance.persistence = null;
    ViveBaseStationDeviceProvider.instance.persistence = null;
    instance.removeProvider(LighthouseV2DeviceProvider.instance);
    instance.removeProvider(ViveBaseStationDeviceProvider.instance);
    instance.removeBackEnd(backEnd);
  });

  test("Should not report a device double", () async {
    final instance = LighthouseProvider.instance;
    final backEnd = FakePairBackEnd([
      FakeLighthouseV2Device(0, 0),
      FakeViveBaseStationDevice(1, 1),
      FakeLighthouseV2Device(0, 0),
      FakeViveBaseStationDevice(1, 1),
    ]);

    instance.addBackEnd(backEnd);
    instance.addProvider(LighthouseV2DeviceProvider.instance);
    instance.addProvider(ViveBaseStationDeviceProvider.instance);

    LighthouseV2DeviceProvider.instance.setPersistence(FakeLighthouseV2Bloc());
    ViveBaseStationDeviceProvider.instance
        .setPersistence(FakeViveBaseStationBloc());

    // Wait for the state to update;
    await Future.delayed(Duration(milliseconds: 10));

    final state = await instance.state.first;

    expect(state, equals(BluetoothAdapterState.on),
        reason: "Fake back end should report an on state!");

    await instance.startScan(timeout: Duration(milliseconds: 100));

    try {
      final devices = await instance.lighthouseDevices
          .firstWhere((element) => element.length == 2)
          .timeout(Duration(seconds: 5));

      expect(devices.length, equals(2),
          reason: "Should have returned 2 devices");
      expect(devices.firstWhere((element) => element is LighthouseV2Device),
          isNotNull,
          reason: "One device should be a lighthouse v2");
      expect(devices.firstWhere((element) => element is ViveBaseStationDevice),
          isNotNull,
          reason: "One device should be a lighthouse v2");
    } on TimeoutException {
      fail("Could not get the required 2 device within the timeout!");
    }

    LighthouseV2DeviceProvider.instance.persistence = null;
    ViveBaseStationDeviceProvider.instance.persistence = null;
    instance.removeProvider(LighthouseV2DeviceProvider.instance);
    instance.removeProvider(ViveBaseStationDeviceProvider.instance);
    instance.removeBackEnd(backEnd);
  });
}
