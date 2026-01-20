part of quick_blue_back_end;

class QuickBlueService extends LHBluetoothService {
  QuickBlueService(final String serviceId, this.characteristics)
      : uuid = LighthouseGuid.fromString(serviceId);

  @override
  final LighthouseGuid uuid;
  @override
  final List<LHBluetoothCharacteristic> characteristics;
}
