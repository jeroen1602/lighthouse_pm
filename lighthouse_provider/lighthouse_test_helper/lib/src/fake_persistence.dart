import 'package:lighthouse_provider/lighthouse_provider.dart';
import 'package:lighthouse_providers/lighthouse_v2_device_provider.dart';
import 'package:lighthouse_providers/vive_base_station_device_provider.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test/fake.dart';

@visibleForTesting
class ViveBaseStationStorage {
  LHDeviceIdentifier deviceId;
  int baseStationId;

  ViveBaseStationStorage(this.deviceId, this.baseStationId);
}

@visibleForTesting
class FakeViveBaseStationBloc extends Fake
    implements ViveBaseStationPersistence {
  BehaviorSubject<List<ViveBaseStationStorage>>? idsStream;

  @override
  Future<int?> getId(final LHDeviceIdentifier deviceId) async {
    final stream = idsStream;
    if (stream == null) {
      return null;
    }

    return stream.valueOrNull
        ?.cast<ViveBaseStationStorage?>()
        .firstWhere((final element) => element?.deviceId == deviceId,
            orElse: () => null)
        ?.baseStationId;
  }

  @override
  Future<void> insertId(final LHDeviceIdentifier deviceId, final int id) async {
    final idsStream = this.idsStream;
    if (idsStream != null) {
      final index = idsStream.valueOrNull
              ?.indexWhere((final element) => element.deviceId == deviceId) ??
          -1;
      if (index >= 0) {
        idsStream.valueOrNull?.removeAt(index);
      }
      idsStream.valueOrNull?.add(ViveBaseStationStorage(deviceId, id));
      idsStream.add(idsStream.valueOrNull ?? []);
    }
  }

  @override
  Future<void> deleteId(final LHDeviceIdentifier deviceId) async {
    final idsStream = this.idsStream;
    if (idsStream != null) {
      final index = idsStream.valueOrNull
              ?.indexWhere((final element) => element.deviceId == deviceId) ??
          -1;
      if (index >= 0) {
        idsStream.valueOrNull?.removeAt(index);
        idsStream.add(idsStream.valueOrNull ?? []);
      }
    }
  }

  @override
  Stream<bool> hasIdStored(final LHDeviceIdentifier deviceId) {
    final idsStream = this.idsStream;
    if (idsStream == null) {
      return Stream.value(false);
    }
    return idsStream.map((final ids) {
      for (final id in ids) {
        if (deviceId == id.deviceId) {
          return true;
        }
      }
      return false;
    });
  }

  void startViveBaseStationIdsStream(
      [final List<ViveBaseStationStorage> data = const []]) {
    idsStream ??= BehaviorSubject.seeded(data.toList());
  }
}

@visibleForTesting
class FakeLighthouseV2Bloc extends Fake implements LighthouseV2Persistence {
  bool shortcutsEnabled = false;

  @override
  Future<bool> areShortcutsEnabled() async {
    return shortcutsEnabled;
  }
}
