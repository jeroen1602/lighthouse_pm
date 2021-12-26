part of lighthouse_provider;

class TimeoutContainer<T> {
  TimeoutContainer(this.data, {DateTime? lastSeen}) {
    if (lastSeen != null) {
      this.lastSeen = lastSeen;
    }
  }

  T data;
  DateTime lastSeen = DateTime.now();
}
