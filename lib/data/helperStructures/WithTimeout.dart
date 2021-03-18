///
/// A simple data class for streams that have a timeout.
/// A normal usage would be.
/// StreamBuilder<WithTimeout<String?>>(
///     stream: someStream,
///     initialData: WithTimeout.empty(),
///     builder: (context, snapshot) {
///         if (snapshot.data.timeoutExpired) {
///             // Handle timeout expired
///         } else if (snapshot.data.data != null) {
///             // Handle data
///         }
///     }
/// );
///
class WithTimeout<T> {
  final T? data;
  final bool timeoutExpired;

  WithTimeout(this.data, this.timeoutExpired);

  WithTimeout.empty()
      : this.data = null,
        this.timeoutExpired = false;
}
