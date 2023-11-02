part of '../../lighthouse_provider.dart';

class TimeoutContainer<T> {
  TimeoutContainer(this.data, {final DateTime? lastSeen})
      : lastSeen = lastSeen ?? DateTime.now();

  T data;
  DateTime lastSeen;
}
