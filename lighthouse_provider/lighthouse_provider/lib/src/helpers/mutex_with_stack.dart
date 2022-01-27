part of lighthouse_provider;

class MutexWithStack extends Mutex {
  StackTrace? _lockTrace;

  ///
  /// The trace of where the [acquire] function was called from.
  ///
  /// You can also add the stack trace yourself at the [acquire] and [protect]
  /// functions if you need better logging.
  ///
  StackTrace? get lockTrace => _lockTrace;

  @override
  Future acquire([final StackTrace? trace]) async {
    await super.acquire();
    _lockTrace = trace ?? StackTrace.current;
  }

  @override
  void release() {
    super.release();
    _lockTrace = null;
  }

  @override
  Future<T> protect<T>(final Future<T> Function() criticalSection,
      [final StackTrace? trace]) async {
    await acquire(trace);
    try {
      return await criticalSection();
    } finally {
      release();
    }
  }
}
