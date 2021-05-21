///
/// Types of shortcuts that exist
///
class ShortcutTypes {
  static const MAC_TYPE = ShortcutTypes._("mac");

  final String part;

  const ShortcutTypes._(this.part);
}

///
/// Data class with all the information for a shortcut type.
///
class ShortcutHandle {
  final ShortcutTypes type;
  final String data;

  const ShortcutHandle(this.type, this.data);

  @override
  bool operator ==(Object other) {
    if (other is ShortcutHandle) {
      return other.type == this.type && other.data == this.data;
    }
    return false;
  }

  @override
  int get hashCode => super.hashCode;
}
