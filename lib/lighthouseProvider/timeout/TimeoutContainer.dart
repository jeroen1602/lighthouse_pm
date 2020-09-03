class TimeoutContainer<T> {
  TimeoutContainer(this.data, {DateTime /* ? */ lastSeen = null}) {
    if (lastSeen == null) {
      lastSeen = DateTime.now();
    }
    this.lastSeen = lastSeen;
  }

  T data;
  DateTime lastSeen;
}
