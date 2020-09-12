class TimeoutContainer<T> {
  TimeoutContainer(this.data, {DateTime /* ? */ lastSeen}) {
    if (lastSeen == null) {
      lastSeen = DateTime.now();
    }
    this.lastSeen = lastSeen;
  }

  T data;
  DateTime lastSeen;
}
