import 'package:lighthouse_provider/lighthouse_provider.dart';
import 'package:lighthouse_providers/lighthouse_v2_device_provider.dart';
import 'package:lighthouse_providers/vive_base_station_device_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test/fake.dart';

class ViveBaseStationStorage {
  LHDeviceIdentifier deviceId;
  int baseStationId;

  ViveBaseStationStorage(this.deviceId, this.baseStationId);
}

class FakeViveBaseStationBloc extends Fake
    implements ViveBaseStationPersistence {
  BehaviorSubject<List<ViveBaseStationStorage>>? idsStream;

  @override
  Future<int?> getId(LHDeviceIdentifier deviceId) async {
    final stream = idsStream;
    if (stream == null) {
      return null;
    }

    return stream.valueOrNull
        ?.cast<ViveBaseStationStorage?>()
        .firstWhere((element) => element?.deviceId == deviceId,
            orElse: () => null)
        ?.baseStationId;
  }

  @override
  Future<void> insertId(LHDeviceIdentifier deviceId, int id) async {
    final idsStream = this.idsStream;
    if (idsStream != null) {
      final index = idsStream.valueOrNull
              ?.indexWhere((element) => element.deviceId == deviceId) ??
          -1;
      if (index >= 0) {
        idsStream.valueOrNull?.removeAt(index);
      }
      idsStream.valueOrNull?.add(ViveBaseStationStorage(deviceId, id));
      idsStream.add(idsStream.valueOrNull ?? []);
    }
  }

  @override
  Future<void> deleteId(LHDeviceIdentifier deviceId) async {
    final idsStream = this.idsStream;
    if (idsStream != null) {
      final index = idsStream.valueOrNull
              ?.indexWhere((element) => element.deviceId == deviceId) ??
          -1;
      if (index >= 0) {
        idsStream.valueOrNull?.removeAt(index);
        idsStream.add(idsStream.valueOrNull ?? []);
      }
    }
  }

  void startViveBaseStationIdsStream(
      [List<ViveBaseStationStorage> data = const []]) {
    idsStream ??= BehaviorSubject.seeded(data.toList());
  }
}

class FakeLighthouseV2Bloc extends Fake implements LighthouseV2Persistence {}
