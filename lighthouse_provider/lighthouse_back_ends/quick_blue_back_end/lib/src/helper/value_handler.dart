part of quick_blue_back_end;

@immutable
class OperationItem {
  const OperationItem(this.deviceId, this.characteristicId);

  final String deviceId;
  final String characteristicId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OperationItem &&
          runtimeType == other.runtimeType &&
          deviceId == other.deviceId &&
          characteristicId == other.characteristicId;

  @override
  int get hashCode => deviceId.hashCode ^ characteristicId.hashCode;
}

class ValueHandler {
  ValueHandler._() {
    QuickBlue.setValueHandler(_valueHandler);
  }

  void _valueHandler(final String deviceId, final String characteristicId,
      final Uint8List value) {
    final operation = OperationItem(deviceId, characteristicId);
    final completer = _readCompleters[operation];
    if (completer != null) {
      completer.complete(value);
    } else {
      lighthouseLogger.info("Could not handle new value for deviceId $deviceId "
          "and characteristic $characteristicId");
    }
  }

  Future<Uint8List> readValue(final String deviceId, final String serviceId,
      final String characteristicId) async {
    final operation = OperationItem(deviceId, characteristicId);
    final oldCompleter = _readCompleters[operation];
    if (oldCompleter != null && !oldCompleter.isCompleted) {
      // TODO: custom error!
      oldCompleter.completeError(Error());
    }
    final completer = Completer<Uint8List>();
    _readCompleters[operation] = completer;

    QuickBlue.readValue(deviceId, serviceId, characteristicId);
    return completer.future;
  }

  final Map<OperationItem, Completer<Uint8List>> _readCompleters = {};

  Future<void> removeReadCompleter(
      final String deviceId, final String characteristicId) async {
    final operation = OperationItem(deviceId, characteristicId);
    final completer = _readCompleters[operation];
    if (completer != null && !completer.isCompleted) {
      // TODO: custom error!
      completer.completeError(Error());
      _readCompleters.remove(operation);
    } else {
      lighthouseLogger.info("Could not close subject for $deviceId");
    }
  }

  Future<void> removeAllReadCompleter() async {
    for (final completer in _readCompleters.values) {
      if (!completer.isCompleted) {
        // TODO: custom error!
        completer.completeError(Error());
      }
    }
    _readCompleters.clear();
  }

  Future<void> writeValue(
      final String deviceId,
      final String serviceId,
      final String characteristicId,
      final Uint8List value,
      final bool withoutResponse) async {
    BleOutputProperty property = withoutResponse
        ? BleOutputProperty.withoutResponse
        : BleOutputProperty.withResponse;
    QuickBlue.writeValue(
        deviceId, serviceId, characteristicId, value, property);
  }
}
