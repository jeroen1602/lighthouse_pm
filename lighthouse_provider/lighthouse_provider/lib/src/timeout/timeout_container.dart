part of lighthouse_provider;

class TimeoutContainer<T> {
  TimeoutContainer(this.data, {DateTime? lastSeen})
      : lastSeen = lastSeen ?? DateTime.now();

  T data;
  DateTime lastSeen;
}
