part of quick_blue_back_end;

class ConnectionHandler {
  ConnectionHandler._() {
    QuickBlue.setConnectionHandler(_connectionHandler);
  }

  void _connectionHandler(
      final String deviceId, final BlueConnectionState state) {
    final subject = _subjects[deviceId];
    if (subject != null) {
      subject.add(state);
    } else {
      lighthouseLogger.info("Could not handle connection state for $deviceId");
    }
  }

  final Map<String, BehaviorSubject<BlueConnectionState>> _subjects = {};

  Stream<BlueConnectionState> getOrCreateStream(final String deviceId) {
    return _getOrCreateSubject(deviceId).stream;
  }

  BehaviorSubject<BlueConnectionState> _getOrCreateSubject(
      final String deviceId) {
    return _subjects[deviceId] ??=
        BehaviorSubject.seeded(BlueConnectionState.disconnected);
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

  Future<void> waitForState(
      final String deviceId, final BlueConnectionState state) async {
    final subject = _getOrCreateSubject(deviceId);
    if (subject.valueOrNull == state) {
      return;
    }
    subject.stream.firstWhere((element) => element == state);
  }
}
