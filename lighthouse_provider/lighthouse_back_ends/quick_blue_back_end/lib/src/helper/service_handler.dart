part of quick_blue_back_end;

@immutable
class ServiceData {
  const ServiceData(this.serviceId, this.characteristicIds);

  final String serviceId;
  final List<String> characteristicIds;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceData &&
          runtimeType == other.runtimeType &&
          serviceId == other.serviceId;

  @override
  int get hashCode => serviceId.hashCode;
}

class ServiceHandler {
  ServiceHandler._() {
    QuickBlue.setServiceHandler(_serviceHandler);
  }

  void _serviceHandler(final String deviceId, final String serviceId,
      List<String> characteristicIds) {
    final data = ServiceData(serviceId, characteristicIds);

    final set = (_services[deviceId] ??= {})..add(data);

    final subject = _subjects[deviceId];
    if (subject != null) {
      subject.add(set);
    } else {
      lighthouseLogger.info("Could not handle connection state for $deviceId");
    }
  }

  final Map<String, BehaviorSubject<Set<ServiceData>>> _subjects = {};
  final Map<String, Set<ServiceData>> _services = {};

  Stream<Set<ServiceData>> getOrCreateStream(final String deviceId) {
    return _getOrCreateSubject(deviceId).stream;
  }

  BehaviorSubject<Set<ServiceData>> _getOrCreateSubject(final String deviceId) {
    return _subjects[deviceId] ??= BehaviorSubject.seeded({});
  }

  Future<Set<ServiceData>> waitForServices(final String deviceId) async {
    return _getOrCreateSubject(deviceId)
        .switchMap(
            (final i) => TimerStream(i, const Duration(milliseconds: 150)))
        .first;
  }

  Future<void> removeSubject(final String deviceId) async {
    final subject = _subjects[deviceId];
    if (subject != null) {
      await subject.close();
      _subjects.remove(deviceId);
    } else {
      lighthouseLogger.info("Could not close subject for $deviceId");
    }
  }

  Future<void> removeAllSubjects() async {
    for (final subject in _subjects.values) {
      await subject.close();
    }
    _subjects.clear();
  }
}
