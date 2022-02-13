part of flutter_web_bluetooth_back_end;

class FlutterWebBluetoothService extends LHBluetoothService {
  FlutterWebBluetoothService(this.service,
      final List<FlutterWebBluetoothCharacteristic> characteristics)
      : _characteristics = characteristics;

  static Future<FlutterWebBluetoothService> withCharacteristics(
      final BluetoothService service,
      final List<LighthouseGuid> characteristicsGuid) async {
    final List<FlutterWebBluetoothCharacteristic> characteristics = [];

    for (final characteristicGuid in characteristicsGuid) {
      try {
        final characteristic = await service
            .getCharacteristic(characteristicGuid.toString().toLowerCase());
        characteristics.add(FlutterWebBluetoothCharacteristic(characteristic));
      } on NotFoundError catch (e, s) {
        lighthouseLogger.info(
            "Characteristic "
            "${characteristicsGuid.toString()} not found in service "
            "${service.uuid}, that's ok.",
            e,
            s);
      } on SecurityError catch (e, s) {
        lighthouseLogger.info(
            "Security error for characteristic "
            "${characteristicsGuid.toString()} in service ${service.uuid}, "
            "that's ok.",
            e,
            s);
      } catch (error) {
        rethrow;
      }
    }
    return FlutterWebBluetoothService(service, characteristics);
  }

  final BluetoothService service;
  final List<FlutterWebBluetoothCharacteristic> _characteristics;

  @override
  List<LHBluetoothCharacteristic> get characteristics => _characteristics;

  @override
  LighthouseGuid get uuid => LighthouseGuid.fromString(service.uuid);
}
